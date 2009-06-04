package AI::Logic::Database;

use warnings;
use strict;

use Carp 'croak';
use Scalar::Util;
use AI::Logic::Var 'Var';
use AI::Logic::Unification ':all';

=head1 NAME

AI::Logic::Database - Logic variables

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

 package My::Database;
 use AI::Logic::Database
   variables  => qw(PERSON),
   predicates => qw(
   male/1
   acts/1
   actor/2
 );
 AI::Logic::Database->add_to_database(
     male('frank');
     male('barney');
     acts('frank');
 );

=cut 

my %DATABASE;

sub import {
    my ( $class, %arg_for ) = @_;

    # XXX assert that values are arrays
    my $callpack = caller(0);
    {
        no strict 'refs';
        *{"$callpack\::Rule"} = \&Rule;
        *{"$callpack\::Any"} = sub { AI::Logic::Var::Any->new };
    }
    my @variables;
    if ( my $variables = delete $arg_for{variables} ) {
        foreach my $variable (@$variables) {
            no strict 'refs';

            # is this enough?
            my $var = Var;
            *{"$callpack\::$variable"} = sub { $var };
            push @variables => $variable;
        }
    }
    local $" = ' ';
    eval <<"    END";
    package $callpack; 
    use subs qw(@variables)
    END
    croak($@) if $@;

    my $predicates = delete $arg_for{predicates}
      or croak("No predicates found for database ($callpack)");

    my %database;
    my %installed;
    foreach my $predicate (@$predicates) {
        my ( $name, $arity ) = split /\// => $predicate;
        $database{$name}{$arity}{fact_or_rule} ||= [];

        # this creates the code which the end user will see.  We might break
        # this down into unifier/arity, facts/arity and rules/arity
        $database{$name}{unifier} ||= _end_user_unifier( \%database, $name );

        no warnings 'numeric';
        if ( not $installed{$name}++ ) {
            no strict 'refs';
            *{"$callpack\::$name"} = _add_to_database( \%database, $name );
        }

        # XXX assert the name can be a function and that the arity is a
        # non-negative integer (what do foo/0 mean in this context?)
        $database{$name}{$arity}{unifier} =
          _internal_unifier( \%database, $name, $arity );
    }
    $DATABASE{$callpack} = \%database;

    if ( my @keys = keys %arg_for ) {
        local $" = ', ';
        croak "Unknown keys passed to AI::Logic::Database (@keys)";
    }
}

# @rules = (
#  [ 'wife', Person ],
#  [ 'married', Any, Person ],
#  [ 'female', Person ]
#);
# sub wife {
#     my ($Person, $continuation) = @_;
#     married(
#         Any, $Person,
#         sub { female( $Person, $continuation ) }
#     );
# }
sub Rule(&) {
    local $ENV{CREATING_RULE} = 1;
    my @rules = shift->() or return;

    unless ( @rules > 1 ) {
        croak "Rules must have both a head and a tail";
    }

    my ( $database, $name, @args ) = @{ pop @rules };
    my @variables = _make_arg_list(@args);
    local $" = ', ';
    my $rule = "{PACKAGE}::$name(@variables, \$continuation)";
    while ( my $curr_rule = pop @rules ) {
        my ( $database, $name, @args ) = @$curr_rule;
        my @variables = _make_arg_list(@args);
        if (@rules) {
            $rule = <<"            END_RULE";
    {PACKAGE}::$name(
        @variables, 
        sub {
            $rule;
        }
    );
            END_RULE
        }
        else {
            $rule = <<"            END_RULE";
sub {
    my (@variables, \$continuation) = \@_;
    $rule;
}
            END_RULE
            my $arity = @args;

        # this is for delayed evaluation.  When the unifier hits this rule, it
        # will be eval'ed against the target namespace and installed as a proper
        # rule.  This only happens once.
            push @{ $database->{$name}{$arity}{fact_or_rule} } => $rule;
        }
    }
    return;
}

sub _make_arg_list {
    my @args = @_;
    my @variables;
    foreach my $arg (@args) {
        if ( UNIVERSAL::isa( $arg, 'AI::Logic::Var::Any' ) ) {
            push @variables => 'AI::Logic::Var::Any->new()';
        }
        elsif ( UNIVERSAL::isa( $arg, 'AI::Logic::Var' ) ) {
            push @variables => '$v' . Scalar::Util::refaddr($arg);
        }
        else {
            push @variables => "'$arg'";
        }
    }
    return @variables;
}

sub _internal_unifier {
    my ( $database, $name, $arity ) = @_;
    return sub {
        local *__ANON__ = '__ANON__internal_unifier';
        my $continuation = pop @_;

        # take advantage of aliasing for the eval
        foreach ( @{ $database->{$name}{$arity}{fact_or_rule} } ) {

            # $fact_or_rule should be an array reference
            if ( !ref $_ ) {    # bless it for safety?
                my $callpack = $ENV{DB_CALLPACK};
                s/{PACKAGE}/$callpack/g;
                my $code = $_;
                $_ = eval "$_";
                if ( my $error = $@ ) {
                    croak(
                        "Creating rule for $name/$arity failed: $error\n$code");
                }
            }

            if ( 'ARRAY' eq ref $_ ) {    # we have a fact
                unify_all( $_, [@_], $continuation );
            }
            elsif ( 'CODE' eq ref $_ ) {    # we have a rule
                $_->( @_, $continuation );
            }
        }
    };
}

#if ( 1 == $arity ) {

#    # micro-optimization for the win! ;)
#    $database{$name}{$arity}{unifier} = sub {
#        my ( $var, $continuation ) = @_;
#        foreach my $data ( @{ $database{$name}{$arity}{fact_or_rule} } ) {
#            unify( @$data, $var, $continuation );
#        }
#    };
#}

=head2 C<get_database($package)>

This code will return the database defined in a given package.

=cut

sub get_database {
    my $name = shift;
    return $DATABASE{$name}
      or croak("No such database ($name)");
}

=head2 C<_add_to_database(\%database, $name)>

This returns a code ref that will be exported to the database package to
handle adding facts to the database;

=cut

sub _add_to_database {
    my ( $database, $name ) = @_;
    return sub (&) {
        if ( $ENV{CREATING_RULE} ) {
            return _add_rule_to_database( $database, $name, shift );
        }
        my @args  = shift->();
        my $arity = @args;
        unless ( exists $database->{$name}{$arity} ) {
            croak "Predicate $name/$arity not found in database";
        }
        push @{ $database->{$name}{$arity}{fact_or_rule} } => [@args]
          ;    # XXX maybe Clone
    };
}

sub _add_rule_to_database {
    my ( $database, $name, $coderef ) = @_;
    return [ $database, $name, $coderef->() ];
}

=head2 C<_end_user_unifier(\%database, $name)>

This returns a code ref that will be exported to the target package to handle
resolving facts and rules.  This is what the end consumer sees.

=cut

sub _end_user_unifier {
    my ( $database, $name ) = @_;
    return sub {
        my $continuation = $_[-1];
        my $arity        = @_ - 1;
        local *__ANON__ = "__ANON__end_user_unifier_$name/$arity";
        unless ( 'CODE' eq ref $continuation ) {
            croak "Last argument to ($name) must be a code reference";
        }
        if ( not exists $database->{$name}{$arity} ) {
            Carp::croak("Predicate $name/$arity not found in database");
        }
        else {
            local $ENV{DB_CALLPACK} = caller(0);
            $database->{$name}{$arity}{unifier}->(@_);
        }
    };
}

=head1 AUTHOR

Curtis "Ovid" Poe, C<< <ovid at cpan.org> >>

Based on the excellent "Perl and Prolog and Continuations... oh my!" by Adrian
Howard.  L<http://www.perlmonks.org/index.pl?node_id=193649>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ai-logic at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=AI-Logic>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AI::Logic::Database


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=AI-Logic>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/AI-Logic>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/AI-Logic>

=item * Search CPAN

L<http://search.cpan.org/dist/AI-Logic/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Curtis "Ovid" Poe, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;    # End of AI::Logic::Database

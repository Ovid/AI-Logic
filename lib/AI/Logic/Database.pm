package AI::Logic::Database;

use warnings;
use strict;

use Carp 'croak';
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
    if ( my $variables = delete $arg_for{variables} ) {
        foreach my $variable (@$variables) {
            no strict 'refs';

            # is this enough?
            *{"$callpack\::$variable"} = sub { Var };
        }
    }
    my $predicates = delete $arg_for{predicates}
      or die "No predicates found for database ($callpack)";

    my %database;
    my %installed;
    foreach my $predicate (@$predicates) {
        my ( $name, $arity ) = split /\// => $predicate;
        $database{$name}{$arity}{data} ||= [];
        $database{$name}{unifier} = sub {
            unless ( 'CODE' eq ref $_[-1] ) {
                croak "Last argument to ($name) must be a code reference";
            }
            my $arity = @_ - 1;
            if ( not exists $database{$name}{$arity} ) {
                Carp::croak("Predicate $name/$arity not found in database");
            }
            else {
                $database{$name}{$arity}{unification}->(@_);
            }
        };

        if ( not $installed{$name} ) {
            no strict 'refs';
            *{"$callpack\::$name"} = sub {
                my $arity = @_;
                unless ( exists $database{$name}{$arity} ) {
                    croak "Predicate $name/$arity not found in database";
                }
                push @{ $database{$name}{$arity}{data} } => [@_];    # XXX maybe Clone
            };
            $installed{$name} = 1;
        }
        # XXX assert the name can be a function and that the arity is a
        # non-negative integer (what do foo/0 mean in this context?)

        if ( 1 == $arity ) {

            # micro-optimization for the win! ;)
            $database{$name}{$arity}{unification} = sub {
                my ( $var, $continuation ) = @_;
                foreach my $data ( @{ $database{$name}{$arity}{data} } ) {
                    unify( @$data, $var, $continuation );
                }
            };
        }
        else {
            $database{$name}{$arity}{unification} = sub {
                my $continuation = pop @_;
                foreach my $data ( @{ $database{$name}{$arity}{data} } ) {

                    # $data should be an array reference
                    unify_all( $data, [@_], $continuation );
                }
            };
        }
    }
    $DATABASE{$callpack} = \%database;

    if ( my @keys = keys %arg_for ) {
        local $" = ', ';
        croak "Unknown keys passed to AI::Logic::Database (@keys)";
    }
}

sub get_database {
    my $name = shift;
    return $DATABASE{$name}
      or croak("No such database ($name)");
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

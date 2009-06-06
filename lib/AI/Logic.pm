package AI::Logic;

use warnings;
use strict;

use Carp 'croak';

use AI::Logic::Database ();

=head1 NAME

AI::Logic - Continuation based logic programming.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 ALPHA CODE

Warning:  this is not yet documented or tested well.  I'm just making this
publicly available because some folks wanted to see it.  It probably has lots
of bugs.

=head1 SYNOPSIS

 {
     package My::Database;
     use AI::Logic::Database variables => [ 'Person' ],
       predicates => [
         qw{
           male/1
           female/1
           married/2
           wife/1
           insane/1
           strange_husband/1
           }
       ];
     male { 'frank' };
     male { 'barney' };
     male { 'timothy' };
     male { 'ovid' };
     male { 'Sam' };
     female { 'Sarah' };
     female { 'Leila' };
     female { 'Samantha' };
     married { 'frank', 'Sarah' };
     married { 'Sam',   'Samantha' };
     married { 'Bill', 'John' };
 
     Rule {
         wife { Person } => 
           married { Any, Person },
           female { Person };
     };
 }
 
 use AI::Logic 'My::Database';
 
 # Are any of these names known males?
 my @names;
 foreach my $name (qw/frank judy barney/) {
     male( $name, sub { push @names => $name; } );
 }
 # @names will contain 'frank' and 'barney'
 
 my $male = Var;
 @names = ();
 male( $male, sub { push @names => $male->value } );
 # @names will contain all known males
 
 # who is frank married to?
 my $husband = Var 'frank';
 my $wife    = Var;
 married(
     $husband, $wife,
     sub {
         print 'frank is married to '.$wife->value."\n";
     }
 );
 
 # print all married couples
 $husband->unbind;
 $wife->unbind;
 my @spouses;
 married(
     $husband, $wife,
     sub {
         print $husband->value .' is married to '.$wife->value."\n";
     }
 );
 
 my $var = Var 'Sarah';
 my $is_wife;
 wife( $var, sub { $is_wife = 1 });
 if ( $is_wife ) {
     print "Yes\n";
 }
 else {
     print "No\n";
 }
 
 # You can create rules on the fly, but it's not fun and they'll conflict with
 # other rules of the same name.
 sub strange_husband {
     my ($person, $continuation) = @_;
     insane(
         $person,
         sub {
             married(
                 $person, Any,
                 sub {
                     male( $person, $continuation );
                 }
             );
         }
     );
 }
 $husband = Var;
 strange_husband($husband, sub { print $husband->value });
 # equivalent to the following declaration in a database:
 
 Rule {
     strange_husband { Person } =>
         insane { Person },
         married { Person, Any },
         male { Person },
 }

=head1 EXPORT

The following functions are exported automatically:

=over 4

=item *C<Var>

Used to declare logic variables.  These variables may be bound or unbound.

 my $person = Var 'ovid';   # bound
 my $person = Var;          # unbound

=item * C<Any>

Used to declare a logic variable whose value you do not care about.

=back

All predicates declared in your database will be exported as functions to your
code.

=cut

sub import {
    my ( $class, $database_class ) = @_;
    my $database = AI::Logic::Database::get_database($database_class);

    my $callpack = caller(0);
    while ( my ( $name, $definition ) = each %$database ) {
        no strict 'refs';
        *{"$callpack\::$name"} = $definition->{unifier};
        *{"$callpack\::Any"}   = sub () { AI::Logic::Var::Any->new };
        *{"$callpack\::Var"}   = *AI::Logic::Var::Var{CODE};
    }
}

=head1 AUTHOR

Curtis "Ovid" Poe, C<< <ovid at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ai-logic at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=AI-Logic>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AI::Logic

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

1;    # End of AI::Logic

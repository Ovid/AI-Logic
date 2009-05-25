#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';
use Test::Most qw/no_plan/;

{

    package My::Database;
    use AI::Logic::Database predicates => [
        qw{
          male/1
          female/1
          married/2
          }
    ];
    male('frank');
    male('barney');
    male('timothy');
    male('ovid');
    male('Sam');
    female('Sarah');
    female('Leila');
    female('Samantha');
    married( 'frank', 'Sarah' );
    married( 'Sam',   'Samantha' );
}

use AI::Logic 'My::Database';
use AI::Logic::Var 'Var';

throws_ok {
    male( 1, 2, sub { } );
}
qr{^Predicate male/2 not found in database},
  'Calling an unknown predicate should fail';

my @names;
foreach my $name (qw/frank judy barney/) {
    male( $name, sub { push @names => $name; } );
}
eq_or_diff \@names, [qw/frank barney/],
  'Matching against individual names should succeed';
my $male = Var;
@names = ();
male( $male, sub { push @names => $male->value } );
eq_or_diff \@names, [qw/frank barney timothy ovid Sam/],
  '... and matching against logic variables should succeed';

my $husband = Var 'frank';
my $wife    = Var;
married(
    $husband, $wife,
    sub {
        is $wife->value, 'Sarah', 'Predicates with an arity > 1 should succeed';
    }
);
$husband->unbind;
$wife->unbind;
my @spouses;
married(
    $husband, $wife,
    sub {
        push @spouses => [ $husband->value, $wife->value ];
    }
);
eq_or_diff \@spouses, [ [qw/frank Sarah/], [qw/Sam Samantha/] ],
  '... and you should be able to search all records if the arity > 1';

my @wives;

# wife(Person) :- married(_,Person), female(Person).
# :- ( wife(Person), married(_,Person), female(Person) ).

sub wife {
    my $var = shift;
    married(
        Var, $var,
        sub {
            female( $var, sub { push @wives => $var->value } );
        }
    );
}
wife( Var 'Sarah' );
eq_or_diff \@wives, ['Sarah'], 'We should be able to match a head :- tail rule';

@wives = ();
wife(Var);
eq_or_diff \@wives, [ 'Sarah', 'Samantha' ],
  'We should be able to match a head :- tail rule';

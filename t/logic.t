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
          acts/1
          actor/2
          }
    ];
    male('frank');
    male('barney');
    male('timothy');
    male('ovid');
    male('Sam');
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

#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most 'no_plan';

use AI::Logic::Var 'Var';
use AI::Logic::Unification ':all';

my $unbound1 = Var;
my $bound1   = Var "hello";
my $unbound2 = Var;
my $bound2   = Var "hello";
my $bound3   = Var 'good bye';

my $unified;
my $continuation = sub { $unified = 1 };
unify( $unbound1, $bound1, $continuation );
ok $unified, 'Unifying an unbound to a bound should succeed';

$unified = undef;
unify( $bound1, $unbound1, $continuation );
ok $unified, 'Unifying an bound to an un bound should succeed';

$unified = undef;
unify( $unbound1, $unbound2, $continuation );
ok $unified, 'Unifying two unbounds should succeed';

$unified = undef;
unify( $bound1, $bound2, $continuation );
ok $unified, 'Unifying two equal bounds should succeed';

$unified = undef;
unify( $bound1, $bound3, $continuation );
ok !$unified, 'Unifying two unequal bounds should fail';

#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use AI::Logic::Var 'Var';
use AI::Logic::Unification ':all';
use AI::Logic::List;

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

# Test list detection helper functions
subtest 'List detection helpers' => sub {
    # Test _is_list function
    my $empty_list = AI::Logic::List->new();
    my $non_empty_list = AI::Logic::List->cons('a', AI::Logic::List->new());
    my $var = Var;
    my $string = "hello";
    my $number = 42;
    
    ok(AI::Logic::Unification::_is_list($empty_list), '_is_list() returns true for empty list');
    ok(AI::Logic::Unification::_is_list($non_empty_list), '_is_list() returns true for non-empty list');
    ok(!AI::Logic::Unification::_is_list($var), '_is_list() returns false for variable');
    ok(!AI::Logic::Unification::_is_list($string), '_is_list() returns false for string');
    ok(!AI::Logic::Unification::_is_list($number), '_is_list() returns false for number');
    ok(!AI::Logic::Unification::_is_list(undef), '_is_list() returns false for undef');
    
    # Test _both_lists function
    my $list1 = AI::Logic::List->new();
    my $list2 = AI::Logic::List->cons('x', AI::Logic::List->new());
    
    ok(AI::Logic::Unification::_both_lists($list1, $list2), '_both_lists() returns true for two lists');
    ok(AI::Logic::Unification::_both_lists($empty_list, $non_empty_list), '_both_lists() returns true for empty and non-empty lists');
    ok(!AI::Logic::Unification::_both_lists($list1, $var), '_both_lists() returns false for list and variable');
    ok(!AI::Logic::Unification::_both_lists($var, $list1), '_both_lists() returns false for variable and list');
    ok(!AI::Logic::Unification::_both_lists($var, $string), '_both_lists() returns false for two non-lists');
    ok(!AI::Logic::Unification::_both_lists($string, $number), '_both_lists() returns false for string and number');
};

done_testing();

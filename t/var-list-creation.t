#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';
use AI::Logic::Var 'Var';
use AI::Logic::List;

subtest 'Empty list creation' => sub {
    my $empty = Var([]);
    
    isa_ok($empty, 'AI::Logic::List', 'Var([]) creates List object');
    ok($empty->is_empty(), 'Empty array creates empty list');
};

subtest 'Single element list creation' => sub {
    my $single = Var(['a']);
    
    isa_ok($single, 'AI::Logic::List', 'Single element array creates List object');
    ok(!$single->is_empty(), 'Single element list is not empty');
    is($single->head(), 'a', 'Head is correct');
    ok($single->tail()->is_empty(), 'Tail is empty list');
};

subtest 'Multi-element list creation' => sub {
    my $colors = Var([qw/ red green blue /]);
    
    isa_ok($colors, 'AI::Logic::List', 'Multi-element array creates List object');
    
    my $list = $colors;
    is($list->head(), 'red', 'First element is red');
    
    $list = $list->tail();
    is($list->head(), 'green', 'Second element is green');
    
    $list = $list->tail();
    is($list->head(), 'blue', 'Third element is blue');
    
    ok($list->tail()->is_empty(), 'Final tail is empty');
};

subtest 'Nested list creation' => sub {
    my $nested = Var([1, [2, 3], 4]);
    
    isa_ok($nested, 'AI::Logic::List', 'Nested array creates List object');
    
    my $list = $nested;
    is($list->head(), 1, 'First element is 1');
    
    $list = $list->tail();
    isa_ok($list->head(), 'AI::Logic::List', 'Second element is a List object');
    
    my $inner_list = $list->head();
    is($inner_list->head(), 2, 'Inner list first element is 2');
    is($inner_list->tail()->head(), 3, 'Inner list second element is 3');
    ok($inner_list->tail()->tail()->is_empty(), 'Inner list tail is empty');
    
    $list = $list->tail();
    is($list->head(), 4, 'Third element is 4');
    ok($list->tail()->is_empty(), 'Final tail is empty');
};

subtest 'Mixed data types' => sub {
    my $mixed = Var(['string', 42, ['nested', 'array']]);
    
    isa_ok($mixed, 'AI::Logic::List', 'Mixed type array creates List object');
    
    my $list = $mixed;
    is($list->head(), 'string', 'String element preserved');
    
    $list = $list->tail();
    is($list->head(), 42, 'Number element preserved');
    
    $list = $list->tail();
    isa_ok($list->head(), 'AI::Logic::List', 'Nested array becomes List object');
};

subtest 'Non-array values unchanged' => sub {
    my $string = Var('hello');
    my $number = Var(42);
    my $undef_var = Var(undef);
    my $unbound = Var;
    
    is($string->value(), 'hello', 'String values unchanged');
    is($number->value(), 42, 'Number values unchanged');
    is($undef_var->value(), undef, 'Undef values unchanged');
    is($unbound->value(), undef, 'Unbound variables unchanged');
};

done_testing();
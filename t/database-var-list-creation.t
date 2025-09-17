#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';

subtest 'Var function exported to database package for list creation' => sub {
    # Define a test database package
    {
        package TestDatabase;
        use AI::Logic::Database
            variables => [qw(X Y Z)],
            predicates => [qw(test_list/1)];
        
        # Test that Var function is available and creates lists from arrays
        my $empty_list = Var([]);
        ::isa_ok($empty_list, 'AI::Logic::List', 'Var([]) creates List object');
        ::ok($empty_list->is_empty(), 'Var([]) creates empty list');
        
        # Test Var with single element array
        my $single_list = Var(['item']);
        ::isa_ok($single_list, 'AI::Logic::List', 'Var([item]) creates List object');
        ::is($single_list->head(), 'item', 'Single element list has correct head');
        ::ok($single_list->tail()->is_empty(), 'Single element list has empty tail');
        
        # Test Var with multi-element array
        my $multi_list = Var(['a', 'b', 'c']);
        ::isa_ok($multi_list, 'AI::Logic::List', 'Var([a,b,c]) creates List object');
        ::is($multi_list->head(), 'a', 'Multi-element list has correct head');
        ::is($multi_list->tail()->head(), 'b', 'Multi-element list has correct second element');
    }
};

subtest 'Var function alongside existing constructors' => sub {
    {
        package TestDatabase2;
        use AI::Logic::Database
            variables => [qw(X Y)],
            predicates => [qw(mixed_test/1)];
        
        # Test that all constructors are available
        my $var = X;
        my $any = Any();
        my $list = Var(['item']);
        my $regular_var = Var('string');
        
        ::isa_ok($var, 'AI::Logic::Var::Named', 'Variable constructor works');
        ::isa_ok($any, 'AI::Logic::Var::Any', 'Any constructor works');
        ::isa_ok($list, 'AI::Logic::List', 'Var with array creates List');
        ::isa_ok($regular_var, 'AI::Logic::Var', 'Var with string creates Var');
        
        ::is($regular_var->value(), 'string', 'Regular Var has correct value');
        ::is($list->head(), 'item', 'List created by Var has correct head');
    }
};

subtest 'Var list creation patterns' => sub {
    {
        package TestDatabase3;
        use AI::Logic::Database
            variables => [qw(X)],
            predicates => [qw(test/1)];
        
        # Test different array patterns
        my $empty = Var([]);
        my $single = Var(['item']);
        my $multiple = Var(['first', 'second', 'third']);
        my $nested = Var([1, [2, 3], 4]);
        
        ::isa_ok($empty, 'AI::Logic::List', 'Empty array creates List');
        ::isa_ok($single, 'AI::Logic::List', 'Single element array creates List');
        ::isa_ok($multiple, 'AI::Logic::List', 'Multiple element array creates List');
        ::isa_ok($nested, 'AI::Logic::List', 'Nested array creates List');
        
        ::ok($empty->is_empty(), 'Empty array creates empty list');
        ::is($single->head(), 'item', 'Single element has correct head');
        ::is($multiple->head(), 'first', 'Multiple elements have correct head');
        ::is($nested->head(), 1, 'Nested array has correct first element');
        ::isa_ok($nested->tail()->head(), 'AI::Logic::List', 'Nested array creates nested lists');
    }
};

done_testing();
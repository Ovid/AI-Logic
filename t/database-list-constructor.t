#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';

subtest 'List constructor exported to database package' => sub {
    # Define a test database package
    {
        package TestDatabase;
        use AI::Logic::Database
            variables => [qw(X Y Z)],
            predicates => [qw(test_list/1)];
        
        # Test that List constructor is available
        my $empty_list = List();
        ::isa_ok($empty_list, 'AI::Logic::List', 'List() constructor creates List object');
        ::ok($empty_list->is_empty(), 'List() creates empty list');
        
        # Test List constructor with arguments
        my $list_with_head = List('a', List());
        ::isa_ok($list_with_head, 'AI::Logic::List', 'List(head, tail) creates List object');
        ::is($list_with_head->head(), 'a', 'List constructor sets head correctly');
        ::ok($list_with_head->tail()->is_empty(), 'List constructor sets tail correctly');
    }
};

subtest 'List constructor alongside Var and Any' => sub {
    {
        package TestDatabase2;
        use AI::Logic::Database
            variables => [qw(X Y)],
            predicates => [qw(mixed_test/1)];
        
        # Test that all constructors are available
        my $var = X;
        my $any = Any();
        my $list = List('item', List());
        
        ::isa_ok($var, 'AI::Logic::Var::Named', 'Variable constructor works');
        ::isa_ok($any, 'AI::Logic::Var::Any', 'Any constructor works');
        ::isa_ok($list, 'AI::Logic::List', 'List constructor works');
    }
};

subtest 'List constructor function signature' => sub {
    {
        package TestDatabase3;
        use AI::Logic::Database
            variables => [qw(X)],
            predicates => [qw(test/1)];
        
        # Test different ways to call List constructor
        my $empty1 = List();
        my $empty2 = List(undef, undef);
        my $single = List('item');
        my $pair = List('first', List('second', List()));
        
        ::isa_ok($empty1, 'AI::Logic::List', 'List() works');
        ::isa_ok($empty2, 'AI::Logic::List', 'List(undef, undef) works');
        ::isa_ok($single, 'AI::Logic::List', 'List(item) works');
        ::isa_ok($pair, 'AI::Logic::List', 'List(head, tail) works');
        
        ::ok($empty1->is_empty(), 'Empty list is empty');
        ::is($single->head(), 'item', 'Single item list has correct head');
        ::is($pair->head(), 'first', 'Pair list has correct head');
        ::is($pair->tail()->head(), 'second', 'Pair list has correct tail head');
    }
};

done_testing();
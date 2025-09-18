#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';

# Load the test database module first to create the database
use AI::Logic::TestDatabase;

# Import the test database to use its predicates
use AI::Logic 'AI::Logic::TestDatabase';

subtest 'Regular predicates work correctly' => sub {
    # Test male/1 predicate
    my @males;
    my $male_var = Var();
    male($male_var, sub { push @males, $male_var->value });
    is_deeply([sort @males], [sort qw(frank barney timothy sam)], 
              'All males found correctly');
    
    # Test female/1 predicate
    my @females;
    my $female_var = Var();
    female($female_var, sub { push @females, $female_var->value });
    is_deeply([sort @females], [sort qw(sarah leila samantha betty)], 
              'All females found correctly');
    
    # Test married/2 predicate
    my @married_couples;
    my $husband = Var();
    my $wife = Var();
    married($husband, $wife, sub {
        push @married_couples, [$husband->value, $wife->value];
    });
    is_deeply([sort { $a->[0] cmp $b->[0] } @married_couples],
              [sort { $a->[0] cmp $b->[0] } (
                  ['frank', 'sarah'],
                  ['barney', 'betty'], 
                  ['sam', 'samantha']
              )],
              'All married couples found correctly');
    
    # Test parent/2 predicate
    my @parent_child;
    my $parent_var = Var();
    my $child_var = Var();
    parent($parent_var, $child_var, sub {
        push @parent_child, [$parent_var->value, $child_var->value];
    });
    is_deeply([sort { $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] } @parent_child],
              [sort { $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] } (
                  ['frank', 'timothy'],
                  ['sarah', 'timothy'],
                  ['barney', 'sam'],
                  ['betty', 'sam']
              )],
              'All parent-child relationships found correctly');
    
    # Test child/2 rule (inverse of parent)
    my @child_parent;
    $child_var = Var();
    $parent_var = Var();
    child($child_var, $parent_var, sub {
        push @child_parent, [$child_var->value, $parent_var->value];
    });
    is_deeply([sort { $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] } @child_parent],
              [sort { $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] } (
                  ['timothy', 'frank'],
                  ['timothy', 'sarah'],
                  ['sam', 'barney'],
                  ['sam', 'betty']
              )],
              'Child rule works correctly (inverse of parent)');
};

subtest 'List predicates are callable but not implemented' => sub {
    # Test that list predicates can be called without crashing
    # They won't succeed since they have no rules/facts yet
    
    my $success_count = 0;
    
    eval {
        Append(Var([]), Var([1, 2]), Var([1, 2]), sub { $success_count++ });
    };
    ok(!$@, 'Append/3 call does not crash');
    
    eval {
        Member(Var(1), Var([1, 2, 3]), sub { $success_count++ });
    };
    ok(!$@, 'Member/2 call does not crash');
    
    eval {
        Select(Var(1), Var([1, 2, 3]), Var([2, 3]), sub { $success_count++ });
    };
    ok(!$@, 'Select/3 call does not crash');
    
    eval {
        Empty_list(Var([]), sub { $success_count++ });
    };
    ok(!$@, 'Empty_list/1 call does not crash');
    
    eval {
        Length(Var([1, 2, 3]), Var(3), sub { $success_count++ });
    };
    ok(!$@, 'Length/2 call does not crash');
    
    # Since no rules are implemented, success_count should be 0
    is($success_count, 0, 'List predicates do not succeed (no rules implemented yet)');
};

subtest 'Mixed variable types work together' => sub {
    # Test that we can create and use different variable types
    my $person = Var('frank');
    my $list_of_names = Var(['frank', 'sarah', 'timothy']);
    my $empty_list = Var([]);
    
    # Verify the person is male
    my $is_male = 0;
    male($person, sub { $is_male = 1 });
    ok($is_male, 'Frank is correctly identified as male');
    
    # Test list variable properties
    isa_ok($list_of_names, 'AI::Logic::List', 'List of names is a List object');
    is($list_of_names->head(), 'frank', 'List head is correct');
    is($list_of_names->tail()->head(), 'sarah', 'List tail head is correct');
    
    isa_ok($empty_list, 'AI::Logic::List', 'Empty list is a List object');
    ok($empty_list->is_empty(), 'Empty list is correctly empty');
    
    # Test that we can create variables of different types
    my $any_var = Any();
    my $bound_var = Var('test');
    my $unbound_var = Var();
    
    isa_ok($any_var, 'AI::Logic::Var::Any', 'Any variable created correctly');
    isa_ok($bound_var, 'AI::Logic::Var', 'Bound variable created correctly');
    isa_ok($unbound_var, 'AI::Logic::Var', 'Unbound variable created correctly');
    
    is($bound_var->value(), 'test', 'Bound variable has correct value');
    ok(!$unbound_var->bound(), 'Unbound variable is not bound');
};

subtest 'Database supports both regular and list predicate queries' => sub {
    # Test that we can query both types of predicates in the same session
    
    # Query regular predicates
    my $frank_is_male = 0;
    male(Var('frank'), sub { $frank_is_male = 1 });
    ok($frank_is_male, 'Can query regular predicates');
    
    # Attempt to query list predicates (they should be callable but not succeed)
    my $append_called = 0;
    eval {
        Append(Var([]), Var([1]), Var([1]), sub { $append_called = 1 });
    };
    ok(!$@, 'Can call list predicates without error');
    is($append_called, 0, 'List predicates do not succeed (no implementation yet)');
    
    # Test that both types of predicates exist in the same namespace
    ok(defined &male, 'Regular predicate function exists');
    ok(defined &Append, 'List predicate function exists');
    ok(defined &Var, 'Var constructor exists');
    ok(defined &Any, 'Any constructor exists');
    # Note: Named variables like Person are only available within the database package
};

done_testing();
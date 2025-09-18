#!/usr/bin/perl

use v5.40.0;
use Test::Most;

# Test singleton behavior for empty lists
use lib 'lib';
use AI::Logic::List;

subtest 'Empty list singleton behavior' => sub {
    # Test that all ways of creating empty lists return the same singleton
    my $empty1 = AI::Logic::List->new();
    my $empty2 = AI::Logic::List->new(undef, undef);
    my $empty3 = AI::Logic::List->empty();
    
    is($empty1, $empty2, 'new() and new(undef, undef) return same singleton');
    is($empty1, $empty3, 'new() and empty() return same singleton');
    is($empty2, $empty3, 'new(undef, undef) and empty() return same singleton');
    
    # Verify they're actually the same object reference
    ok($empty1 == $empty2, 'Empty lists are identical references');
    ok($empty1 == $empty3, 'Empty lists are identical references');
};

subtest 'Adding data to empty list creates new instance' => sub {
    my $empty = AI::Logic::List->new();
    my $non_empty = AI::Logic::List->cons('test', $empty);
    
    # Should NOT be the same object
    isnt($empty, $non_empty, 'Adding data creates new list instance');
    ok($empty != $non_empty, 'Different object references');
    
    # Verify the non-empty list has correct structure
    is($non_empty->head(), 'test', 'Non-empty list has correct head');
    is($non_empty->tail(), $empty, 'Non-empty list tail is empty singleton');
    ok(!$non_empty->is_empty(), 'Non-empty list is not empty');
};

subtest 'Cons method preserves singleton for tail' => sub {
    my $empty = AI::Logic::List->new();
    my $list1 = AI::Logic::List->cons('a', $empty);
    my $list2 = AI::Logic::List->cons('b');  # No tail provided
    
    # Both should have the same empty singleton as tail
    is($list1->tail(), $empty, 'Explicit empty tail is singleton');
    is($list2->tail(), $empty, 'Default empty tail is singleton');
    is($list1->tail(), $list2->tail(), 'Both tails are same singleton');
};

subtest 'Multiple levels preserve singleton' => sub {
    my $empty = AI::Logic::List->new();
    
    # Create nested structure: ['a', ['b', []]]
    my $inner = AI::Logic::List->cons('b', $empty);
    my $outer = AI::Logic::List->cons('a', $inner);
    
    # The deepest tail should still be the singleton
    is($inner->tail(), $empty, 'Inner list tail is singleton');
    is($outer->tail()->tail(), $empty, 'Nested tail is singleton');
};

subtest 'Different construction methods return singleton' => sub {
    my $empty1 = AI::Logic::List->new();
    my $empty2 = AI::Logic::List->empty();
    
    # Create a list and then access its "empty" parts
    my $list = AI::Logic::List->cons('test');
    my $tail_empty = $list->tail();
    
    # All should be the same singleton
    is($empty1, $tail_empty, 'Tail of single-element list is singleton');
    is($empty2, $tail_empty, 'Tail matches empty() singleton');
};

subtest 'Singleton behavior with undef head' => sub {
    my $empty = AI::Logic::List->new();
    
    # Create list with undef head - should NOT be empty
    my $undef_head = AI::Logic::List->new(undef, $empty);
    
    isnt($undef_head, $empty, 'List with undef head is not empty singleton');
    ok(!$undef_head->is_empty(), 'List with undef head is not empty');
    is($undef_head->head(), undef, 'Head is correctly undef');
    is($undef_head->tail(), $empty, 'Tail is empty singleton');
};

subtest 'Edge cases for singleton' => sub {
    my $empty = AI::Logic::List->new();
    
    # Test that we can't accidentally create multiple empty lists
    my $attempt1 = AI::Logic::List->cons(undef, undef);  # This should create [undef|undef], not empty
    my $attempt2 = AI::Logic::List->new(undef);          # This should create [undef|[]], not empty
    
    isnt($attempt1, $empty, 'cons(undef, undef) creates non-empty list');
    isnt($attempt2, $empty, 'new(undef) creates non-empty list');
    
    # But these should return the singleton
    my $explicit_empty1 = AI::Logic::List->new(undef, undef);
    my $explicit_empty2 = AI::Logic::List->empty();
    
    is($explicit_empty1, $empty, 'new(undef, undef) returns singleton');
    is($explicit_empty2, $empty, 'empty() returns singleton');
};

subtest 'Normalize method returns singleton for empty lists' => sub {
    my $empty = AI::Logic::List->new();
    
    # Create an "empty-like" list that isn't the singleton
    my $fake_empty = bless { head => undef, tail => undef }, 'AI::Logic::List';
    
    # They should not be the same object initially
    isnt($fake_empty, $empty, 'Fake empty is different object');
    
    # But normalize should return the singleton
    my $normalized = $fake_empty->normalize();
    is($normalized, $empty, 'normalize() returns singleton for empty list');
    
    # Non-empty list should return itself
    my $non_empty = AI::Logic::List->cons('test');
    my $normalized_non_empty = $non_empty->normalize();
    is($normalized_non_empty, $non_empty, 'normalize() returns self for non-empty list');
};

done_testing();
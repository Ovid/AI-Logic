#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load the module normally
use AI::Logic::List;

subtest 'Empty list operations' => sub {
    my $empty = AI::Logic::List->new();
    isa_ok($empty, 'AI::Logic::List', 'Empty list constructor returns correct type');
    ok($empty->is_empty(), 'Empty list is_empty() returns true');
    is($empty->head(), undef, 'Empty list head() returns undef');
    is($empty->tail(), undef, 'Empty list tail() returns undef');
};

subtest 'Non-empty list construction' => sub {
    my $tail_list = AI::Logic::List->new();
    my $list = AI::Logic::List->new('a', $tail_list);
    isa_ok($list, 'AI::Logic::List', 'Non-empty list constructor returns correct type');
    ok(!$list->is_empty(), 'Non-empty list is_empty() returns false');
    is($list->head(), 'a', 'Non-empty list head() returns correct value');
    isa_ok($list->tail(), 'AI::Logic::List', 'Non-empty list tail() returns List object');
    ok($list->tail()->is_empty(), 'Single element list has empty tail');
};

subtest 'cons() class method with tail' => sub {
    my $empty = AI::Logic::List->new();
    my $cons_list = AI::Logic::List->cons('x', $empty);
    isa_ok($cons_list, 'AI::Logic::List', 'cons() returns correct type');
    is($cons_list->head(), 'x', 'cons() sets head correctly');
    isa_ok($cons_list->tail(), 'AI::Logic::List', 'cons() tail is List object');
    ok($cons_list->tail()->is_empty(), 'cons() with empty tail works');
};

subtest 'cons() class method without tail' => sub {
    my $cons_single = AI::Logic::List->cons('y');
    isa_ok($cons_single, 'AI::Logic::List', 'cons() without tail returns correct type');
    is($cons_single->head(), 'y', 'cons() without tail sets head correctly');
    isa_ok($cons_single->tail(), 'AI::Logic::List', 'cons() without tail creates List tail');
    ok($cons_single->tail()->is_empty(), 'cons() without tail creates empty tail');
};

subtest 'Multi-element list construction' => sub {
    my $multi = AI::Logic::List->cons('first', 
                    AI::Logic::List->cons('second', 
                        AI::Logic::List->new()));
    is($multi->head(), 'first', 'Multi-element list first head correct');
    is($multi->tail()->head(), 'second', 'Multi-element list second head correct');
    ok($multi->tail()->tail()->is_empty(), 'Multi-element list ends with empty list');
};

done_testing();
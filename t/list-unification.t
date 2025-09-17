#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';
use AI::Logic::List;
use AI::Logic::Unification qw(unify);
use AI::Logic::Var 'Var';

subtest 'Empty list unification' => sub {
    my $empty1 = Var([]);
    my $empty2 = Var([]);
    
    my $unified = 0;
    unify($empty1, $empty2, sub { $unified = 1 });
    
    ok($unified, 'Two empty lists unify successfully');
};

subtest 'Empty vs non-empty list unification' => sub {
    my $empty = Var([]);
    my $non_empty = Var(['a']);
    
    my $unified = 0;
    unify($empty, $non_empty, sub { $unified = 1 });
    
    ok(!$unified, 'Empty list does not unify with non-empty list');
    
    # Test the reverse case
    $unified = 0;
    unify($non_empty, $empty, sub { $unified = 1 });
    
    ok(!$unified, 'Non-empty list does not unify with empty list');
};

subtest 'Single element list unification' => sub {
    my $list1 = Var(['a']);
    my $list2 = Var(['a']);
    
    my $unified = 0;
    unify($list1, $list2, sub { $unified = 1 });
    
    ok($unified, 'Single element lists with same element unify');
    
    # Test different elements
    my $list3 = Var(['b']);
    $unified = 0;
    unify($list1, $list3, sub { $unified = 1 });
    
    ok(!$unified, 'Single element lists with different elements do not unify');
};

subtest 'Multi-element list unification' => sub {
    my $list1 = Var(['a', 'b']);
    my $list2 = Var(['a', 'b']);
    
    my $unified = 0;
    unify($list1, $list2, sub { $unified = 1 });
    
    ok($unified, 'Multi-element lists with same structure unify');
    
    # Test different structure
    my $list3 = Var(['a', 'c']);
    $unified = 0;
    unify($list1, $list3, sub { $unified = 1 });
    
    ok(!$unified, 'Multi-element lists with different elements do not unify');
};

subtest 'List unification with variables' => sub {
    my $var = Var;  # Create unbound variable
    my $list = Var(['a']);
    
    my $unified = 0;
    my $was_bound = 0;
    my $bound_value;
    
    unify($var, $list, sub { 
        $unified = 1;
        $was_bound = $var->bound();
        $bound_value = $var->value() if $var->bound();
    });
    
    ok($unified, 'Variable unifies with list');
    ok($was_bound, 'Variable becomes bound during unification');
    isa_ok($bound_value, 'AI::Logic::List', 'Variable bound to list object');
    ok(!$var->bound(), 'Variable is unbound after unification completes');
};

subtest 'List head/tail variable unification' => sub {
    my $head_var = Var;  # Create unbound variables
    my $tail_var = Var;
    
    # Create list with variables as head and tail
    my $var_list = AI::Logic::List->new($head_var, $tail_var);
    
    # Create concrete list to unify with
    my $concrete_list = Var(['a', 'b']);
    
    my $unified = 0;
    my ($head_was_bound, $tail_was_bound);
    my ($head_bound_value, $tail_bound_value);
    
    unify($var_list, $concrete_list, sub { 
        $unified = 1;
        $head_was_bound = $head_var->bound();
        $tail_was_bound = $tail_var->bound();
        $head_bound_value = $head_var->value() if $head_var->bound();
        $tail_bound_value = $tail_var->value() if $tail_var->bound();
    });
    
    ok($unified, 'List with variable head/tail unifies with concrete list');
    ok($head_was_bound, 'Head variable becomes bound during unification');
    ok($tail_was_bound, 'Tail variable becomes bound during unification');
    is($head_bound_value, 'a', 'Head variable bound to correct value');
    isa_ok($tail_bound_value, 'AI::Logic::List', 'Tail variable bound to list');
};

subtest 'Nested list unification' => sub {
    # Create nested lists: [[a, b], c]
    my $list1 = Var([['a', 'b'], 'c']);
    my $list2 = Var([['a', 'b'], 'c']);
    
    my $unified = 0;
    unify($list1, $list2, sub { $unified = 1 });
    
    ok($unified, 'Nested lists with same structure unify');
    
    # Test different nested structure
    my $list3 = Var([['x', 'y'], 'c']);
    
    $unified = 0;
    unify($list1, $list3, sub { $unified = 1 });
    
    ok(!$unified, 'Nested lists with different inner structure do not unify');
};

subtest 'Different length list unification' => sub {
    my $short_list = Var(['a']);
    my $long_list = Var(['a', 'b']);
    
    my $unified = 0;
    unify($short_list, $long_list, sub { $unified = 1 });
    
    ok(!$unified, 'Lists of different lengths do not unify');
};

done_testing();
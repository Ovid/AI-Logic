#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';
use AI::Logic::Var 'Var';
use AI::Logic::Unification qw(unify);

subtest 'Variable unification with lists' => sub {
    my $var = Var;
    my $list = Var(['a', 'b', 'c']);
    
    my $unified = 0;
    my $bound_value;
    
    unify($var, $list, sub {
        $unified = 1;
        $bound_value = $var->value();
    });
    
    ok($unified, 'Unbound variable unifies with list');
    isa_ok($bound_value, 'AI::Logic::List', 'Variable bound to list object');
    is($bound_value->head(), 'a', 'Bound list has correct head');
};

subtest 'List unification with bound variables' => sub {
    my $bound_var = Var('hello');
    my $list = Var(['a', 'b']);
    
    my $unified = 0;
    unify($bound_var, $list, sub { $unified = 1 });
    
    ok(!$unified, 'Bound variable does not unify with different list');
    
    # Test with matching bound variable
    my $bound_list = Var(['hello']);
    $unified = 0;
    unify($bound_var, $bound_list, sub { $unified = 1 });
    
    ok(!$unified, 'String variable does not unify with list containing same string');
};

subtest 'Complex list-variable combinations' => sub {
    # Test list with variable elements
    my $head_var = Var;
    my $tail_var = Var;
    my $pattern_list = AI::Logic::List->new($head_var, $tail_var);
    
    my $concrete_list = Var(['x', 'y', 'z']);
    
    my $unified = 0;
    my ($head_value, $tail_value);
    
    unify($pattern_list, $concrete_list, sub {
        $unified = 1;
        $head_value = $head_var->value();
        $tail_value = $tail_var->value();
    });
    
    ok($unified, 'List with variable head/tail unifies with concrete list');
    is($head_value, 'x', 'Head variable bound to first element');
    isa_ok($tail_value, 'AI::Logic::List', 'Tail variable bound to list');
    is($tail_value->head(), 'y', 'Tail list has correct head');
};

subtest 'Nested list-variable unification' => sub {
    my $inner_var = Var;
    my $outer_list = Var([$inner_var, 'b']);
    
    my $concrete_list = Var([['nested', 'list'], 'b']);
    
    my $unified = 0;
    my $inner_value;
    
    unify($outer_list, $concrete_list, sub {
        $unified = 1;
        $inner_value = $inner_var->value();
    });
    
    ok($unified, 'Nested list with variable unifies');
    isa_ok($inner_value, 'AI::Logic::List', 'Inner variable bound to nested list');
    is($inner_value->head(), 'nested', 'Nested list has correct structure');
};

subtest 'Multiple variable unification in lists' => sub {
    my $var1 = Var;
    my $var2 = Var;
    my $var3 = Var;
    
    my $pattern = Var([$var1, $var2, $var3]);
    my $concrete = Var(['a', 'b', 'c']);
    
    my $unified = 0;
    my ($val1, $val2, $val3);
    
    unify($pattern, $concrete, sub {
        $unified = 1;
        $val1 = $var1->value();
        $val2 = $var2->value();
        $val3 = $var3->value();
    });
    
    ok($unified, 'Multiple variables in list unify');
    is($val1, 'a', 'First variable bound correctly');
    is($val2, 'b', 'Second variable bound correctly');
    is($val3, 'c', 'Third variable bound correctly');
};

subtest 'Backward compatibility with existing unification' => sub {
    # Test that existing variable-to-variable unification still works
    my $var1 = Var;
    my $var2 = Var('test');
    
    my $unified = 0;
    unify($var1, $var2, sub { $unified = 1 });
    
    ok($unified, 'Variable-to-variable unification still works');
    
    # Test string unification
    my $str_var1 = Var('hello');
    my $str_var2 = Var('hello');
    
    $unified = 0;
    unify($str_var1, $str_var2, sub { $unified = 1 });
    
    ok($unified, 'String variable unification still works');
    
    # Test unequal strings
    my $str_var3 = Var('world');
    $unified = 0;
    unify($str_var1, $str_var3, sub { $unified = 1 });
    
    ok(!$unified, 'Unequal string variables do not unify');
};

subtest 'List unification edge cases' => sub {
    # Empty list with variable
    my $var = Var;
    my $empty = Var([]);
    
    my $unified = 0;
    unify($var, $empty, sub { $unified = 1 });
    
    ok($unified, 'Variable unifies with empty list');
    
    # Two empty lists
    my $empty1 = Var([]);
    my $empty2 = Var([]);
    
    $unified = 0;
    unify($empty1, $empty2, sub { $unified = 1 });
    
    ok($unified, 'Two empty lists unify');
    
    # Variable with nested empty lists
    my $nested_var = Var;
    my $nested_empty = Var([[]]);
    
    $unified = 0;
    unify($nested_var, $nested_empty, sub { $unified = 1 });
    
    ok($unified, 'Variable unifies with list containing empty list');
};

done_testing();
#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Test that demonstrates list syntax parsing integration
use lib 'lib';
require AI::Logic::Database;
use AI::Logic::List;
use AI::Logic::Var;

subtest 'List syntax parsing functions work correctly' => sub {
    # Test empty list
    my $result = AI::Logic::Database::_parse_list_syntax([]);
    is($result, 'AI::Logic::List->new()', 'Empty list syntax parsed correctly');
    
    # Test simple list
    $result = AI::Logic::Database::_parse_list_syntax(['a', 'b']);
    like($result, qr/AI::Logic::List->new\('a'/, 'Simple list contains first element');
    like($result, qr/AI::Logic::List->new\('b'/, 'Simple list contains second element');
    
    # Test _make_arg_list with array
    my @args = AI::Logic::Database::_make_arg_list(['x', 'y']);
    is(scalar(@args), 1, '_make_arg_list returns one argument for array');
    like($args[0], qr/AI::Logic::List->new/, 'Array argument converted to List constructor');
};

subtest 'List serialization works correctly' => sub {
    # Create actual List objects and test serialization
    my $empty = AI::Logic::List->new();
    my $result = AI::Logic::Database::_serialize_list($empty);
    is($result, 'AI::Logic::List->new()', 'Empty list serializes correctly');
    
    my $single = AI::Logic::List->cons('test');
    $result = AI::Logic::Database::_serialize_list($single);
    like($result, qr/AI::Logic::List->new\('test'/, 'Single element list serializes correctly');
    
    # Test with nested lists
    my $nested = AI::Logic::List->cons(AI::Logic::List->cons('inner'), AI::Logic::List->new());
    $result = AI::Logic::Database::_serialize_list($nested);
    like($result, qr/AI::Logic::List->new\(AI::Logic::List->new/, 'Nested list serializes correctly');
};

subtest 'Variable handling in lists' => sub {
    # Test with variables
    my $var = AI::Logic::Var::Named->new(undef, 'TestVar');
    my @args = AI::Logic::Database::_make_arg_list($var);
    diag("Named variable result: " . $args[0]);
    like($args[0], qr/TestVar/, 'Named variable handled correctly');
    
    my $any = AI::Logic::Var::Any->new();
    @args = AI::Logic::Database::_make_arg_list($any);
    like($args[0], qr/\{PACKAGE\}::Any\(\)/, 'Any variable handled correctly');
};

done_testing();
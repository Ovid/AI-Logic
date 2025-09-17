#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load the modules
use lib 'lib';
use AI::Logic::List;

# We need to load Database.pm but not import it
require AI::Logic::Database;

# Test the list syntax parsing functions directly
subtest 'Empty list parsing' => sub {
    # Test _parse_list_syntax with empty array
    my $result = AI::Logic::Database::_parse_list_syntax([]);
    is($result, 'AI::Logic::List->new()', 'Empty array [] parses to empty list constructor');
};

subtest 'Simple list parsing' => sub {
    # Test _parse_list_syntax with simple elements
    my $result = AI::Logic::Database::_parse_list_syntax(['a', 'b', 'c']);
    like($result, qr/AI::Logic::List->new/, 'Simple list parsing returns List constructor calls');
    like($result, qr/'a'/, 'Contains first element');
    like($result, qr/'b'/, 'Contains second element');  
    like($result, qr/'c'/, 'Contains third element');
};

subtest 'List serialization' => sub {
    # Test _serialize_list with actual List objects
    my $empty = AI::Logic::List->new();
    my $result = AI::Logic::Database::_serialize_list($empty);
    is($result, 'AI::Logic::List->new()', 'Empty list serializes correctly');
    
    my $single = AI::Logic::List->cons('a');
    $result = AI::Logic::Database::_serialize_list($single);
    like($result, qr/AI::Logic::List->new\('a'/, 'Single element list serializes correctly');
};

subtest 'Extended _make_arg_list functionality' => sub {
    # Test that _make_arg_list handles arrays as list syntax
    my @result = AI::Logic::Database::_make_arg_list([]);
    is($result[0], 'AI::Logic::List->new()', '_make_arg_list handles empty array');
    
    @result = AI::Logic::Database::_make_arg_list(['a', 'b']);
    like($result[0], qr/AI::Logic::List->new/, '_make_arg_list handles simple array');
    
    # Test with actual List object
    my $list = AI::Logic::List->cons('test');
    @result = AI::Logic::Database::_make_arg_list($list);
    like($result[0], qr/AI::Logic::List->new/, '_make_arg_list handles List object');
};

done_testing();
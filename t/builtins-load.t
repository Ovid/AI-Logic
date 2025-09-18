#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';

subtest 'Builtins module loads correctly' => sub {
    use_ok('AI::Logic::Builtins');
    
    # Check that the module has the expected functions
    can_ok('AI::Logic::Builtins', 'register_builtins');
    
    # Verify version is defined
    ok(defined $AI::Logic::Builtins::VERSION, 'Version is defined');
};

done_testing();
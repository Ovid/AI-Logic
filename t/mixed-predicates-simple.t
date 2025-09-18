#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';
use AI::Logic::TestDatabase;  # This loads and creates the database

subtest 'Test database creation and basic functionality' => sub {
    # Test that the database can be created and accessed
    my $database = AI::Logic::Database::get_database('AI::Logic::TestDatabase');
    ok($database, 'Test database exists');
    
    # Test that all expected predicates are defined
    my @regular_predicates = qw(male female married parent child);
    my @list_predicates = qw(Append Member Select Empty_list List_length);
    
    for my $predicate (@regular_predicates) {
        ok(exists $database->{$predicate}, "$predicate predicate exists");
    }
    
    for my $predicate (@list_predicates) {
        ok(exists $database->{$predicate}, "$predicate predicate exists");
    }
    
    # Test specific arities
    ok(exists $database->{male}{1}, 'male/1 arity exists');
    ok(exists $database->{female}{1}, 'female/1 arity exists');
    ok(exists $database->{married}{2}, 'married/2 arity exists');
    ok(exists $database->{parent}{2}, 'parent/2 arity exists');
    ok(exists $database->{child}{2}, 'child/2 arity exists');
    ok(exists $database->{Append}{3}, 'Append/3 arity exists');
    ok(exists $database->{Member}{2}, 'Member/2 arity exists');
    ok(exists $database->{Select}{3}, 'Select/3 arity exists');
    ok(exists $database->{Empty_list}{1}, 'Empty_list/1 arity exists');
    ok(exists $database->{List_length}{2}, 'List_length/2 arity exists');
};

subtest 'Test database facts and rules' => sub {
    my $database = AI::Logic::Database::get_database('AI::Logic::TestDatabase');
    
    # Test that facts are stored
    ok(@{$database->{male}{1}{fact_or_rule}} > 0, 'male/1 has facts');
    ok(@{$database->{female}{1}{fact_or_rule}} > 0, 'female/1 has facts');
    ok(@{$database->{married}{2}{fact_or_rule}} > 0, 'married/2 has facts');
    ok(@{$database->{parent}{2}{fact_or_rule}} > 0, 'parent/2 has facts');
    
    # Test that child/2 has a rule (not just facts)
    ok(@{$database->{child}{2}{fact_or_rule}} > 0, 'child/2 has rules');
    
    # Test that list predicates are defined but have no facts/rules yet
    is(@{$database->{Append}{3}{fact_or_rule}}, 0, 'Append/3 has no facts/rules yet');
    is(@{$database->{Member}{2}{fact_or_rule}}, 0, 'Member/2 has no facts/rules yet');
    is(@{$database->{Select}{3}{fact_or_rule}}, 0, 'Select/3 has no facts/rules yet');
    is(@{$database->{Empty_list}{1}{fact_or_rule}}, 0, 'Empty_list/1 has no facts/rules yet');
    is(@{$database->{List_length}{2}{fact_or_rule}}, 0, 'List_length/2 has no facts/rules yet');
};

subtest 'Test mixed predicates can coexist' => sub {
    my $database = AI::Logic::Database::get_database('AI::Logic::TestDatabase');
    
    # Verify that both regular and list predicates exist in the same database
    my $has_regular = exists $database->{male} && exists $database->{female};
    my $has_list = exists $database->{Append} && exists $database->{Member};
    
    ok($has_regular, 'Database contains regular predicates');
    ok($has_list, 'Database contains list predicates');
    ok($has_regular && $has_list, 'Database contains both regular and list predicates');
    
    # Test that unifiers exist for all predicates
    ok(exists $database->{male}{unifier}, 'male has unifier');
    ok(exists $database->{Append}{unifier}, 'Append has unifier');
    
    # Test that the unifiers are code references
    isa_ok($database->{male}{unifier}, 'CODE', 'male unifier is code');
    isa_ok($database->{Append}{unifier}, 'CODE', 'Append unifier is code');
};

done_testing();
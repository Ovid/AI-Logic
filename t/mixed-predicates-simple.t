#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';
use lib 't/lib';
use AI::Logic::TestDatabase;  # This loads and creates the database

subtest 'Test database creation and basic functionality' => sub {
    # Test that the database can be created and accessed
    my $database = AI::Logic::Database::get_database('AI::Logic::TestDatabase');
    ok($database, 'Test database exists');
    
    # Test that all expected predicates are defined
    my @role_predicates = qw(developer designer manager);
    my @relationship_predicates = qw(works_on team_member mentor collaborates skill);
    my @entity_predicates = qw(project team);
    my @list_predicates = qw(Append Member Select Empty_list List_length);
    
    for my $predicate (@role_predicates, @relationship_predicates, @entity_predicates) {
        ok(exists $database->{$predicate}, "$predicate predicate exists");
    }
    
    for my $predicate (@list_predicates) {
        ok(exists $database->{$predicate}, "$predicate predicate exists");
    }
    
    # Test specific arities
    ok(exists $database->{developer}{1}, 'developer/1 arity exists');
    ok(exists $database->{designer}{1}, 'designer/1 arity exists');
    ok(exists $database->{manager}{1}, 'manager/1 arity exists');
    ok(exists $database->{works_on}{2}, 'works_on/2 arity exists');
    ok(exists $database->{team_member}{2}, 'team_member/2 arity exists');
    ok(exists $database->{mentor}{2}, 'mentor/2 arity exists');
    ok(exists $database->{collaborates}{2}, 'collaborates/2 arity exists');
    ok(exists $database->{skill}{2}, 'skill/2 arity exists');
    ok(exists $database->{Append}{3}, 'Append/3 arity exists');
    ok(exists $database->{Member}{2}, 'Member/2 arity exists');
    ok(exists $database->{Select}{3}, 'Select/3 arity exists');
    ok(exists $database->{Empty_list}{1}, 'Empty_list/1 arity exists');
    ok(exists $database->{List_length}{2}, 'List_length/2 arity exists');
};

subtest 'Test database facts and rules' => sub {
    my $database = AI::Logic::Database::get_database('AI::Logic::TestDatabase');
    
    # Test that facts are stored
    ok(@{$database->{developer}{1}{fact_or_rule}} > 0, 'developer/1 has facts');
    ok(@{$database->{designer}{1}{fact_or_rule}} > 0, 'designer/1 has facts');
    ok(@{$database->{manager}{1}{fact_or_rule}} > 0, 'manager/1 has facts');
    ok(@{$database->{works_on}{2}{fact_or_rule}} > 0, 'works_on/2 has facts');
    ok(@{$database->{skill}{2}{fact_or_rule}} > 0, 'skill/2 has facts');
    
    # Test that derived predicates have rules
    ok(@{$database->{team_lead}{1}{fact_or_rule}} > 0, 'team_lead/1 has rules');
    ok(@{$database->{work_together}{2}{fact_or_rule}} > 0, 'work_together/2 has rules');
    
    # Test that list predicates are defined but have no facts/rules yet
    is(@{$database->{Append}{3}{fact_or_rule}}, 0, 'Append/3 has no facts/rules yet');
    is(@{$database->{Member}{2}{fact_or_rule}}, 0, 'Member/2 has no facts/rules yet');
    is(@{$database->{Select}{3}{fact_or_rule}}, 0, 'Select/3 has no facts/rules yet');
    is(@{$database->{Empty_list}{1}{fact_or_rule}}, 0, 'Empty_list/1 has no facts/rules yet');
    is(@{$database->{List_length}{2}{fact_or_rule}}, 0, 'List_length/2 has no facts/rules yet');
};

subtest 'Test mixed predicates can coexist' => sub {
    my $database = AI::Logic::Database::get_database('AI::Logic::TestDatabase');
    
    # Verify that both team and list predicates exist in the same database
    my $has_team = exists $database->{developer} && exists $database->{works_on};
    my $has_list = exists $database->{Append} && exists $database->{Member};
    
    ok($has_team, 'Database contains team predicates');
    ok($has_list, 'Database contains list predicates');
    ok($has_team && $has_list, 'Database contains both team and list predicates');
    
    # Test that unifiers exist for all predicates
    ok(exists $database->{developer}{unifier}, 'developer has unifier');
    ok(exists $database->{Append}{unifier}, 'Append has unifier');
    
    # Test that the unifiers are code references
    isa_ok($database->{developer}{unifier}, 'CODE', 'developer unifier is code');
    isa_ok($database->{Append}{unifier}, 'CODE', 'Append unifier is code');
};

done_testing();
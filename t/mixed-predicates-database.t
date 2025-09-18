#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';

subtest 'Mixed predicates database setup' => sub {
    # Define a test database package with both regular and list predicates
    {
        package MixedDatabase;
        use AI::Logic::Database
            variables => [qw(Person X Y Z List Head Tail Rest Length Project Skill)],
            predicates => [qw(
                developer/1
                designer/1
                manager/1
                works_on/2
                skill/2
                team_member/2
                mentor/2
                Append/3
                Member/2
                Select/3
                Empty_list/1
                List_length/2
            )];
        
        # Regular predicates - team relationships
        developer { 'yuki' };
        developer { 'adeyemi' };
        developer { 'priya' };
        designer { 'kenji' };
        designer { 'zara' };
        manager { 'amara' };
        
        works_on { 'yuki', 'web_app' };
        works_on { 'adeyemi', 'mobile_app' };
        
        skill { 'yuki', 'javascript' };
        skill { 'adeyemi', 'python' };
        
        # List predicates - will be implemented in later tasks
        # For now, just verify the predicates are defined and callable
        
        # Test that we can call empty_list/1 (will be implemented later)
        # empty_list { Var([]) };
        
        # Test that we can define length/2 (will be implemented later)  
        # length { Var([]), 0 };
    }
    
    # Test that the database was created successfully
    my $database = AI::Logic::Database::get_database('MixedDatabase');
    ok($database, 'Mixed database was created');
    
    # Test that regular predicates are defined
    ok(exists $database->{developer}, 'developer predicate exists');
    ok(exists $database->{designer}, 'designer predicate exists');
    ok(exists $database->{manager}, 'manager predicate exists');
    ok(exists $database->{works_on}, 'works_on predicate exists');
    ok(exists $database->{skill}, 'skill predicate exists');
    
    # Test that list predicates are defined
    ok(exists $database->{Append}, 'Append predicate exists');
    ok(exists $database->{Member}, 'Member predicate exists');
    ok(exists $database->{Select}, 'Select predicate exists');
    ok(exists $database->{Empty_list}, 'Empty_list predicate exists');
    ok(exists $database->{List_length}, 'List_length predicate exists');
    
    # Test arity definitions
    ok(exists $database->{developer}{1}, 'developer/1 arity defined');
    ok(exists $database->{designer}{1}, 'designer/1 arity defined');
    ok(exists $database->{manager}{1}, 'manager/1 arity defined');
    ok(exists $database->{works_on}{2}, 'works_on/2 arity defined');
    ok(exists $database->{skill}{2}, 'skill/2 arity defined');
    ok(exists $database->{Append}{3}, 'Append/3 arity defined');
    ok(exists $database->{Member}{2}, 'Member/2 arity defined');
    ok(exists $database->{Select}{3}, 'Select/3 arity defined');
    ok(exists $database->{Empty_list}{1}, 'Empty_list/1 arity defined');
    ok(exists $database->{List_length}{2}, 'List_length/2 arity defined');
};

subtest 'Regular predicates work alongside list predicate definitions' => sub {
    # Import the mixed database
    use AI::Logic 'MixedDatabase';
    
    # Test regular predicates work
    my @developers;
    my $dev_var = Var;
    developer($dev_var, sub { push @developers, $dev_var->value });
    is_deeply([sort @developers], [sort qw(yuki adeyemi priya)], 'developer/1 predicate works');
    
    my @designers;
    my $designer_var = Var;
    designer($designer_var, sub { push @designers, $designer_var->value });
    is_deeply([sort @designers], [sort qw(kenji zara)], 'designer/1 predicate works');
    
    my @assignments;
    my $person_var = Var;
    my $project_var = Var;
    works_on($person_var, $project_var, sub { 
        push @assignments, [$person_var->value, $project_var->value] 
    });
    is_deeply([sort { $a->[0] cmp $b->[0] } @assignments], 
              [sort { $a->[0] cmp $b->[0] } (['yuki', 'web_app'], ['adeyemi', 'mobile_app'])], 
              'works_on/2 predicate works');
    
    my @skills;
    my $skill_person = Var;
    my $skill_name = Var;
    skill($skill_person, $skill_name, sub {
        push @skills, [$skill_person->value, $skill_name->value]
    });
    is_deeply([sort { $a->[0] cmp $b->[0] } @skills],
              [sort { $a->[0] cmp $b->[0] } (['yuki', 'javascript'], ['adeyemi', 'python'])],
              'skill/2 predicate works');
};

subtest 'List predicates are callable but not yet implemented' => sub {
    use AI::Logic 'MixedDatabase';
    
    # Test that list predicates can be called (they should fail gracefully since not implemented)
    my $called_append = 0;
    my $called_member = 0;
    my $called_select = 0;
    my $called_empty_list = 0;
    my $called_length = 0;
    
    # These should not crash, but may not succeed since rules aren't implemented yet
    eval {
        Append(Var([]), Var([1, 2]), Var([1, 2]), sub { $called_append = 1 });
    };
    ok(!$@, 'Append/3 can be called without crashing');
    
    eval {
        Member(Var(1), Var([1, 2, 3]), sub { $called_member = 1 });
    };
    ok(!$@, 'Member/2 can be called without crashing');
    
    eval {
        Select(Var(1), Var([1, 2, 3]), Var([2, 3]), sub { $called_select = 1 });
    };
    ok(!$@, 'Select/3 can be called without crashing');
    
    eval {
        Empty_list(Var([]), sub { $called_empty_list = 1 });
    };
    ok(!$@, 'Empty_list/1 can be called without crashing');
    
    eval {
        List_length(Var([1, 2, 3]), Var(3), sub { $called_length = 1 });
    };
    ok(!$@, 'List_length/2 can be called without crashing');
};

subtest 'Mixed database supports both regular and list variables' => sub {
    # Test variable creation within the database package context
    {
        package MixedDatabase;
        
        # Test that we can create both regular variables and list variables
        my $person_var = Person;
        my $list_var = Var([1, 2, 3]);
        my $empty_list_var = Var([]);
        my $regular_var = Var('test');
        my $any_var = Any();
        
        ::isa_ok($person_var, 'AI::Logic::Var::Named', 'Named variable works');
        ::isa_ok($list_var, 'AI::Logic::List', 'List variable works');
        ::isa_ok($empty_list_var, 'AI::Logic::List', 'Empty list variable works');
        ::isa_ok($regular_var, 'AI::Logic::Var', 'Regular variable works');
        ::isa_ok($any_var, 'AI::Logic::Var::Any', 'Any variable works');
        
        # Test list properties
        ::is($list_var->head(), 1, 'List variable has correct head');
        ::is($list_var->tail()->head(), 2, 'List variable has correct tail head');
        ::ok($empty_list_var->is_empty(), 'Empty list variable is empty');
        
        # Test regular variable properties
        ::is($regular_var->value(), 'test', 'Regular variable has correct value');
        ::is($person_var->name(), 'Person', 'Named variable has correct name');
    }
};

done_testing();
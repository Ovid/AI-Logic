#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Load modules
use lib 'lib';

# Load the test database module first to create the database
use lib 't/lib';
use AI::Logic::TestDatabase;

# Import the test database to use its predicates
use AI::Logic 'AI::Logic::TestDatabase';

subtest 'Team predicates work correctly' => sub {
    # Test developer/1 predicate
    my @developers;
    my $dev_var = Var();
    developer($dev_var, sub { push @developers, $dev_var->value });
    is_deeply([sort @developers], [sort qw(yuki adeyemi priya carlos fatima erik aisha dmitri)], 
              'All developers found correctly');
    
    # Test designer/1 predicate
    my @designers;
    my $designer_var = Var();
    designer($designer_var, sub { push @designers, $designer_var->value });
    is_deeply([sort @designers], [sort qw(kenji zara maya)], 
              'All designers found correctly');
    
    # Test manager/1 predicate
    my @managers;
    my $manager_var = Var();
    manager($manager_var, sub { push @managers, $manager_var->value });
    is_deeply([sort @managers], [sort qw(amara hassan ling)], 
              'All managers found correctly');
    
    # Test works_on/2 predicate
    my @work_assignments;
    my $person_var = Var();
    my $project_var = Var();
    works_on($person_var, $project_var, sub {
        push @work_assignments, [$person_var->value, $project_var->value];
    });
    is_deeply([sort { $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] } @work_assignments],
              [sort { $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] } (
                  ['yuki', 'web_app'],
                  ['adeyemi', 'mobile_app'],
                  ['priya', 'api_service'],
                  ['carlos', 'data_pipeline'],
                  ['fatima', 'web_app'],
                  ['erik', 'mobile_app']
              )],
              'All work assignments found correctly');
    
    # Test mentor/2 predicate
    my @mentoring;
    my $mentor_var = Var();
    my $mentee_var = Var();
    mentor($mentor_var, $mentee_var, sub {
        push @mentoring, [$mentor_var->value, $mentee_var->value];
    });
    is_deeply([sort { $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] } @mentoring],
              [sort { $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] } (
                  ['carlos', 'yuki'],
                  ['fatima', 'adeyemi'],
                  ['erik', 'priya'],
                  ['amara', 'kenji']
              )],
              'All mentoring relationships found correctly');
    
    # Test skill/2 predicate
    my @skills;
    my $skill_person = Var();
    my $skill_name = Var();
    skill($skill_person, $skill_name, sub {
        push @skills, [$skill_person->value, $skill_name->value];
    });
    ok(@skills > 0, 'Skills found correctly');
    
    # Check specific skill
    my $yuki_has_js = 0;
    skill(Var('yuki'), Var('javascript'), sub { $yuki_has_js = 1 });
    ok($yuki_has_js, 'Yuki has JavaScript skill');
};

subtest 'List predicates are callable but not implemented' => sub {
    # Test that list predicates can be called without crashing
    # They won't succeed since they have no rules/facts yet
    
    my $success_count = 0;
    
    eval {
        Append(Var([]), Var([1, 2]), Var([1, 2]), sub { $success_count++ });
    };
    ok(!$@, 'Append/3 call does not crash');
    
    eval {
        Member(Var(1), Var([1, 2, 3]), sub { $success_count++ });
    };
    ok(!$@, 'Member/2 call does not crash');
    
    eval {
        Select(Var(1), Var([1, 2, 3]), Var([2, 3]), sub { $success_count++ });
    };
    ok(!$@, 'Select/3 call does not crash');
    
    eval {
        Empty_list(Var([]), sub { $success_count++ });
    };
    ok(!$@, 'Empty_list/1 call does not crash');
    
    eval {
        List_length(Var([1, 2, 3]), Var(3), sub { $success_count++ });
    };
    ok(!$@, 'List_length/2 call does not crash');
    
    # Since no rules are implemented, success_count should be 0
    is($success_count, 0, 'List predicates do not succeed (no rules implemented yet)');
};

subtest 'Mixed variable types work together' => sub {
    # Test that we can create and use different variable types
    my $person = Var('yuki');
    my $list_of_names = Var(['yuki', 'adeyemi', 'priya']);
    my $empty_list = Var([]);
    
    # Verify the person is a developer
    my $is_developer = 0;
    developer($person, sub { $is_developer = 1 });
    ok($is_developer, 'Yuki is correctly identified as developer');
    
    # Test list variable properties
    isa_ok($list_of_names, 'AI::Logic::List', 'List of names is a List object');
    is($list_of_names->head(), 'yuki', 'List head is correct');
    is($list_of_names->tail()->head(), 'adeyemi', 'List tail head is correct');
    
    isa_ok($empty_list, 'AI::Logic::List', 'Empty list is a List object');
    ok($empty_list->is_empty(), 'Empty list is correctly empty');
    
    # Test that we can create variables of different types
    my $any_var = Any();
    my $bound_var = Var('test');
    my $unbound_var = Var();
    
    isa_ok($any_var, 'AI::Logic::Var::Any', 'Any variable created correctly');
    isa_ok($bound_var, 'AI::Logic::Var', 'Bound variable created correctly');
    isa_ok($unbound_var, 'AI::Logic::Var', 'Unbound variable created correctly');
    
    is($bound_var->value(), 'test', 'Bound variable has correct value');
    ok(!$unbound_var->is_bound(), 'Unbound variable is not bound');
};

subtest 'Database supports both team and list predicate queries' => sub {
    # Test that we can query both types of predicates in the same session
    
    # Query team predicates
    my $yuki_is_developer = 0;
    developer(Var('yuki'), sub { $yuki_is_developer = 1 });
    ok($yuki_is_developer, 'Can query team predicates');
    
    # Attempt to query list predicates (they should be callable but not succeed)
    my $append_called = 0;
    eval {
        Append(Var([]), Var([1]), Var([1]), sub { $append_called = 1 });
    };
    ok(!$@, 'Can call list predicates without error');
    is($append_called, 0, 'List predicates do not succeed (no implementation yet)');
    
    # Test that both types of predicates exist in the same namespace
    ok(defined &developer, 'Team predicate function exists');
    ok(defined &Append, 'List predicate function exists');
    ok(defined &Var, 'Var constructor exists');
    ok(defined &Any, 'Any constructor exists');
    # Note: Named variables like Person are only available within the database package
};

done_testing();
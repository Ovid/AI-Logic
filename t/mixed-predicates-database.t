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
            variables => [qw(Person X Y Z List Head Tail Rest Length)],
            predicates => [qw(
                male/1
                female/1
                married/2
                parent/2
                Append/3
                Member/2
                Select/3
                Empty_list/1
                Length/2
            )];
        
        # Regular predicates - family relationships
        male { 'frank' };
        male { 'barney' };
        male { 'timothy' };
        female { 'sarah' };
        female { 'leila' };
        female { 'samantha' };
        
        married { 'frank', 'sarah' };
        married { 'barney', 'leila' };
        
        parent { 'frank', 'timothy' };
        parent { 'sarah', 'timothy' };
        
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
    ok(exists $database->{male}, 'male predicate exists');
    ok(exists $database->{female}, 'female predicate exists');
    ok(exists $database->{married}, 'married predicate exists');
    ok(exists $database->{parent}, 'parent predicate exists');
    
    # Test that list predicates are defined
    ok(exists $database->{Append}, 'Append predicate exists');
    ok(exists $database->{Member}, 'Member predicate exists');
    ok(exists $database->{Select}, 'Select predicate exists');
    ok(exists $database->{Empty_list}, 'Empty_list predicate exists');
    ok(exists $database->{Length}, 'Length predicate exists');
    
    # Test arity definitions
    ok(exists $database->{male}{1}, 'male/1 arity defined');
    ok(exists $database->{female}{1}, 'female/1 arity defined');
    ok(exists $database->{married}{2}, 'married/2 arity defined');
    ok(exists $database->{parent}{2}, 'parent/2 arity defined');
    ok(exists $database->{Append}{3}, 'Append/3 arity defined');
    ok(exists $database->{Member}{2}, 'Member/2 arity defined');
    ok(exists $database->{Select}{3}, 'Select/3 arity defined');
    ok(exists $database->{Empty_list}{1}, 'Empty_list/1 arity defined');
    ok(exists $database->{Length}{2}, 'Length/2 arity defined');
};

subtest 'Regular predicates work alongside list predicate definitions' => sub {
    # Import the mixed database
    use AI::Logic 'MixedDatabase';
    
    # Test regular predicates work
    my @males;
    my $male_var = Var;
    male($male_var, sub { push @males, $male_var->value });
    is_deeply([sort @males], [sort qw(frank barney timothy)], 'male/1 predicate works');
    
    my @females;
    my $female_var = Var;
    female($female_var, sub { push @females, $female_var->value });
    is_deeply([sort @females], [sort qw(sarah leila samantha)], 'female/1 predicate works');
    
    my @couples;
    my $husband = Var;
    my $wife = Var;
    married($husband, $wife, sub { 
        push @couples, [$husband->value, $wife->value] 
    });
    is_deeply([sort { $a->[0] cmp $b->[0] } @couples], 
              [sort { $a->[0] cmp $b->[0] } (['frank', 'sarah'], ['barney', 'leila'])], 
              'married/2 predicate works');
    
    my @parents;
    my $parent_var = Var;
    my $child_var = Var;
    parent($parent_var, $child_var, sub {
        push @parents, [$parent_var->value, $child_var->value]
    });
    is_deeply([sort { $a->[0] cmp $b->[0] } @parents],
              [sort { $a->[0] cmp $b->[0] } (['frank', 'timothy'], ['sarah', 'timothy'])],
              'parent/2 predicate works');
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
        Length(Var([1, 2, 3]), Var(3), sub { $called_length = 1 });
    };
    ok(!$@, 'Length/2 can be called without crashing');
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
package AI::Logic::TestDatabase;

use AI::Logic::Database
    variables => [qw(Person X Y Z List Head Tail Rest Length Item)],
    predicates => [qw(
        male/1
        female/1
        married/2
        parent/2
        child/2
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
male { 'sam' };

female { 'sarah' };
female { 'leila' };
female { 'samantha' };
female { 'betty' };

married { 'frank', 'sarah' };
married { 'barney', 'betty' };
married { 'sam', 'samantha' };

parent { 'frank', 'timothy' };
parent { 'sarah', 'timothy' };
parent { 'barney', 'sam' };
parent { 'betty', 'sam' };

# Define child relationship as inverse of parent
Rule {
    child { X, Y } => parent { Y, X };
};

# List predicates will be implemented in subsequent tasks
# For now they are just defined as callable predicates

1;
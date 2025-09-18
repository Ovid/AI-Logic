package AI::Logic::List;

use v5.40.0;

our $VERSION = '0.01';

=head1 NAME

AI::Logic::List - Prolog-style list support for AI::Logic

=head1 SYNOPSIS

    use AI::Logic::List;
    
    # Create empty list
    my $empty = AI::Logic::List->new();
    
    # Create list with elements
    my $list = AI::Logic::List->cons('a', 
                   AI::Logic::List->cons('b', 
                       AI::Logic::List->new()));
    
    # Access list elements
    my $head = $list->head();  # 'a'
    my $tail = $list->tail();  # list containing 'b'
    
    # Check if empty
    if ($list->is_empty()) {
        print "List is empty\n";
    }

=head1 DESCRIPTION

AI::Logic::List implements Prolog-style lists using head/tail structure
that integrates with the AI::Logic unification and variable binding system.

=head1 METHODS

=head2 new($head, $tail)

Constructor for creating list objects. Called with no arguments creates
an empty list. Called with head and tail creates a non-empty list.

    my $empty = AI::Logic::List->new();
    my $list = AI::Logic::List->new('head', $tail_list);

=cut

sub new ($class, $head = undef, $tail = undef) {
    # Empty list if no head provided
    if (!defined $head) {
        return bless { head => undef, tail => undef }, $class;
    }
    
    # Non-empty list with head and tail
    return bless { 
        head => $head, 
        tail => $tail 
    }, $class;
}

=head2 head()

Returns the head (first element) of the list. Returns undef for empty lists.

    my $head = $list->head();

=cut

sub head ($self) {
    return $self->{head};
}

=head2 tail()

Returns the tail (rest of the list) of the list. Returns undef for empty lists.

    my $tail = $list->tail();

=cut

sub tail ($self) {
    return $self->{tail};
}

=head2 is_empty()

Returns true if the list is empty (both head and tail are undefined).

    if ($list->is_empty()) {
        print "Empty list\n";
    }

=cut

sub is_empty ($self) {
    return !defined($self->{head}) && !defined($self->{tail});
}

=head2 cons($head, $tail)

Class method for constructing lists in a functional style. If no tail
is provided, creates a list with the given head and an empty tail.

    my $list = AI::Logic::List->cons('a', $existing_list);
    my $single = AI::Logic::List->cons('a');  # Single element list

=cut

sub cons ($class, $head, $tail = undef) {
    # If no tail provided, use empty list
    $tail = $class->new() unless defined $tail;
    
    return $class->new($head, $tail);
}

=head1 AUTHOR

AI::Logic::List - Part of the AI::Logic system

=head1 COPYRIGHT AND LICENSE

This is alpha-quality code. Use at your own risk.

=cut

1;
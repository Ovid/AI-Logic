package AI::Logic::Var;

use v5.40.0;
use AI::Logic::List;

use base 'Exporter';
our @EXPORT_OK = qw(
    Var
);
@AI::Logic::Var::Any::ISA = 'AI::Logic::Var';

=head1 NAME

AI::Logic::Var - Logic variables

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use AI::Logic::Var 'Var';

    my $any    = Var;
    my $car    = Var('volkswagon');
    my $cheese = Var 'Hasselhoff';
    
    # Create lists using array references
    my $empty_list = Var([]);
    my $colors = Var([qw/ red green blue /]);
    my $nested = Var([1, [2, 3], 4]);

=head1 FUNCTIONS

To be defined later

=over 4

=item * C<Var>

=item * C<new>

=item * C<bind>

=item * C<unbind>

=item * C<equals>

=item * C<is_bound>

=item * C<value>

=back

=cut 

sub Var ($value = undef) {
    
    # Convert array references to AI::Logic::List objects and return directly
    if (defined $value && ref($value) eq 'ARRAY') {
        return _array_to_list($value);
    }
    
    return __PACKAGE__->new($value);
}

=head2 _array_to_list

Helper function to convert Perl array references to AI::Logic::List objects.
Converts [1, 2, 3] to a proper head/tail list structure.

=cut

sub _array_to_list ($array_ref) {
    
    # Empty array becomes empty list
    return AI::Logic::List->new() if @$array_ref == 0;
    
    # Build list from right to left (tail to head)
    my $list = AI::Logic::List->new();
    for my $element (reverse @$array_ref) {
        # Recursively convert nested arrays
        if (ref($element) eq 'ARRAY') {
            $element = _array_to_list($element);
        }
        $list = AI::Logic::List->cons($element, $list);
    }
    
    return $list;
}

{
    package AI::Logic::Var::Named;
    our @ISA = 'AI::Logic::Var';
    sub new ($class, $value, $name) {
        bless [ $value, $name ] => $class;
    }
    
    sub name ($self) { $self->[1] }
}

sub new ($class, $value = undef) {
    bless [$value] => $class;
}

sub is_bound ($self) { defined $self->[0] }

sub value ($self) { return $self->[0] }

sub equals ($v1, $v2) {
    $v1 eq $v2 || $v1->is_bound && $v2->is_bound && $v1->value eq $v2->value;
}

sub bind ($v1, $v2) {
    return if $v1->is_bound;
    $v1->[0] = $v2->[0];
    return 1;
}

sub unbind ($self) { $self->[0] = undef; }

=head1 AUTHOR

Curtis "Ovid" Poe, C<< <ovid at cpan.org> >>

Based on the excellent "Perl and Prolog and Continuations... oh my!" by Adrian
Howard.  L<http://www.perlmonks.org/index.pl?node_id=193649>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ai-logic at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=AI-Logic>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AI::Logic::Var


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=AI-Logic>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/AI-Logic>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/AI-Logic>

=item * Search CPAN

L<http://search.cpan.org/dist/AI-Logic/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Curtis "Ovid" Poe, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;    # End of AI::Logic::Var

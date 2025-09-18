package AI::Logic::Unification;

use v5.40.0;

use AI::Logic::Var 'Var';

use base 'Exporter';
our @EXPORT_OK = qw(
    unify
    unify_all
);
our %EXPORT_TAGS = (
    all => \@EXPORT_OK,
);

=head1 NAME

AI::Logic::Unification - Logic unification

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 EXPORT

All functions are exportable on demand, or with the tag ':all'.

=head1 FUNCTIONS

=head2 unify

=cut

sub unify {
    my ( $v1, $v2, $continuation ) = @_;

    # Check for direct list unification before converting to Var objects
    if (_both_lists($v1, $v2)) {
        return _unify_lists($v1, $v2, $continuation);
    }

    # Handle variable-to-list binding
    if ($v1 isa 'AI::Logic::Var' && _is_list($v2)) {
        if (!$v1->is_bound) {
            $v1->[0] = $v2;  # Bind variable directly to list
            $continuation->();
            $v1->unbind;
            return;
        }
    }
    
    if ($v2 isa 'AI::Logic::Var' && _is_list($v1)) {
        if (!$v2->is_bound) {
            $v2->[0] = $v1;  # Bind variable directly to list
            $continuation->();
            $v2->unbind;
            return;
        }
    }

    $v1 = Var $v1 unless $v1 isa 'AI::Logic::Var';
    $v2 = Var $v2 unless $v2 isa 'AI::Logic::Var';
    
    if ( $v1->equals($v2) ) {
        $continuation->();
    }
    elsif ( $v1->bind($v2) ) {
        $continuation->();
        $v1->unbind;
    }
    elsif ( $v2->bind($v1) ) {
        $continuation->();
        $v2->unbind;
    }
    else {
        # ???
    }
    return;
}

=head2 unify_all

=cut

sub unify_all {
    my ( $a, $b, $continuation ) = @_;
    if ( @$a == 0 && @$b == 0 ) {
        $continuation->();
    }
    elsif ( @$a == @$b ) {
        my ( $v1, $v2 ) = ( shift @$a, shift @$b );
        unify( $v1, $v2, sub { unify_all( $a, $b, $continuation ) } );
        unshift @$a, $v1;
        unshift @$b, $v2;
    }
    return (0);
}

=head2 _is_list

Helper function to check if a value is a list object.

=cut

sub _is_list {
    my ($value) = @_;
    return $value isa 'AI::Logic::List';
}

=head2 _both_lists

Helper function to check if both values are list objects.

=cut

sub _both_lists {
    my ($v1, $v2) = @_;
    return _is_list($v1) && _is_list($v2);
}

=head2 _unify_lists

Recursive list unification function. Handles unification of two list objects
by comparing their structure and recursively unifying heads and tails.

=cut

sub _unify_lists {
    my ($list1, $list2, $continuation) = @_;
    
    # Both empty lists unify successfully
    if ($list1->is_empty && $list2->is_empty) {
        return $continuation->();
    }
    
    # One empty, one not - unification fails
    if ($list1->is_empty || $list2->is_empty) {
        return;
    }
    
    # Both non-empty: unify heads, then tails
    unify($list1->head, $list2->head, sub {
        unify($list1->tail, $list2->tail, $continuation);
    });
    
    return;
}


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

    perldoc AI::Logic::Unification


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

Adrian Howard inspired this.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Curtis "Ovid" Poe, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;    # End of AI::Logic::Unification

package AI::Logic::Unification;

use warnings;
use strict;

use aliased 'AI::Logic::Var';

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

    $v1 = Var->new($v1) unless UNIVERSAL::isa( $v1, Var );
    $v2 = Var->new($v2) unless UNIVERSAL::isa( $v2, Var );
    if ( $v1->equal($v2) ) {
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

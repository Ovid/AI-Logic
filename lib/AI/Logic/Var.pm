package AI::Logic::Var;

use warnings;
use strict;

use base 'Exporter';
our @EXPORT_OK = qw(
    Var
);

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

=head1 FUNCTIONS

To be defined later

=over 4

=item * C<Var>

=item * C<new>

=item * C<bind>

=item * C<unbind>

=item * C<equal>

=item * C<bound>

=item * C<value>

=back

=cut 

sub Var (;$) {
    my $value = shift;
    return return __PACKAGE__->new($value);
}

sub new {
    my ( $class, $value ) = @_;
    bless \\$value, $class;
}

sub bound {
    my $self = shift;
    defined $$$self;
}

sub value {
    my $self = shift;
    return ($$$self);
}

sub equal {
    my ( $v1, $v2 ) = @_;
    $v1 eq $v2 || $v1->bound && $v2->bound && $v1->value eq $v2->value;
}

sub bind {
    my ( $v1, $v2 ) = @_;
    return (0) if $v1->bound;
    $$v1 = $$v2;
    return (1);
}

sub unbind {
    my $self = shift;
    $$self = \undef;
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

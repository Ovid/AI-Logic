package AI::Logic;

use warnings;
use strict;

use Carp 'croak';

use AI::Logic::Database ();

=head1 NAME

AI::Logic - Continuation based logic programming.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 EXPORT

=cut

sub import {
    my ( $class, $database_class ) = @_;
    my $database = AI::Logic::Database::get_database($database_class);

    my $callpack = caller(0);
    while ( my ( $name, $definition ) = each %$database ) {
        no strict 'refs';
        *{"$callpack\::$name"} = $definition->{unifier};
        *{"$callpack\::Any"}   = sub () { AI::Logic::Var::Any->new };
        *{"$callpack\::Var"}   = *AI::Logic::Var::Var{CODE};
    }
}

=head1 AUTHOR

Curtis "Ovid" Poe, C<< <ovid at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ai-logic at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=AI-Logic>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AI::Logic

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

1;    # End of AI::Logic

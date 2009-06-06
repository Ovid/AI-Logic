#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Sortkeys = 1;

{

    package My::Database;
    use AI::Logic::Database predicates => [
        qw{
          male/1
          female/1
          acts/1
          actor/1
          actress/1
          },
      ],
      variables => ['Person'];
    male { 'frank' };
    male { 'barney' };
    male { 'timothy' };
    male { 'ovid' };
    male { 'Sam' };
    female { 'Sarah' };
    acts { 'timothy' };
    acts { 'barney' };
    acts { 'Sarah' };
    Rule {
        actor { Person } => acts { Person },
          male { Person };
    };
    Rule {
        actress { Person } => acts { Person },
          female { Person };
    };
}

use AI::Logic 'My::Database';

my @names;
foreach my $name (qw/frank judy barney/) {
    male( $name, sub { push @names => $name; } );
}
print Dumper \@names;
my $male = Var;
male( $male, sub { print $male->value .' is a male'.$/ } );

my $actor = Var;
actor( $actor, sub { print $actor->value . ' is an actor', $/ } );

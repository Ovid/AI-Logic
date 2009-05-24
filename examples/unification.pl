#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Sortkeys = 1;

{

    package My::Database;
    use AI::Logic::Database
      predicates => [
        qw{
          male/1
          acts/1
          actor/2
          }
      ];
    male('frank');
    male('barney');
    male('timothy');
    male('ovid');
    male('Sam');
}

use AI::Logic 'My::Database';
use AI::Logic::Var 'Var';

my @names;
foreach my $name (qw/frank judy barney/) {
    male( $name, sub { push @names => $name;} );
}
print Dumper \@names;
my $male = Var;
male ($male, sub { print $male->value, $/ });

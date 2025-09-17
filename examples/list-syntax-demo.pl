#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';

use AI::Logic::Var 'Var';
use AI::Logic::Unification 'unify';

print "AI::Logic List Creation Demo\n";
print "============================\n\n";

# Old syntax (still works)
print "Old syntax:\n";
print "  my \$list = AI::Logic::List->cons('a', AI::Logic::List->cons('b', AI::Logic::List->new()));\n\n";

# New syntax
print "New syntax:\n";
print "  my \$list = Var(['a', 'b']);\n\n";

# Demonstrate the new syntax
my $empty = Var([]);
my $colors = Var([qw/ red green blue /]);
my $nested = Var([1, [2, 3], 4]);

print "Examples:\n";
print "---------\n";
print "Empty list: Var([])\n";
print "  -> " . ($empty->is_empty() ? "empty list" : "not empty") . "\n\n";

print "Color list: Var([qw/ red green blue /])\n";
print "  -> head: " . $colors->head() . "\n";
print "  -> second: " . $colors->tail()->head() . "\n";
print "  -> third: " . $colors->tail()->tail()->head() . "\n\n";

print "Nested list: Var([1, [2, 3], 4])\n";
print "  -> first: " . $nested->head() . "\n";
print "  -> second (nested): [" . 
      $nested->tail()->head()->head() . ", " . 
      $nested->tail()->head()->tail()->head() . "]\n";
print "  -> third: " . $nested->tail()->tail()->head() . "\n\n";

# Demonstrate unification
print "Unification example:\n";
print "--------------------\n";
my $list1 = Var(['a', 'b']);
my $list2 = Var(['a', 'b']);
my $list3 = Var(['a', 'c']);

my $unified = 0;
unify($list1, $list2, sub { $unified = 1 });
print "Var(['a', 'b']) unifies with Var(['a', 'b']): " . ($unified ? "YES" : "NO") . "\n";

$unified = 0;
unify($list1, $list3, sub { $unified = 1 });
print "Var(['a', 'b']) unifies with Var(['a', 'c']): " . ($unified ? "YES" : "NO") . "\n";

print "\nThis makes list creation much more intuitive!\n";
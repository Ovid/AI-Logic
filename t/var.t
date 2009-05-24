#!/usr/bin/env perl

use strict;
use warnings;

use Test::More 'no_plan';

use aliased 'AI::Logic::Var';

my $v1 = Var->new;
my $v2 = Var->new("hello");
my $v3 = Var->new;
my $v4 = Var->new("hello");

isa_ok $v1, Var, 'new unbound var';
ok !$v1->bound, '  is not bound';
is $v1->value, undef, '  and undefined';

isa_ok $v2, Var, 'new bound var';
ok $v2->bound, '  is bound';
is $v2->value, "hello", '  to correct value';

ok $v1->equal($v1), 'var equal to itself';
ok !$v1->equal($v3), 'unbound var not equal to other unbound var';
ok $v2->equal($v4), 'bound vars with same content equal';

ok !$v2->bind($v1), 'cannot bind bound var';
ok $v1->bind($v2), 'can bind unbound var';
is $v1->value, "hello", '  to correct value';

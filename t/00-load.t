#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'AI::Logic' );
}

diag( "Testing AI::Logic $AI::Logic::VERSION, Perl $], $^X" );

#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'File::Attribute' );
}

diag( "Testing File::Attribute $File::Attribute::VERSION, Perl $], $^X" );

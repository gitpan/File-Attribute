#!/usr/bin/perl

use Test::More tests=>20;
use File::Attribute;

for(qw(1 1/2 1/2/3 1/2/3/4 1/2/3/4/file)){
    is( read_attribute( { attribute => "global",
			  top => "t/tests",
			  path => "t/tests/$_" }),
	"exists",
	"reading global for $_");
}

for(qw(global one two three four five)){
    is( read_attribute( { attribute => $_,
			  top => "t/tests",
			  path => "t/tests/1/2/3/4/file" }),
	"exists",
	"reading $_ for 1/2/3/4/file");
}

for(qw(global one two three)){
    is( read_attribute( { attribute => $_,
			  top => "t/tests",
			  path => "t/tests/1/2/3/4"
			}),
	"exists",
	"reading $_ for 1/2/3/4");
}

# make sure top works
for(qw(1 1/2 1/2/3 1/2/3/4 1/2/3/4/file)){
    is( read_attribute( { attribute => "global",
			  top => "t/tests/1",
			  path => "t/tests/$_",
			}),
	undef,
	"reading global for $_ limited to t/tests/1");
}

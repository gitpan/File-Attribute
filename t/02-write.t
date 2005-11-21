#!/usr/bin/perl

use Test::More tests=>60;
use File::Attribute;

`rm -rf t/tests/write`; # get rid of stale data
mkdir "t/tests/write";
mkdir "t/tests/write/dir";
`touch t/tests/write/file`;
`touch t/tests/write/dir/file`;

my @names = 
  qw(0 1 2 3 4 5 aaa bbb ccc ddd eee fff ggg InterestingName .something .file .dir .file.dir ..file..dir ...);

my $something = "this is a test";
my $something_else = '日本語';

for my $attr (@names){
    for my $path (qw(dir/file dir file)){
	my @result;
	
	my $filename = write_attribute({path=>"t/tests/write/$path",
					attribute=>$attr},
				       $something, $something_else);
	
	@result = read_attribute({path=>"t/tests/write/$path",
				  top=>"t/tests/write",
				  attribute=>$attr});
	
    
	is_deeply(\@result, [$something, $something_else],
		  "read/write of $attr to $path");
	
    }
}

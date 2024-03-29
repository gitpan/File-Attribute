#!/usr/bin/perl

use Test::More tests=>60;
use File::Attribute;

eval {
    `rm -rf t/tests/write`; # get rid of stale data
};

mkdir "t/tests/write"    or die;
mkdir "t/tests/write/dir" or die;

# for windows users without touch installed (how can you use a
# computer without touch!?)

sub touch {
    open my $file, '>', $_[0] or die;
    print {$file} "\n";
    close $file;
}

touch("t/tests/write/file");
touch("t/tests/write/dir/file");

# cleanup complete

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

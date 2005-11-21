package File::Attribute;

use warnings;
use strict;
use Exporter;
use File::Slurp::SmallFile qw(slurp);

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(read_attribute write_attribute);
our @EXPORT = qw(read_attribute write_attribute);

=head1 NAME

File::Attribute - read and write file attributes

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

C<File::Attribute> lets you assign attributes to files.  This means
that you can easily set metadata for files.  Even better, the module
looks for attributes recursively.  It first checks for an attribute
applied to a certain file, then the directory, then the parent
directory, etc.  This lets you set information for many files in a
very efficient way.

An example should clarify this.

    use File::Attribute;

    my $lang = read_attribute({path=>"/path/to/a/file", 
                               attribute=>"language",
                               top=>"/path"});

Here, we read the "language" attribute for the file
C</path/to/a/file>.  This is accomplished by reading a file called
C</path/to/a/.file.language>.  If that file doesn't exist, the module
tries C</path/to/a/.language>, and then C</path/to/a/.language>, then
C</path/to/.language>, and finally, C</path/.language>.  C</.language>
is not tried because the search will not ascend above the (optional)
C<top> argument.

If C<read_attribute> encounters a blank file at any stage in the
serach, it will terminate the search and return nothing (even if a
non-blank file exists below the blank file that was found).

Writing is just as easy:

    use File::Attribute;

    write_attribute({path=>"/path/to/a/file",
                     attribute=>"language"},
                    "en_JP", "engrish");

In this example, we create an attribute called "language" that applies
to C</path/to/a/file>.  The attribute has two lines; one "en_JP" and
the next "engrish".  (My apologies to the Japanese.)  If C<path> is a
directory, the attribute will be a directory-scoped attribute
(i.e. applies to files in that directory, and files in all
subdirectories).

=head1 EXPORT

Both functions are exported by default.

=head2 read_attribute

=head2 write_attribute

=head1 FUNCTIONS

=head2 read_attribute

Reads an attribute, as per the decription in SYNOPSIS.

=head3 ARGUMENTS

Accepts a single hash reference.  Required in the hash are C<path>,
the path to the file, and C<attribute>, the name of the attribute to read.

Optionally, you may include C<top>, which limits the scope of the
search to all subdirectories of C<top>.  C<read_attribute> will C<die>
if C<path> is not below C<top>.  Creative symlinking is not accounted
for here -- if C</a> is a symlink to C</b/a>, then C</b> is not
"above" C</a>.  I would be very interested in hearing how this is a
problem for you :)

=head3 RETURN VALUE

In scalar context, returns the first non-blank line of the attribute
file (if one exists).  In list context, returns all non-blank lines.

=cut
my $END_OF_PATH = '(.*)/([^/]+)/?$';
        
sub read_attribute {
    my $arg_ref = shift;
    my $path = $arg_ref->{path} 
      || die "Required argument 'path' not specified.";
    my $attribute = $arg_ref->{attribute};
    die "Required argument 'attribute' not specified."
      unless defined $attribute;
    
    my $top = $arg_ref->{top} || "/";

    for($path,$top){
	s{(^/)[.]+(/$)}{}g; # eliminate /../ and /./
    }
    
    if(!defined $top){
	$top = (split(m(/),$path))[0];
    }
        
    die "$path does not exist" unless -e $path;
    
    if(!_contains($top,$path)){
	die "$top does not contain $path";
    }
    
    if($path !~ m($END_OF_PATH)){
	die "$path is not a valid UNIX path";
    }
    my ($file, $dir) = ($2, $1);
    
    ####print {*STDERR} "try .$file.$attribute in $dir\n";
    # first try .file.attribute
    if(-e "$dir/.$file.$attribute" && !-d $path){
	###print {*STDERR} "got it\n";
	return slurp("$dir/.$file.$attribute");
    }
    
    ####print {*STDERR} "try $path/.$attribute\n";
    # then try .attribute in the directory
    if( -d $path && -e "$path/.$attribute"){
	####print {*STDERR} "got it\n";
	return slurp("$path/.$attribute");
    }

    # now iterate over the directory structure
    while(_contains($top, $dir)){
	####print {*STDERR} "try .$attribute in $dir\n";

	if(-e "$dir/.$attribute"){
	    ####print {*STDERR} "got it\n";
	    return slurp("$dir/.$attribute");
	}
	
	$dir =~ s{$END_OF_PATH}{$1};
    }
    
    # not found
    return;
}

# does top contain path?
sub _contains {
    my $top = shift;
    my $path = shift;
    return (index($path, $top) == 0)
}

=head2 write_attribute

Writes an attribute file that can be read by C<read_attribute>.

=head3 ARGUMENTS

Accepts a hash reference followed by one or more lines to save in the
attribute file.

The hash must contain two elements, C<path>, and C<attribute>.  If
C<path> is a file, a file-scoped attribute is written.  If C<path> is
a directory, a directory-scoped attribute is written.

The remaining arguments are taken to be lines to be written to the
attribute file.

=head3 RETURN VALUE

Returns the filename of the attribute file.  Throws an exception on error.

=cut

sub write_attribute {
    my $arg_ref = shift;
    my $path = $arg_ref->{path}
      || die "Required argument 'path' not specified.";
    my $attribute = $arg_ref->{attribute};
    die "Required argument 'attribute' not specified."
      unless defined $attribute;
    
    my @data = @_;

    if(!-e $path){
	die "$path does not exist";
    }
    
    my $filename;
    if(-d $path){
	$filename = "$path/.$attribute";
    }
    else {
	$path =~ m($END_OF_PATH);
	my $dir = $1;
	my $file = $2;
	$filename = "$dir/.$file.$attribute";
    }
    
    open my $file, '>', "$filename.TMP" or die "Couldn't open $filename: $!";
    foreach(@data){
	print {$file} "$_\n" or die "Couldn't write data: $!";
    }
    close $file;

    rename "$filename.TMP", $filename 
      or die "Couldn't rename temp file $filename.TMP to $filename: $!";
    
    unlink "$filename.TMP";
    
    return $filename;
}

=head1 DIAGNOSTICS

=head2 Required argument C<foo> not specified.

The function required an argument named C<foo>, but you didn't supply it.

=head2 C<path> does not exist.

The path C<path> passed to the function does not exist.

=head2 C<path> is not a valid UNIX path.

You passed a path to the function that isn't valid.  (Probably a bug
in my code.)

=head2 C<top> does not contain C<path>

You passed C<read_attribute> a path that's not contained in C<top>.
That makes the specification of C<top> meaningless, which probably
isn't what you wanted.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-file-attribute@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-Attribute>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 AUTHOR

Jonathan T. Rockway, C<< <jon-cpan@jrock.us> >>

=head1 COPYRIGHT & LICENSE

Copyright 2005 Jonathan T. Rockway, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of File::Attribute

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'File::Attribute',
    AUTHOR              => 'Jonathan T. Rockway <jon-cpan@jrock.us>',
    VERSION_FROM        => 'lib/File/Attribute.pm',
    ABSTRACT_FROM       => 'lib/File/Attribute.pm',
    PL_FILES            => {},
    PREREQ_PM => {
		  'Exporter' => 0,
		  'File::Slurp::SmallFile' => 0,
		  'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'File-Attribute-*' },
);

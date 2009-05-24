use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'AI::Logic',
    license             => 'perl',
    dist_author         => 'Curtis "Ovid" Poe <ovid@cpan.org>',
    dist_version_from   => 'lib/AI/Logic.pm',
    build_requires => {
        'Test::Most' => 0.21,
        'aliased'    => 0.22,
    },
    add_to_cleanup      => [ 'AI-Logic-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();

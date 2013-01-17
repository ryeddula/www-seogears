use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::SEOGears',
    license             => 'perl',
    dist_author         => q{Rishwanth Yeddula <ryeddula@hostgator.com>},
    dist_version_from   => 'lib/WWW/SEOGears.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'URI::Escape'          => 0,
        'Date::Calc'           => 0,
        'LWP::Protocol::https' => 0,
        'LWP::UserAgent'       => 0,
        'HTTP::Request'        => 0,
        'JSON'                 => 0,
        'URI::Escape'          => 0,
    },
    add_to_cleanup     => [ 'WWW-SEOGears-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();

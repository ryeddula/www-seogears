use Test::More tests => 5;

BEGIN { use_ok ( 'WWW::SEOGears' ); }
require_ok ( 'WWW::SEOGears' );

my $api = WWW::SEOGears->new( { brandname => 'brandname',
                                brandkey  => '123456789ABCDEFG',
                                sandbox   => '1',
                                lwp       => {'parse_head' => 0, 'ssl_opts' => {'verify_hostname' => 0, 'SSL_verify_mode' => '0x00'}}
                              } );

ok ( defined ($api) && ref $api eq 'WWW::SEOGears', "API object creation" );
ok ( $api->get_brandname eq 'brandname',  "Brandname value");
ok ( $api->get_brandkey eq '123456789ABCDEFG', "Brandkey value");
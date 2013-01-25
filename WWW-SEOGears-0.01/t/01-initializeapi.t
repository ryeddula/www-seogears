use Test::More tests => 5;
use FindBin;
use lib $FindBin::Bin;
use CommonSubs;

BEGIN { use_ok ( 'WWW::SEOGears' ); }
require_ok ( 'WWW::SEOGears' );

my $api = CommonSubs::initiate_api();

ok ( defined ($api) && ref $api eq 'WWW::SEOGears', "API object creation" );
ok ( $api->get_brandname eq 'brandname',  "Brandname value");
ok ( $api->get_brandkey eq '123456789ABCDEFG', "Brandkey value");
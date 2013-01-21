package CommonSubs;

use WWW::SEOGears;

sub initiate_api {

	my $api = WWW::SEOGears->new( { brandname => 'brandname',
	                                brandkey  => '123456789ABCDEFG',
	                                sandbox   => '1',
	                                lwp       => {'parse_head' => 0, 'ssl_opts' => {'verify_hostname' => 0, 'SSL_verify_mode' => '0x00'}}
	                              } );

	return $api;
}

sub newuser {

	my $api        = shift;
	my $params     = shift;
	my $param_test = shift;

	if ($param_test) {
		delete $params->{'price'};
	}
	my $output = eval { $api->newuser($params); };
	return $output;
}

sub random_uid {

	my $limit    = 12;
	my $possible = 'abcdefghijkmnpqrstuvwxyz0123456789';
 	my $string   = '';
 	while (length($string) < $limit) {
 		$string .= substr( $possible, ( int( rand( length($possible) ) ) ), 1 );
 	}
 	return $string;
}

sub gen_rand_params {

	my $params = {};
	$params->{'userid'}    = random_uid();
	$params->{'name'}      = 'Hostgator testing';
	$params->{'email'}     = random_uid().'@hostgatortesting.com';
	$params->{'phone'}     = '1.5552223333';
	$params->{'domain'}    = 'testing-'.random_uid().'-hostgator.com';
	$params->{'rep'}       = 'hostgatortesting@hostgator.com';
	$params->{'placement'} = 'reg';
	$params->{'pack'}      = '32';
	$params->{'price'}     = '14.99';
	$params->{'months'}    = 1;
	return $params;
}

1;
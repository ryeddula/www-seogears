use Test::More tests => 6;

use WWW::SEOGears;

my $api = WWW::SEOGears->new( { brandname => 'brandname',
                                brandkey  => '123456789ABCDEFG',
                                sandbox   => '1',
                                lwp       => {'parse_head' => 0, 'ssl_opts' => {'verify_hostname' => 0, 'SSL_verify_mode' => '0x00'}}
                              } );

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

#diag "\nCreating an account:\n".explain($params);
my $output = eval { $api->newuser($params); };
ok ($output->{success}, "Account creation");

SKIP: {

	skip "Failed to create account", 5 if (not $output->{success});
	if ($output->{success}) {
		#diag "\nCreate account output:\n".explain($output);
	} else {
		diag "\nCreate account failed: $output->{debuginfo} - \n";
		diag explain $@;
	}
	my $userid  = $params->{'userid'};
	my $email   = $params->{'email'};
	my $authkey = $output->{'authkey'};
	my $bzid    = $output->{'bzid'};

	$params = { 'userid' => $params->{'userid'},
				'email'  => $params->{'email'},
	};

	#diag "\nChecking created account:\n".explain($params);
	if ($output =  eval { $api->statuscheck($params); }) {
		#diag "\nStatuscheck output:\n".explain($output);
	} else {
		diag "Statuscheck failed: $output->{debuginfo} - \n";
		diag explain $@;
	}

	ok ($output->{success}, "Statuscheck returned success");
	ok ($output->{authkey} eq $authkey, "Authkey returned matches");
	ok ($output->{bzid} eq $bzid, "Bzid returned matches");

	$params = { 'bzid'    => $bzid,
				'authkey' => $authkey,
	};
	$output = $api->get_tempauth($params);
	if ($output->{success}) {
		#diag "\nGet auth output:\n".explain($output);
	} else {
		diag "\nGet auth failed: $output->{debuginfo} - \n";
		diag explain $@;
	}
	ok ($output->{success}, "Getauth returned success");
	my $tempurl = 'https://seogearstools.com/api/login.html?&bzid='.$output->{bzid}.'&tempauthkey='.$output->{tempauthkey};
	my $ua  = $api->{_ua};
	my $res1 = $ua->get($tempurl);
	
	$params = { 'userid'    => $userid,
				'email'     => $email,
	};
	$tempurl2 = $api->get_templogin_url($params);
	#diag "\nTempurl: $tempurl\nTempurl2: $tempurl2\n";
	my $res2 = $ua->get($tempurl2);
	ok ($res1->is_success && $res2->is_success, "Both tempurls fetched successfully");
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

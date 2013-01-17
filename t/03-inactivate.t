use Test::More tests => 2;

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
if ($output->{success}) {
	#diag "\nCreate account output:\n".explain($output);
} else {
	diag "\nCreate account failed: $output->{debuginfo} - \n";
	diag explain $@;
}
ok ($output->{success}, "Account creation");
SKIP: {

	skip "Failed to create account", 1 if (not $output->{success});
	my $authkey = $output->{'authkey'};

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

	SKIP: {
		skip "Failed to fetch current info for $params->{'userid'}", 1 if (not $output->{success});

		$params = { 'bzid'    => $output->{bzid},
					'authkey' => $output->{authkey},
		};
		#diag "\nInactivating account:\n".explain($params);
		$output =  eval { $api->inactivate($params); };
		if ($output->{success}) {
			#diag "\nInactivate output:\n".explain($output);
		} else {
			diag "\nInactivate failed: $output->{debuginfo} - \n";
			diag explain $@;
		}
		ok ( $output->{success}, "Inactivate account");
	}
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

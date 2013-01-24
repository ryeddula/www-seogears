use Test::More tests => 6;
use FindBin;
use lib $FindBin::Bin;
use CommonSubs;

my $api = CommonSubs::initiate_api();

my $params = CommonSubs::gen_rand_params();
#diag "\nCreating an account:\n".explain($params);
my $output = CommonSubs::newuser($api, $params);
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
	my $tempurl2 = $api->get_templogin_url($params);
	my $res2 = $ua->get($tempurl2);

	$params = { 'bzid'    => $bzid,
				'authkey' => $authkey,
	};
	my $tempurl3 = $api->get_templogin_url($params);
	my $res3 = $ua->get($tempurl3);

	#diag "\nTempurl: $tempurl\nTempurl2: $tempurl2\nTempurl3: $tempurl3\n";
	ok ($res1->is_success && $res2->is_success && $res3->is_success, "Tempurls fetched successfully");
}

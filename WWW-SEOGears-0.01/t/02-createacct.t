use Test::More tests => 6;
use FindBin;
use lib $FindBin::Bin;
use CommonSubs;

use Sys::Hostname;

my $api = CommonSubs::initiate_api();

my $params = CommonSubs::gen_rand_params();
#diag "\nCreating an account:\n".explain($params);
my $output = CommonSubs::newuser($api, $params);


if ($output->{success}) {
	#diag "\nCreate account output:\n".explain($output);
} else {
	diag "\nCreate account failed: $output->{debuginfo} - \n";
	diag explain $@;
}
ok ($output->{success}, "Account creation");
SKIP: {

	skip "Failed to create account", 5 if (not $output->{success});
	my $authkey = $output->{'authkey'};
	$params = { 'userid' => $params->{'userid'},
				'email'  => $params->{'email'},
	};

	#diag "\nChecking created account:\n".explain $params;
	if ($output =  eval { $api->statuscheck($params); }) {
		#diag "\nStatuscheck output:\n".explain($output);
	} else {
		diag "Statuscheck failed: $output->{debuginfo} - \n";
		diag explain $@;
	}

	ok ($output->{success}, "Statuscheck returned success");
	ok ($output->{authkey} eq $authkey, "Authkey returned matches");
	ok ($output->{pack} eq '32', "Package ID matches");
	ok ($output->{price} eq "14.99", "Package price is correct");
	ok ($output->{months} eq "1", "Months value is correct");
}
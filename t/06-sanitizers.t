use Test::More tests => 5;

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
$params->{'pack'}      = '32';
$params->{'price'}     = '14.99';
$params->{'months'}    = 1;

#diag "\nCreating an account:\n".explain($params);
my $output = eval { $api->newuser($params); };
if ($output->{success}) {
	#diag "\nCreate account output:\n".explain($output);
} else {
	diag explain $@;
}
ok (not (keys $output), "Create account sanitization failed");

$params = { 'userid' => random_uid(),
			'email'  => '',
};
#diag "\nStatuscheck:\n".explain($params);
$output = eval { $api->statuscheck($params); };
if ($output->{success}) {
	#diag "\nStatuscheck output:\n".explain($output);
} else {
	diag explain $@;
}
ok (not (keys $output), "Statuscheck sanitization failed");

$params = { 'bzid' => random_uid() };
#diag "\nInactivate account:\n".explain($params);
$output = eval { $api->inactivate($params); };
if ($output->{success}) {
	#diag "\nInactivate output:\n".explain($output);
} else {
	diag explain $@;
}
ok (not (keys $output), "Inactivate sanitization failed");

$params = { 'bzid' => random_uid() };
#diag "\nUpdate account:\n".explain($params);
$output = eval { $api->update($params); };
if ($output->{success}) {
	#diag "\nUpdate output:\n".explain($output);
} else {
	diag explain $@;
}
ok (not (keys $output), "Update sanitization failed");

$params = { 'bzid' => random_uid() };
#diag "\nGet tempauth:\n".explain($params);
$output = eval { $api->inactivate($params); };
if ($output->{success}) {
	#diag "\nGet Tempauth output:\n".explain($output);
} else {
	diag explain $@;
}
ok (not (keys $output), "Get tempauth sanitization failed");

sub random_uid {

	my $limit    = 12;
	my $possible = 'abcdefghijkmnpqrstuvwxyz0123456789';
 	my $string   = '';
 	while (length($string) < $limit) {
 		$string .= substr( $possible, ( int( rand( length($possible) ) ) ), 1 );
 	}
 	return $string;
}

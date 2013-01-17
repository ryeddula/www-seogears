package WWW::SEOGears;

use 5.008;
use strict;
use Carp qw(croak);
use Data::Dumper;
use English qw(-no_match_vars);
use List::Util qw(first);
use warnings FATAL => 'all';

use Date::Calc qw(Add_Delta_YMDHMS Today_and_Now);
use HTTP::Request;
use JSON qw(decode_json);
use LWP::UserAgent;
use URI::Escape qw(uri_escape);

=head1 NAME

WWW::SEOGears - Perl Interface for SEOGears API.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This module provides you with an perl interface to interact with the Seogears API.

	use WWW::SEOGears;
	my $api = WWW::SEOGears->new( { 'brandname' => $brandname,
	                                'brandkey' => $brandkey,
	                                'sandbox' => $boolean 
	});
	$api->newuser($params_for_newuser);
	$api->statuscheck($params_for_statuscheck);
	$api->inactivate($params_for_inactivate);
	$api->update($params_for_update);
	$api->get_tempauth($params_for_update);

=head1 SUBROUTINES/METHODS

=head2 new

Constructor.

B<Input> takes a hashref that contains:

	Required:

	brandname => Brandname as listed on seogears' end.
	brandkey  => Brandkey received from seogears.
	
	Will croak if the above keys are not present.

	Optional:
	sandbox   => If specified the sandbox API url is used instead of production.
	lwp       => hash of options that are passed on to the LWP::UserAgent object.
	             Example value: {'parse_head' => 0, 'ssl_opts' => {'verify_hostname' => 0, 'SSL_verify_mode' => '0x00'}}

=cut

sub new {

	my ($class, $opts) = @_;

	my $self = {};
	bless $self, $class;

	$self->{brandname} = delete $opts->{brandname} or croak('brandname is a required parameter');
	$self->{brandkey}  = delete $opts->{brandkey}  or croak('brandkey is a required parameter');

	# API urls
	$self->{authurl}  = 'http://seogearstools.com/api/auth.html';
	$self->{loginurl} = 'https://seogearstools.com/api/login.html';
	if (delete $opts->{sandbox}) {
		$self->{userurl} = 'https://seogearstools.com/api/user-sandbox.html';
	} else {
		$self->{userurl} = 'https://seogearstools.com/api/user.html';
	}

	# The LWP objects for the queries
	my $lwp_opts = delete $opts->{lwp};
	$self->{_ua}  = LWP::UserAgent->new(%{$lwp_opts});
	$self->{_req} = HTTP::Request->new('GET');

	#valid month options
	$self->{_valid_months} = ['1','12','24','36'];

	return $self;
}

=head2 newuser

Creates a new user via the 'action=new' API call.
Since the 'userid' and 'email' can be used to fetch details about the seogears account, storing these values locally is recommended.

B<Input> Requires that you pass in the following parameters for the call:

	userid    => '123456789'
	email     => 'test1@testing123.com'
	name      => 'Testing User'
	phone     => '1.5552223333'
	domain    => 'somedomain.com'
	rep       => 'rep@domain.com'
	placement => 'reg'
	pack      => '32'
	price     => '14.99'
	months    => '12'

Croaks if it is unable to sanatize the %params passed successfully, or the HTTP request to the API fails.

B<Output> Hash containing the data returned by the API:

	"success"   => 1
	"authkey"   => "GB0353566P163045n07157LUFGZntgqNF042MO692S19567CIGHj727437179300tE5nt8C362803K686Yrbj4643zausyiw"
	"bzid"      => "30928"
	"debuginfo" => "Success"
	"message"   => "New Account Created"

=cut

sub newuser {

	my ($self, $params) = @_;
	$self->_sanatize_params('new', $params) or $self->_error('Failed to sanatize params. "'.$self->get_error.'": '.Dumper($params), 1);
	my ($output, $error) = $self->_make_request('new', $params);
	if ($error) {
		$self->_error('Failed to process newuser request. HTTP request failed: '.$error, 1);
	}
	return decode_json($output);
}

=head2 statuscheck

Fetches information about a user via the 'action=statuscheck' API call.

B<Input> Requires that you pass in the following parameters for the call:

	userid    => '123456789'
	email     => 'test1@testing123.com'

Croaks if it is unable to sanatize the %params passed successfully, or the HTTP request to the API fails.

B<Output> Hash containing the data returned by the API:

	"success"   =>  1,
	"inactive"  => "0"
	"authkey"   => "WO8407914M283278j87070OPWZGkmvsEG847ZB845Q28584YSBDt684478133472pV3ws1X655571X005Zlhh6810hsxjjka"
	"bzid"      => "30724"
	"brand"     => "brandname"
	"message"   => User is active. See variables for package details."
	"expdate"   => "2014-01-01 12:00:00"
	"debuginfo" => "User exists. See variables for status and package details."
	"pack"      => "32"
	"price"     => "14.99"
	"months"    => "12"

=cut

sub statuscheck {

	my ($self, $params) = @_;
	$self->_sanatize_params('statuscheck', $params) or $self->_error('Failed to sanatize params. "'.$self->get_error.'": '.Dumper($params), 1);
	my ($output, $error) = $self->_make_request('statuscheck', $params);
	if ($error) {
		$self->_error('Failed to process statuscheck request. HTTP request failed: '.$error, 1);
	}
	return decode_json($output);
}

=head2 inactivate

Inactivates a user via the 'action=inactivate' API call.

B<Input> Requires that you pass in the following parameters for the call:

	"bzid"      => "30724"
	"authkey"   => "WO8407914M283278j87070OPWZGkmvsEG847ZB845Q28584YSBDt684478133472pV3ws1X655571X005Zlhh6810hsxjjka"

Croaks if it is unable to sanatize the %params passed successfully, or the HTTP request to the API fails.

B<Output> Hash containing the data returned by the API:

	'success'   => 1,
	'bzid'      => '30724',
	'debuginfo' => 'Success BZID30724 WO8407914M283278j87070OPWZGkmvsEG847ZB845Q28584YSBDt684478133472pV3ws1X655571X005Zlhh6810hsxjjka'

=cut

sub inactivate {

	my ($self, $params) = @_;
	$self->_sanatize_params('inactivate', $params) or $self->_error('Failed to sanatize params. "'.$self->get_error.'": '.Dumper($params), 1);
	my ($output, $error) = $self->_make_request('inactivate', $params);
	if ($error) {
		$self->_error('Failed to process inactivate user request. HTTP request failed: '.$error, 1);
	}
	return decode_json($output);
}

=head2 update

Updates/Renews a user via the 'action=update' API call.

B<Input> Requires that you pass in the following parameters for the call:

	"bzid"      => "30724"
	"authkey"   => "WO8407914M283278j87070OPWZGkmvsEG847ZB845Q28584YSBDt684478133472pV3ws1X655571X005Zlhh6810hsxjjka"

	Optional params:
	"email"     => "newemail@testing123.com"
	"phone"     => "1.5552224444"
	"pack"      => "33"
	"months"    => "24"
	"price"     => "14.99"

If pack is specified, then a price must be specified along with it.

Croaks if it is unable to sanatize the %params passed successfully, or the HTTP request to the API fails.

B<Output> Hash containing the data returned by the API:

	'success' => 1,
	'bzid' => '30724',
	'debuginfo' => 'Success'

=cut

sub update {

	my ($self, $params) = @_;
	$self->_sanatize_params('update', $params) or $self->_error('Failed to sanatize params. "'.$self->get_error.'": '.Dumper($params), 1);
	my ($output, $error) = $self->_make_request('update', $params);
	if ($error) {
		$self->_error('Failed to process update user request. HTTP request failed: '.$error, 1);
	}
	return decode_json($output);
}

=head2 get_tempauth

Retrieves the tempauth key for an account from the API.

B<Input> Requires that you pass in the following parameters for the call:

	bzid      => '31037'
	authkey   => 'HH1815009C705940t76917IWWAQdvyoDR077CO567M05324BHUCa744638889409oM8kw5E097737M626Gynd3974rsetvzf'

Croaks if it is unable to sanatize the %params passed successfully, or the HTTP request to the API fails.

B<Output> Hash containing the data returned by the API:

	'success'     => 1,
	'bzid'        => '31037',
	'tempauthkey' => 'OU8937pI03R56Lz493j0958US34Ui9mgJG831JY756X0Tz04WGXVu762IuIxg7643vV6ju9M96J951V430Qvnw41b4qzgp2pu',
	'message'     => ''

=cut

sub get_tempauth {

	my ($self, $params) = @_;
	$self->_sanatize_params('auth', $params) or $self->_error('Failed to sanatize params. "'.$self->get_error.'": '.Dumper($params), 1);
	my ($output, $error) = $self->_make_request('auth', $params);
	if ($error) {
		$self->_error('Failed to process get tempauth request. HTTP request failed: '.$error, 1);
	}
	return decode_json($output);
}

=head2 get_templogin_url

Generates the temporary login URL with which you can access the seogears' control panel. Essentially acts as a wrapper that stringifies the data returned by get_tempauth.

B<Input> Requires that you pass in the following parameters for the call:

	userid    => '123456789'
	email     => 'test1@testing123.com'

It will use the userid and email provided to fetch the proper bzid/authkey for the account, which are inturn used to retrieve the tempauthkey that will be used for the login.

Croaks if it is unable to sanatize the %params passed successfully, or the HTTP request to the API fails.

B<Output> Returns the login url that can be used to access the control panel on SEOgears.
Example: https://seogearstools.com/api/login.html?bzid=31037&tempauthkey=OU8937pI03R56Lz493j0958US34Ui9mgJG831JY756X0Tz04WGXVu762IuIxg7643vV6ju9M96J951V430Qvnw41b4qzgp2pu

=cut

sub get_templogin_url {

	my ($self, $params) = @_;
	my $current_info = $self->statuscheck($params);
	if (not $current_info->{success}) {
		$self->_error("Failed to fetch current account information. Error: $current_info->{'debuginfo'}", 1);
	}

	$params = {'bzid' => $current_info->{'bzid'}, 'authkey' => $current_info->{'authkey'}};
	my $tempauth = $self->get_tempauth($params);
	if (not $tempauth->{success}) {
		$self->_error("Failed to fetch tempauth key for account. Error: $tempauth->{'debuginfo'}", 1);
	}

	return $self->_get_apiurl('login')._stringify_params({'bzid' => $tempauth->{'bzid'}, 'tempauthkey' => $tempauth->{'tempauthkey'}});
}

=head2 get_userurl, get_authurl, get_loginurl

Return the corresponding api url that is being used.

=cut

sub get_userurl  { return shift->{'userurl'}; }
sub get_authurl  { return shift->{'authurl'}; }
sub get_loginurl { return shift->{'loginurl'}; }

=head2 get_error

Returns $self->{'error'}

=cut

sub get_error { return shift->{'error'}; }

=head2 get_brandname

Returns $self->{'brandname'}

=cut

sub get_brandname { return shift->{'brandname'}; }

=head2 get_brandkey

Returns $self->{'brandkey'}

=cut

sub get_brandkey { return shift->{'brandkey'}; }

=head1 Internal Subroutines

The following are not meant to be used directly, but are available if 'finer' control is required.

=cut

=head2 _make_request

Makes the HTTP request to the API server. 

B<Input> Takes the 'action' and sanatized paramaters hashref as input.

B<Output> Returns an array containing the http response, and error. 
If the HTTP request was successful, then the error is blank.
If the HTTP request failed, then the response is blank and the error is the status line from the HTTP response.

=cut

sub _make_request {

	my $self   = shift;
	my $action = shift;
	my $params = shift;

	my $uri    = $self->_get_apiurl($action) or return ('', $self->get_error);
	$uri      .= _stringify_params($params);
	$self->{_req}->uri($uri);

	my $res = eval {
		local $SIG{ALRM} = sub { croak 'connection timeout' };
		my $timeout = $self->{_ua}->timeout() || '30';
		alarm $timeout;
		$self->{_ua}->request($self->{_req});
	};
	alarm 0;

	if (!$res || $EVAL_ERROR || ref $res && $res->status_line =~ m/connection timeout/) {
		return ('', 'connection timeout');
	}elsif ($res->is_success()) {
		return ($res->content(), '');
	} else {
		return ('', $res->status_line);
	}
}

=head2 _stringify_params

Stringifies the content of a hash such that the output can be used as the URI body of a GET request.

B<Input> A hashref containing the sanatizied parameters for an API call.

B<Output> String with the keys and values stringified as so '&key1=value1&key2=value2'

=cut

sub _stringify_params {

	my $params = shift;
	my $url;
	foreach my $key (keys %{$params}) {
		$url .= '&'.$key.'='.$params->{$key};
	}
	return $url;
}

=head2 _sanatize_params

Sanatizes the data in the hashref passed for the action specified.

B<Input>  The 'action', and a hashref that has the data that will be sanatized.

B<Output> Boolean value indicating success. The hash is altered in place as needed.

=cut

sub _sanatize_params {

	my $self   = shift;
	my $action = shift;
	my $params = shift;

	if ($action eq 'new') {
		return $self->_sanatize_params_newuser($params);
	}
	if ($action eq 'statuscheck') {
		return $self->_sanatize_params_statuscheck($params);
	}
	if ($action eq 'inactivate' or $action eq 'auth') {
		return $self->_sanatize_params_inactivate_auth($params);
	}
	if ($action eq 'update') {
		return $self->_sanatize_params_update($params);
	}
	return;
}

=head2 _sanatize_params_newuser

Sanatizes the data in the hashref passed for the 'action=new' API call.

B<Input> The following keys are required. If any of them are missing, it will set $self->{error} and return

	userid
	name
	email
	phone
	domain
	rep
	pack
	price
	placement
	months

B<Output> Boolean value indicating success. The hash is altered in place as needed.

The 'expdate' value is calculated via B<_months_from_now($params-E<gt>{'months'})>.

=cut

sub _sanatize_params_newuser {

	my $self   = shift;
	my $params = shift;
	my %required_keys = map { ($_ => 1) } qw(userid name email phone domain rep pack placement price months);

	#remove any data that shouldn't be in the params beforehand.
	foreach my $key (keys %{$params}) {
		if (not $required_keys{$key}) {
			delete $params->{$key};
		}
	}

	foreach (keys %required_keys) {
		if (not exists $params->{$_}) {
			$self->_error("Missing required parameter: '$_'.");
			return;
		} elsif (not $params->{$_}) {
			$self->_error("Blank value passed for required parameter: '$_'.");
			return;
		}
		if ($_ eq 'months' and (not $self->_valid_months($params->{'months'}))) {
			$self->_error("Month parameter set incorrectly to: '$params->{$_}'");
			return;
		}
	}
	#if price is passed as part of the params, use that instead of what the pack price is.
	$params->{'expdate'}  = uri_escape( _months_from_now($params->{'months'}) );
	$params->{'brand'}    = $self->get_brandname;
	$params->{'brandkey'} = $self->get_brandkey;
	return 1;
}

=head2 _sanatize_params_statuscheck

Sanatizes the data in the hashref passed for the 'action=statuscheck' API call.

B<Input> The following keys are required. If any of them are missing, it will set $self->{error} and return

	userid
	email

B<Output> Boolean value indicating success.

=cut

sub _sanatize_params_statuscheck {

	my $self   = shift;
	my $params = shift;

	my @required_keys = qw(userid email);
	foreach (@required_keys) {
		if (not exists $params->{$_}) {
			$self->_error("Missing required parameter: '$_'.");
			return;
		} elsif (not $params->{$_}) {
			$self->_error("Blank value passed for required parameter: '$_'.");
			return;
		}
	}
	return 1;
}

=head2 _sanatize_params_inactivate_auth

Sanatizes the data in the hashref passed for the 'action=inactivate' and 'auth' API calls.

B<Input> The following keys are required. If any of them are missing, it will set $self->{error} and return

	bzid
	authkey

B<Output> Boolean value indicating success.

=cut

sub _sanatize_params_inactivate_auth {

	my $self   = shift;
	my $params = shift;

	my @required_keys = qw(bzid authkey);
	foreach (@required_keys) {
		if (not exists $params->{$_}) {
			$self->_error("Missing required parameter: '$_'.");
			return;
		} elsif (not $params->{$_}) {
			$self->_error("Blank value passed for required parameter: '$_'.");
			return;
		}
	}
	return 1;
}

=head2 _sanatize_params_update

Sanatizes the data in the hashref passed for the 'action=update' API call.

B<Input> The following keys are required. If any of them are missing, it will set $self->{error} and return

	bzid
	authkey

	Optional parameters:
	email
	months
	pack
	phone
	price
	expdate

If 'pack' is specified, then 'price' must also be given.
If 'months' is specified, but 'expdate' is not, then a new 'expdate' value is calculated via B<_months_from_now($params-E<gt>{'months'})>

B<Output> Boolean value indicating success. The hash is altered in place as needed.

=cut

sub _sanatize_params_update {

	my $self   = shift;
	my $params = shift;
	my @required_keys = qw(bzid authkey);
	my @optional_keys = qw(email expdate months pack phone price);

	#remove any data that shouldn't be in the params beforehand.
	my %keys_check = map { ($_ => 1) } (@required_keys, @optional_keys);
	foreach my $key (keys %{$params}) {
		if (not $keys_check{$key}) {
			delete $params->{$key};
		}
	}

	foreach (@required_keys) {
		if (not exists $params->{$_}) {
			$self->_error("Missing required parameter: '$_'.");
			return;
		} elsif (not $params->{$_}) {
			$self->_error("Blank value passed for required parameter: '$_'.");
			return;
		}
	}

	foreach (@optional_keys) {
		if (exists $params->{$_}) {
			if ($_ eq 'pack' and (not $params->{'price'})) {
				$self->_error("Package ID specified without a price value.");
				return;
			}
			if ($_ eq 'months') {
				if ($self->_valid_months($params->{'months'})) {
					$params->{'expdate'}  = uri_escape( _months_from_now($params->{'months'}) );
				} else {
					$self->_error("Month parameter specified is not valid: '$params->{$_}'");
					return;
				}
			}
		}
	}
	return 1;
}

=head2 _valid_months

Returns true if the 'months' value specified is a valid. Currently, you can set renewals to occur on a monthly or yearly (upto 3 years), so the valid values are:

	1
	12
	24
	36

=cut

sub _valid_months {

	my $self   = shift;
	my $months = shift;
	if (first { $months == $_ } @{$self->{_valid_months}} ) {
		return 1;
	}
	return;
}

=head2 _get_apiurl

Depending on the action passed, it will return the initial part of the URL that you can use along with the _stringify_params method to generate the full GET url.

Valid actions and the corresponding strings that are returned:

	'auth'        => get_authurl().'?'
	'login'       => get_loginurl().'?'
	'new'         => get_userurl().'?action=new'
	'statuscheck' => get_userurl().'?action=statuscheck'
	'inactivate'  => get_userurl().'?action=inactivate'
	'update'      => get_userurl().'?action=update'

If no valid action is specified, it will set the $self->{error} and return;

=cut

sub _get_apiurl {

	my $self   = shift;
	my $action = shift;

	if ($action eq 'auth') {
		return $self->get_authurl().'?';
	} elsif ($action eq 'login') {
		return $self->get_loginurl().'?';
	} elsif (first {$action eq $_} qw(new statuscheck inactivate update)) {
		return $self->get_userurl()."?action=$action";
	} else {
		$self->_error('Unknown action provided.');
		return;
	}
}

=head2 _error

Internal method that is used to report and set $self->{'error'}. It will croak if called with a true second argument (Such as '$self->_error($msg, 1);').

=cut

sub _error {

	my ($self, $msg, $croak) = @_;
	$self->{'error'} = $msg;
	if ($croak) { croak $msg};
}

=head2 _months_from_now

Internal helper method that will calculate the expiration date thats x months in the future - calculated via Date::Calc's Add_Delta_YMDHMS().

=cut

sub _months_from_now {

	my $months = shift;
	my @date   = Add_Delta_YMDHMS( Today_and_Now(), 0, $months, 0, 0, 0, 0);
	return sprintf '%d-%02d-%02d %02d:%02d:%02d', @date;
}

=head1 AUTHOR

Rishwanth Yeddula, C<< <ryeddula at hostgator.com> >>

Hostgator.com LLC

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-seogears at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-SEOGears>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc WWW::SEOGears

You can also review the API documentation provided by SEOgears for more information.

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-SEOGears>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-SEOGears>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-SEOGears>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-SEOGears/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Rishwanth Yeddula, Hostgator.com LLC.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of WWW::SEOGears

package Google;


package Google::CalendarAPI;

use strict;
use warnings;

use API::Google::GCal;

use DateTimeFactory;

my $api;
my $user;
my $dtf;

sub auth {
	my ($tokensfile, $user_) = @_;
	$api = API::Google::GCal->new({tokensfile => $tokensfile});
	$user = $user_;
	$dtf = DateTimeFactory->new;
}

my $_expire;
sub _refresh_token {
	my $now = $dtf->now;
	if (not defined $_expire or $dtf->cmp($_expire, $now) <= 0) {
		$api->refresh_access_token_silent($user);
		$_expire = $now->clone->add(minutes => 45);
	}
}

package Google::CalendarAPI::Events;

use strict;
use warnings;

sub list {
	my ($calendar, $span) = @_;
	$span = $span // $dtf->span_d($dtf->tomorrow, {days => 7});

	Google::CalendarAPI::_refresh_token;

	my @result = grep {
		defined $_->{summary} and $span->contains($_->{span});
	} map {{
		summary => $_->{summary},
		transparent => ($_->{transparency} // "") eq "transparent",
		span => $dtf->span_se(
			$dtf->parse_rfc3339($_->{start}->{dateTime}),
			$dtf->parse_rfc3339($_->{end}->{dateTime})),
	}} @{$api->events_list({calendarId => $calendar, user => $user})};

	\@result;
}

sub insert {
	my ($calendar, $summary, $span) = @_;

	Google::CalendarAPI::_refresh_token;

	my $event = {};
	$event->{summary} = $summary;

	$event->{start}{dateTime} = $dtf->rfc3339($span->start);
	$event->{end}{dateTime} = $dtf->rfc3339($span->end);

	$api->add_event($user, $calendar, $event);
}

1;

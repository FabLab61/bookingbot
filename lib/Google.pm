package Google;


package Google::CalendarAPI;

use strict;
use warnings;
use utf8;

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

use Data::Dumper;

use strict;
use warnings;


=method list

Accept google calendar_id and interval (span)

Return an array of events

=cut

sub list {
	my ($calendar, $span) = @_;

	warn "".(caller(0))[3]."() : ".Dumper \@_; # return and a

	$span = $span // $dtf->span_d($dtf->tomorrow, {days => 7});

	Google::CalendarAPI::_refresh_token;

	warn "User: ".$user;

	warn "Events list: ".Dumper \@{$api->events_list({calendarId => $calendar, user => $user})};

	

	my @i = map {{
		id => $_->{id},
		summary => $_->{summary},
		transparent => ($_->{transparency} // "") eq "transparent",
		span => $dtf->span_se(
			$dtf->parse_rfc3339($_->{start}->{dateTime}),
			$dtf->parse_rfc3339($_->{end}->{dateTime})),
	}} @{$api->events_list({calendarId => $calendar, user => $user})};

	warn Dumper \@i;

	my @result = grep { defined $_->{summary} and $span->contains($_->{span}) } @i;

	warn "Result: ".Dumper \@result; # span field is DateTime::Span object

	\@result;
}

sub insert {
	my ($calendar, $summary, $span, $busy) = @_;

	Google::CalendarAPI::_refresh_token;

	my $event = {};
	$event->{summary} = $summary;
	$event->{transparency} = $busy ? "opaque" : "transparent";

	$event->{start}{dateTime} = $dtf->rfc3339($span->start);
	$event->{end}{dateTime} = $dtf->rfc3339($span->end);

	$api->add_event($user, $calendar, $event);
}

sub delete {
	my ($calendar, $event) = @_;

	Google::CalendarAPI::_refresh_token;

	my $url = "https://www.googleapis.com/calendar/v3/calendars/";
	$api->api_query({
		method => "delete",
		route =>  $url . $calendar . "/events/" . $event,
		user => $user
	});
}

1;

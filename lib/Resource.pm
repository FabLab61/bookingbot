package Resource;

# ABSTRACT: Class for managing resources in Google Calendar. Each object of this class corresponds to particular Google Calendar

=head1 SYNOPSIS

    use Resource;
		use Data::Dumper;
		$Data::Dumper::Maxdepth = 3;
		my $r = Resource->new({
			user => 'fablab61.ru@gmail.com',
			calendar => "GOOGLE_CAL_ID"
		});
		warn Dumper $r->events_inside_span( DateTime::Span->from_datetimes( start => DateTime->now) );
		my $dur = DateTime::Duration->new(hours=>3);
		warn Dumper $r->vacancies($dur, $span); # will return all events that lasts more than 3 hours
		my $span2 = DateTime::Span->from_datetimes( start => DateTime->now, end => DateTime->now->add_duration($dur) ); # from now till +1 hour
		warn Dumper $r->book('Ivan Ivanov',$span2)->json; # return Google API response formatted in Perl hash


Each object of this class corresponds to particular Google Calendar ID

For more information about Google Calendar API please check https://developers.google.com/google-apps/calendar/v3/reference

For working with Google Calendar API this module uses L<Moo::Google> module

=cut


use strict;
use warnings;
use utf8;
use Data::Dumper;

use DateTimeFactory;  # has only one attribute - timeZone
use ScheduleUtils;
use Moo::Google;
# use Hash::Slice qw/slice/;


my $gapi = Moo::Google->new;
my $dtf = DateTimeFactory->new('Europe/Moscow');

sub new {
	my ($class, $record) = @_;
	my %self = ((dtf => DateTimeFactory->new()), %$record);
	my $user = $record->{user} || 'fablab61ru@gmail.com';
	$gapi->auth_storage->setup({type => 'jsonfile', path => 'gapi.conf' });
	$gapi->user($user);
	$gapi->do_autorefresh(1);
	bless \%self, $class;
}

=method  _enclosing_event


=cut


sub _enclosing_event {
	my ($events, $span) = @_;

	my @result = grep {
		$_->{transparent} && $_->{span}->contains($span);
	} @$events;

	scalar @result ? $result[0] : undef;
}

=method events_inside_span

	Return list of events into specified DateTime::Span object

	Input - L<DateTime::Span> object

	https://metacpan.org/pod/DateTime::Span

	Output = HASH with following fields:

		id - Google Calendar Event ID
		summary - Google Calendar Event summary
		transparent - can be 0 or 1, based on 'transparency function'
		span - corresponding L<DateTime::Span> object

=cut


sub events_inside_span { # instead of old Google::CalendarAPI::Events::list
	my ($self, $span) = @_;
	my $events = $gapi->Calendar->Events->list({ calendarId => $self->{calendar} })->json->{items}; # all
	warn "Total events found in calendarId: ".scalar @$events;
	# warn "Events".Dumper $events;
	# filter events
	my @i = map {{
		id => $_->{id},
		summary => $_->{summary},
		transparent => ($_->{transparency} // "") eq "transparent",  # ?
		span => $dtf->span_se(
			$dtf->parse_rfc3339($_->{start}{dateTime}),
			$dtf->parse_rfc3339($_->{end}{dateTime})),
	}} @$events;   # more convenient representation for further comparision
	#warn "Spanified Event objects: ".Dumper \@i;
	$span = $span // $dtf->span_d($dtf->tomorrow, {days => 7}); # DateTime::Duration from tomorrow till tomorrow plus week
	my @result = grep { defined $_->{summary} && $span->contains($_->{span}) } @i; # like "is-fully-inside"
	return \@result;
}


=method vacancies

Search free timeslots with minimum $duration in specified interval ($span)

	my $resource = Resource->new;
	$resource->vacancies($duration, $span);

Input format:

$duration - L<DateTime::Duration> object

$span - L<DateTime::Span> object

Return ARRAY of hashes with following properties:

	busy - 0 or 1
	span - L<DateTime::Span> object

=cut


sub vacancies {
	my ($self, $duration, $span) = @_;
	my $events = $self->events_inside_span($span);
	my @free = map { $_->{span} } grep { $_->{transparent} } @$events;
	my @busy = map { $_->{span} } grep { not $_->{transparent} } @$events;
	my $vacancies = ScheduleUtils::vacancies(\@free, \@busy, $duration);
	my @result = map {{
		span => $_,
		instructor => _enclosing_event($events, $_)->{summary}
	}} @$vacancies;
	warn Dumper \@result;
	return \@result;
}


=method schedule

	Show schedule of instructor

	my $resource = Resource->new;
	$resource->schedule($instructor_id_id, $span);
	# $span - DateTime::Span object
	# $instructor_id_id - like 'pavel.p.serikov@gmail.com'

=cut


sub schedule {
	my ($self, $instructor_id, $span) = @_;
	my $events = $self->events_inside_span($span);
	#warn "My events as instructor:". Dumper $events;

	my @free = map { $_->{span} }
		grep { $_->{summary} eq $instructor_id }
			grep { $_->{transparent} } @$events;

	my @busy = map { $_->{span} }
		grep { not $_->{transparent} } @$events;

	ScheduleUtils::schedule(\@free, \@busy); # return sorted arrayref
}


=method remove

	my $resource = Resource->new;
	$resource->remove($instructor_id, $span2remove, $span);
	# $span and $span2remove - DateTime::Span objects
	# $instructor_id_id - like 'pavel.p.serikov@gmail.com'

Search and remove event matching specified span and instructor_id

Warning! Will remove only first event into specified span

=cut


sub remove {
	my ($self, $instructor_id, $span2remove, $span) = @_;
	my $events = $self->events_inside_span($span);

	my @free = grep { $_->{span}->contains($span2remove) }
		grep { $_->{summary} eq $instructor_id }
		grep { $_->{transparent} } @$events;

	if (scalar @free) {
		my $event = $free[0];

		my @busy = grep { $event->{span}->contains($_->{span}) }
			grep { not $_->{transparent} } @$events;

		foreach my $e (@busy) {
			$self->record($instructor_id, $e->{span});
		}

		my $events = $gapi->Calendar->Events->delete({
			calendarId => $self->{calendar},
			eventId => $event->{id}
		});

		# Google::CalendarAPI::Events::delete($self->{calendar}, $event->{id});
	}
}

=method book

Store information about user booking in Google Calendar (add corresponding event)

https://developers.google.com/google-apps/calendar/v3/reference/events/insert

Returns Google API response (L<Mojo::Message::Response> object)

Blocks time (transparency = opaque), so this method can't be user for instructors

=cut


sub book {
	my ($self, $summary, $span) = @_;
	$gapi->Calendar->Events->insert({
		calendarId => $self->{calendar},
		options => {
			start => { dateTime => $dtf->rfc3339($span->start) },
			end => { dateTime => $dtf->rfc3339($span->end) },
			summary => $summary,
			transparency => 'opaque' # blocks time, can be 'transparent' in future (in case of two users allowed to work with one resource in same time)
		}
	});
}

=method record

Store information about instructor availability time in Google Calendar (add corresponding event)

https://developers.google.com/google-apps/calendar/v3/reference/events/insert

Returns Google API response (L<Mojo::Message::Response> object)

Do not block time (transparency = transparent), so this method can't be used for adding users booking

=cut

sub record {
	my ($self, $instructor_id, $span) = @_;
	$gapi->Calendar->Events->insert({
		calendarId => $self->{calendar},
		options => {
			start => { dateTime => $dtf->rfc3339($span->start) },
			end => { dateTime => $dtf->rfc3339($span->end) },
			summary => $instructor_id,
			transparency => 'transparent'
		}
	});
}

1;

package Resource;

# ABSTRACT: Class for managing resources in Google Calendar

use strict;
use warnings;
use utf8;
use Data::Dumper;

use DateTimeFactory;
use ScheduleUtils;
use Moo::Google;
use Hash::Slice qw/slice/;

my $gapi = Moo::Google->new;
my $user = 'fablab61ru@gmail.com';
$gapi->auth_storage->setup({type => 'jsonfile', path => 'gapi.conf' });
$gapi->user($user);
$gapi->do_autorefresh(1);
my $dtf = DateTimeFactory->new('Europe/Moscow');

=method new

Resource->new($record)

$record - hash with calendar id property like

{ "calendar": "GOOGLE_CAL_ID" }


=cut

sub new {
	my ($class, $record) = @_;
	my %self = ((dtf => DateTimeFactory->new()), %$record);
	bless \%self, $class;
}



sub _enclosing_event {
	my ($events, $span) = @_;

	my @result = grep {
		$_->{transparent} and $_->{span}->contains($span);
	} @$events;

	scalar @result ? $result[0] : undef;
}




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
	warn "Spanified Event objects: ".Dumper \@i;
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

Return ARRAY

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
	return \@result;
}


=method schedule

Obligatory parameter: instructor ID

=cut


sub schedule {
	my ($self, $instructor, $span) = @_;

	#warn "".(caller(0))[3]."() : ".Dumper $self;

	my $events = Google::CalendarAPI::Events::list($self->{calendar}, $span); # self->{calendar} contains calendar id

	warn "My events:". Dumper $events;

	my @free = map { $_->{span} }
		grep { $_->{summary} eq $instructor }
			grep { $_->{transparent} } @$events;

	my @busy = map { $_->{span} }
		grep { not $_->{transparent} } @$events;

	ScheduleUtils::schedule(\@free, \@busy);
}

sub remove {
	my ($self, $instructor, $span2remove, $span) = @_;

	my $events = Google::CalendarAPI::Events::list($self->{calendar}, $span);

	my @free = grep { $_->{span}->contains($span2remove) }
		grep { $_->{summary} eq $instructor }
		grep { $_->{transparent} } @$events;

	if (scalar @free) {
		my $event = $free[0];

		my @busy = grep { $event->{span}->contains($_->{span}) }
			grep { not $_->{transparent} } @$events;

		foreach my $e (@busy) {
			$self->record($instructor, $e->{span});
		}

		Google::CalendarAPI::Events::delete($self->{calendar}, $event->{id});
	}
}

sub book {
	my ($self, $summary, $span) = @_;
	Google::CalendarAPI::Events::insert($self->{calendar}, $summary, $span, 1);
}

sub record {
	my ($self, $instructor, $span) = @_;
	Google::CalendarAPI::Events::insert($self->{calendar}, $instructor, $span, 0);
}

1;

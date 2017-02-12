package Resource;

use strict;
use warnings;

use DateTimeFactory;
use ScheduleUtils;
use Google;

sub new {
	my ($class, $record) = @_;
	my %self = ((dtf => DateTimeFactory->new()), %$record);
	bless \%self, $class;
}

sub vacancies {
	my ($self, $duration, $span) = @_;

	my $events = Google::CalendarAPI::Events::list($self->{calendar}, $span);

	my @free = map { $_->{span} } grep { $_->{transparent} } @$events;
	my @busy = map { $_->{span} } grep { not $_->{transparent} } @$events;

	sub _enclosing_event {
		my ($events, $span) = @_;

		my @result = grep {
			$_->{transparent} and $_->{span}->contains($span);
		} @$events;

		scalar @result ? $result[0] : undef;
	}

	my $vacancies = ScheduleUtils::vacancies(\@free, \@busy, $duration);
	my @result = map {{
		span => $_,
		instructor => _enclosing_event($events, $_)->{summary}
	}} @{$vacancies};

	\@result;
}

sub schedule {
	my ($self, $instructor, $span) = @_;

	my $events = Google::CalendarAPI::Events::list($self->{calendar}, $span);

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

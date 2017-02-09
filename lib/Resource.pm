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

	my $dtf = $self->{dtf};

	my $events = Google::CalendarAPI::Events::list($self->{calendar}, $span);

	my @free = grep { $_->{summary} eq $instructor }
		grep { $_->{transparent} } @$events;

	my @busy = grep {
		my $span = $_->{span};
		my @result = grep { $_->{span}->contains($span) } @free;
		scalar @result;

	} grep { not $_->{transparent} } @$events;

	my @result = map { {span => $_->{span}, busy => not $_->{transparent}} }
		sort { $dtf->cmp($a->{span}->start, $b->{span}->start) }
		(@free, @busy);

	\@result;
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

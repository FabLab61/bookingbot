package ScheduleUtils;

use strict;
use warnings;

use DateTimeFactory;

sub vacancies {
	my ($freespans, $busyspans, $duration) = @_;

	my $dtf = DateTimeFactory->new();

	my $freeset = $dtf->spanset($freespans);
	my $busyset = $dtf->spanset($busyspans);

	my @result = grep {
		$dtf->durcmp($duration, $_->duration, $_->start) <= 0;
	} $freeset->complement($busyset)->as_list();

	\@result;
};

sub schedule {
	my ($freespans, $busyspans) = @_;

	my $dtf = DateTimeFactory->new();

	my $inputbusy = $dtf->spanset($busyspans);
	my $inputfree = $dtf->spanset($freespans);

	my $realbusy = $inputfree->intersection($inputbusy);
	my $realfree = $inputfree->complement($realbusy);

	my @busy = map {{ span => $_, busy => 1 }} $realbusy->as_list();
	my @free = map {{ span => $_, busy => 0 }} $realfree->as_list();

	my @result = sort { $dtf->cmp($a->{span}->start, $b->{span}->start) }
		(@busy, @free);

	\@result;
};

1;

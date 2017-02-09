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
	} $freeset->complement($busyset)->as_list;

	\@result;
};

1;

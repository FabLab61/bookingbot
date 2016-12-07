package RecordTimeParser;

use strict;
use warnings;

use Localization qw(lz);

my $dtf = DateTimeFactory->new;

sub _tokenize {
	my ($text) = @_;

	my $regexp = lz("span_regexp");
	if($text =~ m/${regexp}/g) {
		my %result = ();

		$result{day} = $1 // lz("today");
		$result{preposition} = $2 // "";
		$result{hours1} = $3 // 0;
		$result{minutes1} = $4 // 0;
		$result{hours2} = $5 // 0;
		$result{minutes2} = $6 // 0;

		\%result;
	} else {
		undef;
	}
}

sub _parse_tokens {
	my ($tokens, $begin) = @_;

	my $start = $begin->clone;
	$start->truncate(to => "day");
	$start->add(hours => $tokens->{hours1}, minutes => $tokens->{minutes1});

	my $end = $begin->clone;
	$end->truncate(to => "day");
	$end->add(hours => $tokens->{hours2}, minutes => $tokens->{minutes2});

	my $monday_re = lz("monday_re");
	my $tuesday_re = lz("tuesday_re");
	my $wednesday_re = lz("wednesday_re");
	my $thursday_re = lz("thursday_re");
	my $friday_re = lz("friday_re");
	my $saturday_re = lz("saturday_re");
	my $sunday_re = lz("sunday_re");

	if ($tokens->{day} eq lz("tomorrow")) {
		$start->add(days => 1);
		$end->add(days => 1);
	} elsif ($tokens->{day} =~ m/${monday_re}/g) {
	}

	if ($dtf->cmp($start, $end) < 0) {
		$dtf->span_se($start, $end);
	} else {
		undef;
	}
}

1;

package RecordTimeParser;

use strict;
use warnings;

use Localization qw(lz);

my $dtf = DateTimeFactory->new;

sub _parse_workinghours {
	my ($workinghours, $today) = @_;

	if ($workinghours =~ m/(\d{2}):(\d{2})-(\d{2}):(\d{2})/g) {
		my $start = $today->clone;
		$start->truncate(to => "day");
		$start->add(hours => $1 // 0, minutes => $2 // 0);

		my $end = $today->clone;
		$end->truncate(to => "day");
		$end->add(hours => $3 // 0, minutes => $4 // 0);


		if ($dtf->cmp($start, $end) >= 0) {
			$end->add(days => 1);
		}

		$dtf->span_se($start, $end);
	} else {
		undef;
	}
}

sub _tokenize {
	my ($text) = @_;

	my $regexp = lz("span_regexp");
	if($text =~ m/${regexp}/g) {
		my %result = ();

		$result{day} = $1 // lz("today");
		$result{preposition} = $2 // "";
		$result{hours1} = ($3 // 0) + 0;
		$result{minutes1} = ($4 // 0) + 0;
		$result{hours2} = ($5 // 0) + 0;
		$result{minutes2} = ($6 // 0) + 0;

		\%result;
	} else {
		undef;
	}
}

sub _parse_tokens {
	my ($tokens, $today, $workinghours) = @_;

	die unless defined $tokens;

	my $start = $today->clone;
	my $end = $today->clone;

	$start->truncate(to => "day");
	$end->truncate(to => "day");

	my $at_re = lz("at_re");
	my $until_re = lz("until_re");

	if ($tokens->{preposition} =~ m/$at_re/g) {
		$start->add(hours => $tokens->{hours1}, minutes => $tokens->{minutes1});
		$end->add(hours => $tokens->{hours1} + 1, minutes => $tokens->{minutes1});
	} elsif ($tokens->{preposition} =~ m/$until_re/g) {
		$start = $workinghours->start->clone;
		$end->add(hours => $tokens->{hours1}, minutes => $tokens->{minutes1});
	} else {
		$start->add(hours => $tokens->{hours1}, minutes => $tokens->{minutes1});

		if ($tokens->{hours2} == 0 && $tokens->{minutes2} == 0) {
			$end->add(days => 1);
		} else {
			$end->add(hours => $tokens->{hours2}, minutes => $tokens->{minutes2});
		}
	}

	if ($tokens->{day} eq lz("tomorrow")) {
		$start->add(days => 1);
		$end->add(days => 1);
	} else {
		my %days = (
			lz("monday_re")    => 1,
			lz("tuesday_re")   => 2,
			lz("wednesday_re") => 3,
			lz("thursday_re")  => 4,
			lz("friday_re")    => 5,
			lz("saturday_re")  => 6,
			lz("sunday_re")    => 7
		);

		foreach my $re (keys %days) {
			if ($tokens->{day} =~ m/$re/g) {
				my $current = $start->day_of_week();
				my $target = $days{$re};
				my $delta = $target - $current + ($target < $current ? 7 : 0);

				$start->add(days => $delta);
				$end->add(days => $delta);

				last;
			}
		}
		
	}

	if ($dtf->cmp($start, $end) < 0) {
		$dtf->span_se($start, $end);
	} else {
		undef;
	}
}

sub new {
	my ($class, $workinghours) = @_;
	die unless defined $workinghours;

	my $self = {
		workinghours => $workinghours,
		dtf => DateTimeFactory->new
	};
	bless $self, $class;
}

sub parse {
	my ($self, $text) = @_;
	my $tokens = _tokenize($text);
	if (defined $tokens) {
		my $today = $self->{dtf}->now;
		my $workinghours = _parse_workinghours($self->{workinghours}, $today);
		_parse_tokens($tokens, $today, $workinghours);
	} else {
		undef;
	}
}

1;

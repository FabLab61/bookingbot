use strict;
use warnings;

use Test::More tests => 2;

use lib "..";
use DateTimeFactory;
use RecordTimeParser;

my $dtf = DateTimeFactory->new("UTC");

my %data = (
	"russian" => [{
		"input" => "сегодня с 10:45 до 12",
		"tokens" => {
			day			=> "сегодня",
			preposition	=> "с",
			hours1		=> 10,
			minutes1	=> 45,
			hours2		=> 12,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-01T10:45-1970-01-01T12:00",
	}, {
		"input" => "завтра с 10 до 14",
		"tokens" => {
			day			=> "завтра",
			preposition	=> "с",
			hours1		=> 10,
			minutes1	=> 0,
			hours2		=> 14,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-02T10:00-1970-01-02T14:00",
	}, {
		"input" => "в пятницу с 15:20",
		"tokens" => {
			day			=> "пятницу",
			preposition	=> "с",
			hours1		=> 15,
			minutes1	=> 20,
			hours2		=> 0,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-02T15:20-1970-01-03T00:00",
	}, {
		"input" => "в чт после 18",
		"tokens" => {
			day			=> "чт",
			preposition	=> "после",
			hours1		=> 18,
			minutes1	=> 0,
			hours2		=> 0,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-01T18:00-1970-01-02T00:00",
	}, {
		"input" => "в сб до 13",
		"tokens" => {
			day			=> "сб",
			preposition	=> "до",
			hours1		=> 13,
			minutes1	=> 0,
			hours2		=> 0,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-03T08:00-1970-01-03T13:00",
	}, {
		"input" => "пн в 8",
		"tokens" => {
			day			=> "пн",
			preposition	=> "в",
			hours1		=> 8,
			minutes1	=> 0,
			hours2		=> 0,
			minutes2	=> 0,
		},

		"workinghours" => "10:00-00:00",
		"span" => "1970-01-05T08:00-1970-01-05T09:00",
	}, {
		"input" => "во вторник с 15 до 13",
		"tokens" => {
			day			=> "вторник",
			preposition	=> "с",
			hours1		=> 15,
			minutes1	=> 0,
			hours2		=> 13,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => undef,
	}]
);


sub _parse_workinghours {
	my ($workinghours, $begin) = @_;
	if($workinghours =~ m/\d{2}:\d{2}-\d{2}:\d{2}/g) {
		my $start = $begin->clone;
		$start->truncate(to => "day");
		$start->add(hours => $1 // 0, minutes => $2 // 0);

		my $end = $begin->clone;
		$end->truncate(to => "day");
		$end->add(hours => $3 // 0, minutes => $4 // 0);

		$dtf->span_se($start, $end);
	} else {
		undef;
	}
}

subtest "_tokenize (russian)" => sub {
	Localization::set_language("Russian");

	my $russian = $data{russian};
	foreach my $record (@$russian) {
		my $tokens = RecordTimeParser::_tokenize($record->{input});
		is_deeply($tokens, $record->{tokens}, $record->{input});
	}
};

subtest "_parse_tokens (russian)" => sub {
	Localization::set_language("Russian");

	my $begin = DateTime->from_epoch(epoch => 0);
	my $russian = $data{russian};
	foreach my $record (@$russian) {
		my $tokens = RecordTimeParser::_tokenize($record->{input});

		my $workinghours = _parse_workinghours(
			$record->{workinghours}, $begin);

		my $span = RecordTimeParser::_parse_tokens(
			$tokens, $begin, $workinghours);

		if (defined $span) {
			my $format = "%FT%R";
			my $startstr = $span->start->strftime($format);
			my $endstr = $span->end->strftime($format);
			my $spanstr = $startstr . "-" . $endstr;
			is_deeply($spanstr, $record->{span}, $record->{input});
		} else {
			is(undef, $record->{span}, $record->{input});
		}
	}
};

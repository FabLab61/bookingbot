use strict;
use warnings;
use utf8;

use Test::More tests => 2;

use lib "..";
use DateTimeFactory;
use RecordTimeParser;

# workaround for "wide character in print" error
my $builder = Test::More->builder;
binmode $builder->output,         ":encoding(utf8)";
binmode $builder->failure_output, ":encoding(utf8)";
binmode $builder->todo_output,    ":encoding(utf8)";

my $dtf = DateTimeFactory->new("UTC");

my %data = (
	"russian" => [{
		"input" => "сегодня с 10:00 до 12:30",
		"tokens" => {
			day			=> "сегодня",
			preposition	=> "с",
			hours1		=> 10,
			minutes1	=> 0,
			hours2		=> 12,
			minutes2	=> 30,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-01T10:00-1970-01-01T12:30",
	}, {
		"input" => "завтра с 8.15 до 9.45",
		"tokens" => {
			day			=> "завтра",
			preposition	=> "с",
			hours1		=> 8,
			minutes1	=> 15,
			hours2		=> 9,
			minutes2	=> 45,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-02T08:15-1970-01-02T09:45",
	}, {
		"input" => "в понедельник с 10-20 до 17-35",
		"tokens" => {
			day			=> "понедельник",
			preposition	=> "с",
			hours1		=> 10,
			minutes1	=> 20,
			hours2		=> 17,
			minutes2	=> 35,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-05T10:20-1970-01-05T17:35",
	}, {
		"input" => "во вт с 15 до 19-50",
		"tokens" => {
			day			=> "вт",
			preposition	=> "с",
			hours1		=> 15,
			minutes1	=> 0,
			hours2		=> 19,
			minutes2	=> 50,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-06T15:00-1970-01-06T19:50",
	}, {
		"input" => "сб с 11.10 до 19",
		"tokens" => {
			day			=> "сб",
			preposition	=> "с",
			hours1		=> 11,
			minutes1	=> 10,
			hours2		=> 19,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-03T11:10-1970-01-03T19:00",
	}, {
		"input" => "в среду с 9.30",
		"tokens" => {
			day			=> "среду",
			preposition	=> "с",
			hours1		=> 9,
			minutes1	=> 30,
			hours2		=> 0,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-07T09:30-1970-01-08T00:00",
	}, {
		"input" => "пятница после 16",
		"tokens" => {
			day			=> "пятница",
			preposition	=> "после",
			hours1		=> 16,
			minutes1	=> 0,
			hours2		=> 0,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-02T16:00-1970-01-03T00:00",
	}, {
		"input" => "вс до 14",
		"tokens" => {
			day			=> "вс",
			preposition	=> "до",
			hours1		=> 14,
			minutes1	=> 0,
			hours2		=> 0,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-04T08:00-1970-01-04T14:00",
	}, {
		"input" => "пн в 10:30",
		"tokens" => {
			day			=> "пн",
			preposition	=> "в",
			hours1		=> 10,
			minutes1	=> 30,
			hours2		=> 0,
			minutes2	=> 0,
		},

		"workinghours" => "08:00-00:00",
		"span" => "1970-01-05T10:30-1970-01-05T11:30",
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
	if($workinghours =~ m/(\d{2}):(\d{2})-(\d{2}):(\d{2})/g) {
		my $start = $begin->clone;
		$start->truncate(to => "day");
		$start->add(hours => $1 // 0, minutes => $2 // 0);

		my $end = $begin->clone;
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

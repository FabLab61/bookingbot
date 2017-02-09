use strict;
use warnings;

use Test::More tests => 2;

use TestUtils;

use ScheduleUtils;

subtest "vacancies" => sub {
	my $data = [{
		freespans => [
			["1970-01-01T10:00:00Z", "1970-01-01T11:00:00Z"],
			["1970-01-01T12:00:00Z", "1970-01-01T13:00:00Z"],
			["1970-01-01T14:00:00Z", "1970-01-01T15:00:00Z"],
		],
		busyspans => [
			["1970-01-01T10:00:00Z", "1970-01-01T10:30:00Z"],
			["1970-01-01T14:30:00Z", "1970-01-01T15:00:00Z"],
		],
		duration  => "00:30",

		expected => [
			["1970-01-01T10:30:00Z", "1970-01-01T11:00:00Z"],
			["1970-01-01T12:00:00Z", "1970-01-01T13:00:00Z"],
			["1970-01-01T14:00:00Z", "1970-01-01T14:30:00Z"],
		]
	}, {
		freespans => [
			["1970-01-01T10:00:00Z", "1970-01-01T11:00:00Z"],
			["1970-01-01T12:00:00Z", "1970-01-01T13:00:00Z"],
			["1970-01-01T14:00:00Z", "1970-01-01T15:00:00Z"],
		],
		busyspans => [
			["1970-01-01T10:00:00Z", "1970-01-01T10:30:00Z"],
			["1970-01-01T14:30:00Z", "1970-01-01T15:00:00Z"],
		],
		duration  => "01:00",

		expected => [
			["1970-01-01T12:00:00Z", "1970-01-01T13:00:00Z"],
		]
	}];

	foreach my $record (@$data) {
		my @free = map { TestUtils::parse_span($_) } @{$record->{freespans}};
		my @busy = map { TestUtils::parse_span($_) } @{$record->{busyspans}};
		my $duration = TestUtils::parse_dur($record->{duration});

		my $actual = ScheduleUtils::vacancies(\@free, \@busy, $duration);
		my @expected = map { TestUtils::parse_span($_) } @{$record->{expected}};

		is_deeply($actual, \@expected);
	}
};

subtest "schedule" => sub {
	my $data = [{
		freespans => [
			["1970-01-01T10:00:00Z", "1970-01-01T11:00:00Z"],
			["1970-01-01T12:00:00Z", "1970-01-01T13:00:00Z"],
			["1970-01-01T14:00:00Z", "1970-01-01T15:00:00Z"],
		],
		busyspans => [
			["1970-01-01T09:00:00Z", "1970-01-01T10:30:00Z"],
			["1970-01-01T14:30:00Z", "1970-01-01T16:00:00Z"],
		],

		expected => [
			{ span => ["1970-01-01T10:00:00Z", "1970-01-01T10:30:00Z"], busy => 1},
			{ span => ["1970-01-01T10:30:00Z", "1970-01-01T11:00:00Z"], busy => 0},
			{ span => ["1970-01-01T12:00:00Z", "1970-01-01T13:00:00Z"], busy => 0},
			{ span => ["1970-01-01T14:00:00Z", "1970-01-01T14:30:00Z"], busy => 0},
			{ span => ["1970-01-01T14:30:00Z", "1970-01-01T15:00:00Z"], busy => 1},
		]
	}];

	foreach my $record (@$data) {
		my @free = map { TestUtils::parse_span($_) } @{$record->{freespans}};
		my @busy = map { TestUtils::parse_span($_) } @{$record->{busyspans}};

		my $actual = ScheduleUtils::schedule(\@free, \@busy);
		my @expected = map {{
			span => TestUtils::parse_span($_->{span}),
			busy => $_->{busy}
		}} @{$record->{expected}};

		is_deeply($actual, \@expected);
	}
};

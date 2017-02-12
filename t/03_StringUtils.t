use strict;
use warnings;

use Test::More tests => 2;

use StringUtils;

subtest "trim" => sub {
	my $data = [
		{ input => "", expected => ""},
		{ input => "test test", expected => "test test"},
		{ input => " test test", expected => "test test"},
		{ input => "test test ", expected => "test test"},
		{ input => " test test ", expected => "test test"},
	];

	foreach my $record (@$data) {
		my $actual = StringUtils::trim($record->{input});
		my $expected = $record->{expected};
		is($actual, $expected);
	}
};

subtest "split" => sub {
	my $data = [{
		input => "test",
		expected => ["test"]
	}, {
		input => "test1, test2\ntest3,\ntest4\n,\n\n",
		expected => ["test1", "test2", "test3", "test4"]
	}];

	foreach my $record (@$data) {
		my $actual = StringUtils::split($record->{input});
		my $expected = $record->{expected};
		is_deeply($actual, $expected);
	}
};

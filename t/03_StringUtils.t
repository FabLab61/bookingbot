use strict;
use warnings;

use Test::More tests => 1;

use TestUtils;

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

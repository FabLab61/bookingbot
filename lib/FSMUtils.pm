package FSMUtils;

use strict;
use warnings;

sub _with_text {
	my ($update, $callback) = @_;
	defined $update
		and defined $update->{message}
		and defined $update->{message}->{text}
		? $callback->($update->{message}->{text})
		: undef
}

sub _parse_value {
	my ($state, $parser, @data) = @_;

	my $parsed = $parser->(@data);
	if (defined $parsed) {
		$state->result($parsed);
	}

	defined $parsed;
}

1;

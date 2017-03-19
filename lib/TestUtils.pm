package TestUtils;

use strict;
use warnings;
use utf8;

use DateTimeFactory;

my $dtf = DateTimeFactory->new("UTC");

sub span2str {
	my ($span) = @_;
	my $format = "%FT%R";
	my $startstr = $span->start->strftime($format);
	my $endstr = $span->end->strftime($format);
	$startstr . "-" . $endstr;
}


sub parse_span {
	my ($strpair) = @_;
	$dtf->span_se(
		$dtf->parse_rfc3339($strpair->[0]),
		$dtf->parse_rfc3339($strpair->[1]));
}

sub parse_dur {
	my ($inputstr) = @_;
	if ($inputstr =~ m/(\d{2}):(\d{2})/g) {
		$dtf->dur(hours => $1 // 0, minutes => $2 // 0);
	} else {
		undef;
	}
}

1;

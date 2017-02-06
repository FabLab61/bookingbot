package DumperUtils;

use strict;
use warnings;

sub span2str {
	my ($span) = @_;
	($span->start_is_closed ? "[" : "(") . $span->start->datetime . " .. " .
		$span->end->datetime . ($span->end_is_closed ? "]" : ")");
}

sub human_readable_spans {
	my ($spans) = @_;
	my @result = map { span2str($_) } @$spans;
	\@result;
}

sub human_readable_events {
	my ($events) = @_;

	my @result = map {{
		summary => $_->{summary} // "undef",
		transparent => $_->{transparent} // "undef",
		span => span2str($_->{span}),
	}} @$events;

	\@result;
}

1;

package StringUtils;

use strict;
use warnings;
use utf8;

sub trim {
	my ($inputstr) = @_;
	$inputstr =~ s/^\s+|\s+$//g;
	$inputstr;
}

sub split {
	my ($inputstr) = @_;
	my @result = grep { length $_ > 0 }
		map { trim($_) }
		split(/[\n,]/, $inputstr);
	\@result;
}

1;

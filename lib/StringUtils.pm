package StringUtils;

use strict;
use warnings;

sub trim {
	my ($inputstr) = @_;
	$inputstr =~ s/^\s+|\s+$//g;
	$inputstr;
}

1;

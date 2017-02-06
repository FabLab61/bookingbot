package BaseFSM;

use strict;
use warnings;

sub next {
	my ($self, $update) = @_;
	my $last_message;
	do {
		$self->{fsa}->switch($update);
		$last_message = $self->{fsa}->last_message;
	} while (defined $last_message and $last_message eq "transition")
}

1;

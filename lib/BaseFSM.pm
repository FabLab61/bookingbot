package BaseFSM;

use strict;
use warnings;
use utf8;

sub next {
	my ($self, $update) = @_;
	my $last_message;
	do {
		$self->{fsa}->switch($update);
		$last_message = $self->{fsa}->last_message;
	} while (defined $last_message && $last_message eq "transition")
}

=method debug

Return names of states that the machine has been in

Extremelly useful for debugging FSM states, finding wrong transitions and loops

https://metacpan.org/pod/FSA::Rules#stack

=cut

sub debug_states {
	my $self = shift;
	$self->{fsa}->stack;
}

1;

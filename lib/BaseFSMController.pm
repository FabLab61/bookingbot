package BaseFSMController;

use strict;
use warnings;
use utf8;

use Localization qw(lz);

sub new {
	my ($class, $chat_id, $api) = @_;

	my $self = {
		chat_id => $chat_id,
		api => $api,
		dtf => DateTimeFactory->new,
	};

	bless $self, $class;
}

=method transition

Depends on current $state (type = L<FSA::Rules> object) and income $message (type = string)

L<https://metacpan.org/pod/FSA::Rules#message1>


=cut

sub transition {
	my ($self, $state, $message) = @_;
	$state->message("transition");
	if (defined $message) {
		$self->send_message($message);
	}
}

sub is_transition {
	my ($self, $state) = @_;
	my $message = $state->message;
	$message && $message eq "transition";
}

sub send_message {
	my ($self, $text) = @_;
	$self->{api}->send_message({
		chat_id => $self->{chat_id},
		text => $text
	});
}

sub send_keyboard {
	my ($self, $text, $keyboard) = @_;
	$self->{api}->send_keyboard({
		chat_id => $self->{chat_id},
		text => $text,
		keyboard => $keyboard
	});
}

sub remove_keyboard {
	my ($self, $text) = @_;
	$self->{api}->remove_keyboard({
		chat_id => $self->{chat_id},
		text => $text
	});
}

sub rule_back {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub { shift eq lz("back"); });
}

sub rule_cancel {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub { shift eq lz("cancel"); });
}

sub rule_help {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub { shift eq lz("help"); });
}

1;

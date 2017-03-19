package BaseFSMController;

use Mojo::Base -strict;
use Localization qw(lz);

has 'chat_id';
has 'api';
has 'dtf' => sub { DateTimeFactory->new };

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
	$self->api->send_message({
		chat_id => $self->chat_id,
		text => $text
	});
}

sub send_keyboard {
	my ($self, $text, $keyboard) = @_;
	$self->api->send_keyboard({
		chat_id => $self->chat_id,
		text => $text,
		keyboard => $keyboard
	});
}

sub remove_keyboard {
	my ($self, $text) = @_;
	$self->api->remove_keyboard({
		chat_id => $self->chat_id,
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

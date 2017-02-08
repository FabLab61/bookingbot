package BaseFSMController;

use strict;
use warnings;

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

sub transition {
	my ($self, $state, $message) = @_;
	$state->message("transition");
	if (defined $message) {
		$self->send_message($message);
	}
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

sub rule_back {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub { shift eq lz("back"); });
}

sub rule_cancel {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub { shift eq lz("cancel"); });
}

1;

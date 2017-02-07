package BaseFSMController;

use strict;
use warnings;

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
	my ($self, $state) = @_;
	$state->message("transition");
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

1;

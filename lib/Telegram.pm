package Telegram;


package Telegram::BotAPI;

use strict;
use warnings;

use Try::Tiny qw(try catch);
use WWW::Telegram::BotAPI;

use lib "serikoff.lib";
use Serikoff::Telegram::Keyboards qw(create_one_time_keyboard);
use Serikoff::Telegram::Polling qw(get_last_messages);

use Log;

BEGIN { $ENV{TELEGRAM_BOTAPI_DEBUG} = 1 };

sub new {
	my ($class, $token) = @_;
	my $self = {
		api => WWW::Telegram::BotAPI->new(token => $token),
		log => Log->new("telegram_botapi")
	};
	bless $self, $class;
}

sub my_id {
	my ($self) = @_;
	my $me = $self->{api}->getMe;
	$self->{log}->debugf("me: %s", $me);
	$me->{result}->{id};
}

sub last_messages {
	my ($self) = @_;
	my $result = {};
	try {
		$result = get_last_messages($self->{api});
	}
}

sub send_message {
	my ($self, $params) = @_;
	$self->{api}->sendMessage($params);
	$self->{log}->debugf("message sent: %s", $params);
}

sub send_keyboard {
	my ($self, $params) = @_;
	$self->{api}->sendMessage({
		chat_id => $params->{chat_id},
		text => $params->{text},
		reply_markup => create_one_time_keyboard($params->{keyboard}, 1)
	});
	$self->{log}->debugf("keyboard sent: %s", $params);
}

sub send_contact {
	my ($self, $params) = @_;
	$self->{api}->sendContact({chat_id => $params->{chat_id},
		phone_number => $params->{contact}->{phone_number},
		first_name => $params->{contact}->{first_name},
		last_name => $params->{contact}->{last_name}
	});
	$self->{log}->debugf("contact sent: %s", $params);
}

1;

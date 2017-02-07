#!/usr/bin/env perl

package BookingBot;

use common::sense;
use File::Basename qw(dirname);
use Mojolicious::Lite;

use lib "lib/";

use FSMFactory;
use Google;
use Groups;
use Localization ();
use Log;
use Telegram;

$| = 1; # disable buffering

my $jsonconfig = plugin "JSONConfig";

DateTimeFactory::set_default_timezone($jsonconfig->{timezone});
Localization::set_language($jsonconfig->{language});

my $api = Telegram::BotAPI->new($jsonconfig->{token});
my $groups = Groups->new($api->my_id);
my $fsmfactory = FSMFactory->new($api, $groups, $jsonconfig);

my $log = Log->new();
my %machines = ();

Google::CalendarAPI::auth(dirname(__FILE__) . "/gapi.conf", "fablab61ru\@gmail.com");


$log->infof("ready to process incoming messages");

while (1) {
	my $hash = $api->last_messages();
	while (my ($chat_id, $update) = each(%$hash)) {
		Log::incsid;

		if (not defined $update
				or not defined $update->{message}
				or not defined $update->{message}->{from}) {
			$log->infof("unknown update - ignored");
		} elsif ($chat_id ne $update->{message}->{from}->{id}) {
			if (defined $update->{message}->{new_chat_participant}
					or defined $update->{message}->{left_chat_participant}) {
				$groups->process($update->{message});
				$log->infof("group message processed");
			} else {
				$log->infof("non-private message ignored");
			}
		} else {
			my $user = $update->{message}->{from};
			$log->infof("new message: %s", $update->{message});

			if (not exists $machines{$chat_id}) {
				$machines{$chat_id} = $fsmfactory->create($user, $chat_id);
				$log->infof("finite state machine created");
			}

			$machines{$chat_id}->next($update);
			$log->infof("moved to next state");
		}

		$log->infof("message processing finished");
	}

	sleep 1;
}

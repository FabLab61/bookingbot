use strict;
use warnings;

use Test::More tests => 1;

use Test::MockObject;
use UserFSM;

subtest "UserFSM" => sub {
	my $mock = Test::MockObject->new();
	$mock->set_false(
		"send_start_message",
		"send_contact_message",
		"send_contact_failed",
		"send_begin_message",
		"send_resources"
	);

	my $fsm = UserFSM->new($mock);
	$mock->called_ok("send_start_message");

	$mock->clear();
	$fsm->next();
	$mock->called_ok("send_contact_message");

	$mock->clear();
	$fsm->next();
	$mock->called_ok("send_contact_failed");
	$mock->called_ok("send_contact_message");

	$mock->clear();
	$fsm->next({ message => { text => "/start" }});
	$mock->called_ok("send_start_message");
	$mock->called_ok("send_contact_message");

	$mock->clear();
	$fsm->next({ message => { text => "/cancel" }});
	$mock->called_ok("send_start_message");
	$mock->called_ok("send_contact_message");

	$mock->clear();
	$mock->set_always("save_contact", undef);
	$fsm->next({ message => { contact => 0 }});
	$mock->called_ok("save_contact");
	$mock->called_ok("send_contact_failed");
	$mock->called_ok("send_contact_message");

	$mock->clear();
	$mock->set_always("save_contact", 1);
	$fsm->next({ message => { contact => 0 }});
	$mock->called_ok("save_contact");
	$mock->called_ok("send_begin_message");
	$mock->called_ok("send_resources");
};

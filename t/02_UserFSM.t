use strict;
use warnings;

use Test::More tests => 1;

use Test::MockObject;
use UserFSM;

sub _calls_ok {
	my ($fsm, $nextarg, $mock, $calls) = @_;

	$mock->clear();
	$fsm->next($nextarg);

	for(my $i = 0; $i < scalar @$calls; $i++) {
		$mock->called_pos_ok($i + 1, $calls->[$i]);
	}
}

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

	_calls_ok($fsm, undef, $mock, ["send_contact_message"]);

	_calls_ok($fsm, undef, $mock, [
			"send_contact_failed",
			"send_contact_message"]);

	_calls_ok($fsm, { message => { text => "/start" }}, $mock, [
			"send_start_message",
			"send_contact_message"]);

	_calls_ok($fsm, { message => { text => "/cancel" }}, $mock, [
			"send_start_message",
			"send_contact_message"]);

	$mock->set_always("save_contact", undef);
	_calls_ok($fsm, { message => { contact => 0 }}, $mock, [
			"save_contact",
			"send_contact_failed",
			"send_contact_message"]);

	$mock->set_always("save_contact", 1);
	_calls_ok($fsm, { message => { contact => 0 }}, $mock, [
			"save_contact",
			"send_begin_message",
			"send_resources"]);
};

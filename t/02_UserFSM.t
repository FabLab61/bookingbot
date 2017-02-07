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

		"send_resource_not_found",
		"send_resource_failed",

		"send_duration_not_found",

		"send_refresh"
	);

	my $fsm = UserFSM->new($mock);
	$mock->called_ok("send_start_message");

	_calls_ok($fsm, undef, $mock, ["send_contact_message"]);

	_calls_ok($fsm, undef, $mock, [
			"send_contact_failed",
			"send_contact_message"]);

	_calls_ok($fsm, { message => { text => "abracadabra" }}, $mock, [
			"send_contact_failed",
			"send_contact_message"]);

	_calls_ok($fsm, { message => { text => "/cancel" }}, $mock, [
			"send_start_message",
			"send_contact_message"]);

	_calls_ok($fsm, { message => { text => "/start" }}, $mock, [
			"send_start_message",
			"send_contact_message"]);

	$mock->set_always("save_contact", undef);
	_calls_ok($fsm, { message => { contact => 1 }}, $mock, [
			"save_contact",
			"send_contact_failed",
			"send_contact_message"]);

	$mock->set_always("save_contact", 1);
	$mock->set_always("send_resources", undef);
	_calls_ok($fsm, { message => { contact => 1 }}, $mock, [
			"save_contact",
			"send_begin_message",
			"send_resources",
			"send_resource_not_found",
			"send_refresh"]);

	$mock->set_always("send_resources", 1);
	_calls_ok($fsm, undef, $mock, [
			"send_begin_message",
			"send_resources"]);

	_calls_ok($fsm, undef, $mock, [
			"send_resource_failed",
			"send_resources"]);

	$mock->set_always("get_resource_parser", sub { undef; });
	_calls_ok($fsm, { message => { text => "abracadabra" }}, $mock, [
			"get_resource_parser",
			"send_resource_failed",
			"send_resources"]);

	_calls_ok($fsm, { message => { text => "/cancel" }}, $mock, [
			"get_resource_parser",
			"send_begin_message",
			"send_resources"]);

	_calls_ok($fsm, { message => { text => "/start" }}, $mock, [
			"get_resource_parser",
			"send_begin_message",
			"send_resources"]);

	$mock->set_always("get_resource_parser", sub { 1; });
	$mock->set_always("send_durations", undef);
	_calls_ok($fsm, { message => { text => "abracadabra" }}, $mock, [
			"get_resource_parser",
			"send_durations",
			"send_duration_not_found",
			"send_refresh"]);
};

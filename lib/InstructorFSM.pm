package InstructorFSM;

use strict;
use warnings;

use FSA::Rules;

use FSMUtils;

use parent ("BaseFSM");

sub new {
	my ($class, $controller) = @_;

	my $self = {
		fsa => FSA::Rules->new(
			START => {
				# init machine here
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_start_message();
				},
				rules => [MENU => 1],
			},

			CANCEL => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_cancel_message();
				},
				rules => [MENU => 1],
			},

			MENU => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_menu();
				},
				rules => [SILENT_MENU => 1],
			},

			SILENT_MENU => {
				rules => [
					SCHEDULE => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							$controller->is_schedule_selected($text);
						});
					},

					RECORD => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							$controller->is_add_record_selected($text);
						});
					},

					MENU => \&FSMUtils::_start,

					SILENT_MENU => 1,
				],
			},

			SCHEDULE => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_schedule();
				},
				rules => [MENU => 1],
			},

			RECORD => {
				do => sub {
					my ($state) = @_;
					$controller->ask_record_time();
				},
				rules => [
					CANCEL => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							$controller->is_cancel_operation_selected($text);
						});
					},

					RECORD_DONE => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							FSMUtils::_parse_value( $state,
								sub { $controller->parse_record_time(@_); },
								$text);
						});
					},

					RECORD_FAILED => 1
				],
			},

			RECORD_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->ask_record_time_failed();
				},
				rules => [RECORD => 1],
			},

			RECORD_DONE => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");

					my $machine = $state->machine;
					my $record = $machine->last_result("RECORD");

					$controller->save_record($record);
				},
				rules => [MENU => 1],
			},
		)
	};

	bless $self, $class;
	$self->{fsa}->start();
	$self;
}

1;

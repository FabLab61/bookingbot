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

					RESOURCE => sub {
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

			RESOURCE => {
				do => sub {
					my ($state) = @_;
					if (not defined $controller->send_resources()) {
						$state->message("transition");
						$state->result(undef);
					} else {
						$state->result(1);
					}
				},
				rules => [
					RESOURCE_NOT_FOUND => sub {
						my ($state) = @_;
						not defined $state->result;
					},

					TIME => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							FSMUtils::_parse_value($state,
								sub { $controller->parse_resource(@_); },
								$text);
						});
					},

					CANCEL => \&FSMUtils::_start,
					CANCEL => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							$controller->is_cancel_operation_selected($text);
						});
					},

					RESOURCE_FAILED => 1
				],
			},

			RESOURCE_NOT_FOUND => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_resource_not_found();
				},
				rules => [MENU => 1],
			},

			RESOURCE_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_resource_failed();
				},
				rules => [RESOURCE => 1],
			},

			TIME => {
				do => sub {
					my ($state) = @_;
					$controller->send_time_request();
				},
				rules => [
					CANCEL => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							$controller->is_cancel_operation_selected($text);
						});
					},

					RECORD => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							FSMUtils::_parse_value($state,
								sub { $controller->parse_record_time(@_); },
								$text);
						});
					},

					TIME_FAILED => 1
				],
			},

			TIME_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_time_failed();
				},
				rules => [TIME => 1],
			},

			RECORD => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");

					my $machine = $state->machine;
					my $resource = $machine->last_result("RESOURCE");
					my $time = $machine->last_result("TIME");

					$controller->save_record($resource, $time);
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

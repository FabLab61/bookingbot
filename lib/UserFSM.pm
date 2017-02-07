package UserFSM;

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
				rules => [CONTACT => 1],
			},

			CONTACT => {
				do => sub { $controller->send_contact_message(); },
				rules => [
					BEGIN => sub {
						my ($state, $update) = @_;
						my $contact = $update->{message}->{contact};
						if (defined $contact) {
							$controller->save_contact($contact);
						}
					},

					START => \&FSMUtils::_start,
					START => \&FSMUtils::_cancel,

					CONTACT_FAILED => 1
				],
			},

			CONTACT_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_contact_failed();
				},
				rules => [CONTACT => 1],
			},

			BEGIN => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_begin_message();
				},
				rules => [RESOURCE => 1],
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

					DURATION => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							FSMUtils::_parse_value($state,
								$controller->get_resource_parser(), $text);
						});
					},

					BEGIN => \&FSMUtils::_start,
					CANCEL => \&FSMUtils::_cancel,

					RESOURCE_FAILED => 1
				],
			},

			RESOURCE_NOT_FOUND => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_resource_not_found();
				},
				rules => [REFRESH => 1],
			},

			RESOURCE_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_resource_failed();
				},
				rules => [RESOURCE => 1],
			},

			DURATION => {
				do => sub {
					my ($state) = @_;

					my $machine = $state->machine;
					my $resource = $machine->last_result("RESOURCE");

					if (not defined $controller->send_durations($resource)) {
						$state->message("transition");
						$state->result(undef);
					} else {
						$state->result(1);
					}
				},
				rules => [
					DURATION_NOT_FOUND => sub {
						my ($state) = @_;
						not defined $state->result;
					},

					DATETIME => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							FSMUtils::_parse_value(
									$state,
									$controller->parse_duration,
									$text);
						});
					},

					BEGIN => \&FSMUtils::_start,
					CANCEL => \&FSMUtils::_cancel,

					DURATION_FAILED => 1
				],
			},

			DURATION_NOT_FOUND => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_duration_not_found();
				},
				rules => [REFRESH => 1],
			},

			DURATION_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_duration_failed();
				},
				rules => [DURATION => 1],
			},

			DATETIME => {
				do => sub {
					my ($state) = @_;

					my $machine = $state->machine;
					my $resource = $machine->last_result("RESOURCE");
					my $duration = $machine->last_result("DURATION");

					$controller->send_datetime_selector($resource, $duration);
				},
				rules => [
					INSTRUCTOR => sub {
						my ($state, $update) = @_;
						FSMUtils::_with_text($update, sub {
							my ($text) = @_;
							FSMUtils::_parse_value($state,
								$controller->parse_datetime, $text);
						});
					},

					BEGIN => \&FSMUtils::_start,
					CANCEL => \&FSMUtils::_cancel,

					DATETIME_FAILED => 1
				],
			},

			DATETIME_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_datetime_failed();
				},
				rules => [DATETIME => 1],
			},

			INSTRUCTOR => {
				do => sub { shift->message("transition"); },
				rules => [
					BOOK => sub {
						my ($state) = @_;

						my $machine = $state->machine;
						my $resource = $machine->last_result("RESOURCE");
						my $datetime = $machine->last_result("DATETIME");
						my $duration = $machine->last_result("DURATION");

						FSMUtils::_parse_value(
								$state,
								$controller->parse_instructor,
								$resource,
								$datetime,
								$duration);
					},
					INSTRUCTOR_FAILED => 1
				],
			},

			INSTRUCTOR_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$controller->send_instructor_failed();
				},
				rules => [DATETIME => 1],
			},

			BOOK => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");

					my $machine = $state->machine;
					my $resource = $machine->last_result("RESOURCE");
					my $datetime = $machine->last_result("DATETIME");
					my $duration = $machine->last_result("DURATION");
					my $instructor = $machine->last_result("INSTRUCTOR");

					$controller->book(
							$resource,
							$datetime,
							$duration,
							$instructor);
				},
				rules => [BEGIN => 1],
			},

			CANCEL => {
				do => sub { shift->message("transition"); },
				rules => [BEGIN => 1],
			},

			REFRESH => {
				do => sub {
					my ($state) = @_;
					$controller->send_refresh();
				},
				rules => [BEGIN => 1],
			},
		)
	};

	bless $self, $class;
	$self->{fsa}->start();
	$self;
}

1;

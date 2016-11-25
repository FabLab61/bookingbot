package UserFSM;

use strict;
use warnings;

use FSA::Rules;

sub new {
	my ($class, %callbacks) = @_;

	my $self = {
		fsa => FSA::Rules->new(
			START => {
				# init machine here
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_start_message}();
				},
				rules => [CONTACT => 1],
			},

			CONTACT => {
				do => sub { $callbacks{send_contact_message}(); },
				rules => [
					BEGIN => sub {
						my ($state, $update) = @_;
						my $contact = $update->{message}->{contact};
						if (defined $contact) {
							$callbacks{save_contact}($contact);
						}
					},

					START => \&_start,
					START => \&_cancel,

					CONTACT_FAILED => 1
				],
			},

			CONTACT_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_contact_failed}();
				},
				rules => [CONTACT => 1],
			},

			BEGIN => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_begin_message}();
				},
				rules => [RESOURCE => 1],
			},

			RESOURCE => {
				do => sub {
					my ($state) = @_;
					if (not defined $callbacks{send_resources}()) {
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
						_with_text($update, sub {
							my ($text) = @_;
							_parse_value($state,
								$callbacks{parse_resource}, $text);
						});
					},

					BEGIN => \&_start,
					CANCEL => \&_cancel,

					RESOURCE_FAILED => 1
				],
			},

			RESOURCE_NOT_FOUND => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_resource_not_found}();
				},
				rules => [REFRESH => 1],
			},

			RESOURCE_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_resource_failed}();
				},
				rules => [RESOURCE => 1],
			},

			DURATION => {
				do => sub {
					my ($state) = @_;

					my $machine = $state->machine;
					my $resource = $machine->last_result("RESOURCE");

					if (not defined $callbacks{send_durations}($resource)) {
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
						_with_text($update, sub {
							my ($text) = @_;
							_parse_value($state,
								$callbacks{parse_duration}, $text);
						});
					},

					BEGIN => \&_start,
					CANCEL => \&_cancel,

					DURATION_FAILED => 1
				],
			},

			DURATION_NOT_FOUND => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_duration_not_found}();
				},
				rules => [REFRESH => 1],
			},

			DURATION_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_duration_failed}();
				},
				rules => [DURATION => 1],
			},

			DATETIME => {
				do => sub {
					my ($state) = @_;

					my $machine = $state->machine;
					my $resource = $machine->last_result("RESOURCE");
					my $duration = $machine->last_result("DURATION");

					$callbacks{send_datetime_selector}($resource, $duration);
				},
				rules => [
					INSTRUCTOR => sub {
						my ($state, $update) = @_;
						_with_text($update, sub {
							my ($text) = @_;
							_parse_value($state,
								$callbacks{parse_datetime}, $text);
						});
					},

					BEGIN => \&_start,
					CANCEL => \&_cancel,

					DATETIME_FAILED => 1
				],
			},

			DATETIME_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_datetime_failed}();
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

						_parse_value($state, $callbacks{parse_instructor},
							$resource, $datetime, $duration);
					},
					INSTRUCTOR_FAILED => 1
				],
			},

			INSTRUCTOR_FAILED => {
				do => sub {
					my ($state) = @_;
					$state->message("transition");
					$callbacks{send_instructor_failed}();
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

					$callbacks{book}(
						$resource, $datetime, $duration, $instructor);
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
					$callbacks{send_refresh}();
				},
				rules => [BEGIN => 1],
			},
		)
	};

	bless $self, $class;
	$self->{fsa}->start();
	$self;
}

sub next {
	my ($self, $update) = @_;
	my $last_message;
	do {
		$self->{fsa}->switch($update);
		$last_message = $self->{fsa}->last_message;
	} while (defined $last_message and $last_message eq "transition")
}

sub _with_text {
	my ($update, $callback) = @_;
	defined $update
		and defined $update->{message}
		and defined $update->{message}->{text}
		? $callback->($update->{message}->{text})
		: undef
}

sub _start {
	my ($state, $update) = @_;
	_with_text($update, sub { shift eq "/start"; });
}

sub _cancel {
	my ($state, $update) = @_;
	_with_text($update, sub { shift eq "/cancel"; });
}

sub _parse_value {
	my ($state, $parser, @data) = @_;

	my $parsed = $parser->(@data);
	if (defined $parsed) {
		$state->result($parsed);
	}

	defined $parsed;
}

1;
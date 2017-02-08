package InstructorFSMController;

use strict;
use warnings;

use FSMUtils;
use Localization qw(lz dt);

use DumperUtils; # TODO: remove (see also do_record method)

use parent ("BaseFSMController");

sub new {
	my ($class, $user,
		$chat_id, $api,
		$instructors, $resources, $recordtimeparser) = @_;

	my $self = $class->SUPER::new($chat_id, $api);
	$self->{user} = $user;
	$self->{instructors} = $instructors;
	$self->{resources} = $resources;
	$self->{recordtimeparser} = $recordtimeparser;
	$self->{log} = Log->new("instructorfsmcontroller");

	$self;
}

sub _rule_cancel {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub {
		my ($text) = @_;
		$text eq lz("instructor_cancel_operation");
	});
}

################################################################################
# START

sub do_start {
	my ($self, $state) = @_;
	$self->transition($state, lz("instructor_start"));
}

################################################################################
# CANCEL

sub do_cancel {
	my ($self, $state) = @_;
	$self->transition($state, lz("instructor_operation_cancelled"));
}

################################################################################
# MENU

sub do_menu {
	my ($self, $state) = @_;
	$self->transition($state);
	my @keyboard = (
		lz("instructor_show_schedule"),
		lz("instructor_add_record"),
	);
	$self->send_keyboard(lz("instructor_menu"), \@keyboard);
}

sub silent_menu_rule_schedule {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub { shift eq lz("instructor_show_schedule"); });
}

sub silent_menu_rule_resource {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub { shift eq lz("instructor_add_record"); });
}

################################################################################
# SCHEDULE

sub do_schedule {
	my ($self, $state) = @_;
	$self->transition($state, lz("instructor_schedule"));

	my $instructor = $self->{instructors}->name($self->{user}->{id});
	my $schedule = $self->{resources}->schedule($instructor);

	my $text = "";
	foreach my $resource (keys %$schedule) {
		$text .= $resource . ":\n";
		foreach my $event (@{$schedule->{$resource}}) {
			$text .= dt($event->{span}->start) . " - ";
			$text .= dt($event->{span}->end) . ": ";
			$text .= ($event->{busy} ? lz("busy") : lz("free")) . "\n";
		}
	}

	if ($text eq "") {
		$text = lz("instructor_schedule_is_empty");
	}

	$self->send_message($text);
}

################################################################################
# RESOURCE

sub do_resource {
	my ($self, $state) = @_;
	my @keyboard = @{$self->{resources}->names};
	if (@keyboard) {
		push @keyboard, lz("instructor_cancel_operation");
		$self->send_keyboard(lz("instructor_select_resource"), \@keyboard);
		$state->result(1);
	} else {
		$self->transition($state);
		$state->result(undef);
	}
}

sub resource_rule_resource_not_found {
	my ($self, $state) = @_;
	not defined $state->result;
}

sub resource_rule_time {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub {
		FSMUtils::_parse_value($state, sub {
			my ($name) = @_;
			$self->{resources}->exists($name) ? $name : undef;
		}, shift);
	});
}

sub resource_rule_cancel {
	my ($self, $state, $update) = @_;
	$self->_rule_cancel($state, $update);
}

################################################################################
# RESOURCE_NOT_FOUND

sub do_resource_not_found {
	my ($self, $state) = @_;
	$self->transition($state, lz("instructor_resource_not_found"));
}

################################################################################
# RESOURCE_FAILED

sub do_resource_failed {
	my ($self, $state) = @_;
	$self->transition($state, lz("invalid_resource"));
}

################################################################################
# TIME

sub do_time {
	my ($self, $state) = @_;
	my @keyboard = (
		lz("instructor_cancel_operation"),
	);
	$self->send_keyboard(lz("instructor_time"), \@keyboard);
}

sub time_rule_cancel {
	my ($self, $state, $update) = @_;
	$self->_rule_cancel($state, $update);
}

sub time_rule_record {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub {
		FSMUtils::_parse_value($state, sub {
			$self->{recordtimeparser}->parse(shift);
		}, shift);
	});
}

################################################################################
# TIME_FAILED

sub do_time_failed {
	my ($self, $state) = @_;
	$self->transition($state, lz("invalid_time"));
}

################################################################################
# RECORD

sub do_record {
	my ($self, $state) = @_;
	$self->transition($state);

	my $machine = $state->machine;
	my $resource = $machine->last_result("RESOURCE");
	my $time = $machine->last_result("TIME");

	$self->send_message($resource);
	$self->send_message(DumperUtils::span2str($time));
}

################################################################################

1;

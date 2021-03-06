package InstructorFSMController;

use strict;
use warnings;
use utf8;

use FSMUtils;
use Localization qw(lz dt);
use StringUtils;

use parent ("BaseFSMController");

use Data::Dumper;

sub new {
	my ($class, $user,
		$chat_id, $api,
		$instructors, $resources, $recordtimeparser) = @_;

	my $self = $class->SUPER::new($chat_id, $api);
	$self->{instructor} = $instructors->name($user->{id});  ## instructor ID. now it's GMail address.
	$self->{resources} = $resources;
	$self->{recordtimeparser} = $recordtimeparser;
	$self->{log} = Log->new("instructorfsmcontroller");

	$self;
}



# All first $state arguments are FSA::State object


################################################################################
# START

sub do_start {
	my ($self, $state) = @_;
	$self->transition($state);
	$self->remove_keyboard(lz("instructor_start"));
}

################################################################################
# CANCEL

sub do_cancel {
	my ($self, $state) = @_;
	$self->transition($state, lz("operation_cancelled"));
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

=method silent_menu_rule_schedule

Return true if text from update is equal to instructor_show_schedule in needed locale

Can also return undef if update is not good structure

Needed to hide menu keyboard

=cut 

sub silent_menu_rule_schedule {
	my ($self, $state, $update) = @_;
	warn $update->{message}{text}; # must be "📒 Show my schedule"   ð Show my schedule
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
	warn "Debug : ".(caller(0))[3]." params :".ref($state);

	$self->transition($state, lz("instructor_schedule"));

	my $instructor = $self->{instructor};
	my $schedule = $self->{resources}->schedule($instructor); # return of schedule() from Resource.pm. Return hash

	# warn "Schedule : ".ref($schedule);
	# warn "Instructor : ".ref($instructor);

	warn "do_schedule() Instructor object".Dumper $instructor;
	warn "do_schedule() schedule".Dumper  $schedule;

	my $text = "";
	foreach my $resource (sort { $a cmp $b } keys %$schedule) {
		$text .= $resource . ":\n";
		foreach my $event (@{$schedule->{$resource}}) {
			$text .= dt($event->{span}->start) . " - ";
			$text .= dt($event->{span}->end) . ": ";
			$text .= $event->{busy}
				? lz("instructor_busy")
				: lz("instructor_free");
			$text .= "\n";
		}
	}

	if ($text eq "") {
		$text = lz("instructor_schedule_is_empty");
	}

	$self->send_message($text);
}

################################################################################
# SCHEDULE_REMOVE

sub _schedule_keyboard {
	my ($schedule) = @_;

	my %result = ();
	foreach my $resource (keys %$schedule) {
		foreach my $event (grep { not $_->{busy} } @{$schedule->{$resource}}) {
			my $start = dt($event->{span}->start);
			my $end = dt($event->{span}->end);
			my $key = $resource . ": " . $start .  " - " . $end;
			$result{$key} = {
				resource => $resource,
				span => $event->{span},
			};
		}
	}

	\%result;
}

sub _schedule_item {
	my ($self, $text) = @_;
	my $instructor = $self->{instructor};
	my $schedule = $self->{resources}->schedule($instructor);
	my $keyboard = _schedule_keyboard($schedule);
	$keyboard->{$text};
}

sub do_schedule_remove {
	my ($self, $state) = @_;

	my $instructor = $self->{instructor};
	my $schedule = $self->{resources}->schedule($instructor);
	my @keyboard = sort { $a cmp $b } keys %{_schedule_keyboard($schedule)};

	if (scalar @keyboard) {
		push @keyboard, lz("cancel");
		$self->send_keyboard(lz("instructor_remove_record"), \@keyboard);
	} else {
		$self->transition($state);
	}
}

sub schedule_remove_rule_cancel {
	my ($self, $state, $update) = @_;
	$self->is_transition($state) ? undef : $self->rule_cancel($state, $update);
}

sub schedule_remove_rule_schedule_remove_failed {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub {
		my $item = $self->_schedule_item(shift);
		!$self->is_transition($state) && !defined $item;
	});
}

sub schedule_remove_rule_schedule_remove_done {
	my ($self, $state, $update) = @_;
	if ($self->is_transition($state)) {
		undef;
	} else {
		FSMUtils::_with_text($update, sub {
			my $item = $self->_schedule_item(shift);
			$self->{resources}->remove(
				$self->{instructor},
				$item->{resource},
				$item->{span});
		});
		1;
	}
}

################################################################################
# SCHEDULE_REMOVE_FAILED

sub do_schedule_remove_failed {
	my ($self, $state) = @_;
	$self->transition($state, lz("instructor_invalid_record"));
}

################################################################################
# SCHEDULE_REMOVE_DONE

sub do_schedule_remove_done {
	my ($self, $state) = @_;
	$self->transition($state, lz("instructor_record_removed"));
}

################################################################################
# RESOURCE

sub do_resource {
	my ($self, $state) = @_;
	my @keyboard = @{$self->{resources}->names};
	if (@keyboard) {
		push @keyboard, lz("cancel");
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
	$self->rule_cancel($state, $update);
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
	$self->transition($state, lz("instructor_invalid_resource"));
}

################################################################################
# TIME

sub do_time {
	my ($self, $state) = @_;
	my @keyboard = (lz("help"), lz("back"), lz("cancel"));
	$self->send_keyboard(lz("instructor_enter_time"), \@keyboard);
}

sub time_rule_resource {
	my ($self, $state, $update) = @_;
	$self->rule_back($state, $update);
}

sub time_rule_cancel {
	my ($self, $state, $update) = @_;
	$self->rule_cancel($state, $update);
}

sub time_rule_time_help {
	my ($self, $state, $update) = @_;
	$self->rule_help($state, $update);
}

sub time_rule_record {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub {
		FSMUtils::_parse_value($state, sub {
			my @strs = @{StringUtils::split(shift)};
			my @spans = grep { defined $_ }
				map { $self->{recordtimeparser}->parse($_) }
				@strs;
			scalar @spans == scalar @strs ? \@spans : undef;
		}, shift);
	});
}

################################################################################
# TIME_HELP

sub do_time_help {
	my ($self, $state) = @_;
	$self->transition($state, lz("instructor_time_help"));
}

################################################################################
# TIME_FAILED

sub do_time_failed {
	my ($self, $state) = @_;
	$self->transition($state, lz("instructor_invalid_time"));
}

################################################################################
# RECORD

sub do_record {
	my ($self, $state) = @_;
	$self->transition($state);

	my $instructor = $self->{instructor};

	my $machine = $state->machine;
	my $resource = $machine->last_result("RESOURCE");
	my $spans = $machine->last_result("TIME");

	foreach my $span (@$spans) {
		$self->{resources}->record($instructor, $resource, $span);
	}

	$self->send_message(lz("instructor_record_saved"));
}

################################################################################

1;

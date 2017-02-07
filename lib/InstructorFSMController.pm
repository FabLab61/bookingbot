package InstructorFSMController;

use strict;
use warnings;

use Localization qw(lz dt);

use DumperUtils;

use parent ("BaseFSMController");

sub new {
	my ($class, $user, $chat_id, $api, $instructors, $resources, $recordtimeparser) = @_;

	my $self = $class->SUPER::new($chat_id, $api);
	$self->{user} = $user;
	$self->{instructors} = $instructors;
	$self->{resources} = $resources;
	$self->{recordtimeparser} = $recordtimeparser;
	$self->{log} = Log->new("instructorfsmcontroller");

	$self;
}

sub send_start_message {
	my ($self) = @_;
	$self->send_message(lz("instructor_start"));
}

sub send_cancel_message {
	my ($self) = @_;
	$self->send_message(lz("instructor_operation_cancelled"));
}

sub send_menu {
	my ($self) = @_;
	my @keyboard = (
		lz("instructor_show_schedule"),
		lz("instructor_add_record"),
	);
	$self->send_keyboard(lz("instructor_menu"), \@keyboard);
}

sub is_schedule_selected {
	my ($self, $text) = @_;
	$text eq lz("instructor_show_schedule");
}

sub is_add_record_selected {
	my ($self, $text) = @_;
	$text eq lz("instructor_add_record");
}

sub send_schedule {
	my ($self) = @_;
	$self->send_message(lz("instructor_schedule"));

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

sub ask_record_time {
	my ($self) = @_;
	my @keyboard = (
		lz("instructor_cancel_operation"),
	);
	$self->send_keyboard(lz("instructor_record_time"), \@keyboard);
}

sub is_cancel_operation_selected {
	my ($self, $text) = @_;
	$text eq lz("instructor_cancel_operation");
}

sub ask_record_time_failed {
	my ($self) = @_;
	$self->send_message(lz("invalid_record_time"));
}

sub parse_record_time {
	my ($self, $text) = @_;
	$self->{recordtimeparser}->parse($text);
}

sub save_record {
	my ($self, $record) = @_;
	$self->send_message(DumperUtils::span2str($record));
}

1;

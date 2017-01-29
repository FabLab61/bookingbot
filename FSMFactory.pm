package FSMFactory;

use strict;
use warnings;

use Contacts;
use DateTimeFactory;
use UserFSM;
use UserFSMController;
use InstructorFSM;
use Instructors;
use Localization qw(lz dt);
use Resources;
use RecordTimeParser;

use DumperUtils;

sub new {
	my ($class, $api, $groups, $config) = @_;

	my $contacts = Contacts->new($api);
	my $dtf = DateTimeFactory->new;
	my $instructors = Instructors->new(
		$api, $contacts, $groups, $config->{instructors});
	my $resources = Resources->new($config->{resources});
	my $recordtimeparser = RecordTimeParser->new($config->{workinghours});

	my $self = {
		api => $api,
		contacts => $contacts,
		dtf => $dtf,
		instructors => $instructors,
		resources => $resources,
		recordtimeparser => $recordtimeparser,
		durations => $config->{durations},
		log => Log->new("fsmfactory"),
	};
	bless $self, $class;
}

sub create {
	my ($self, $user, $chat_id) = @_;

	if ($self->{instructors}->is_instructor($user->{id})) {
		$self->instructor_fsm($user, $chat_id);
	} else {
		$self->user_fsm($user, $chat_id);
	}
}

sub instructor_fsm {
	my ($self, $user, $chat_id) = @_;

	InstructorFSM->new(
		send_start_message => sub {
			$self->{api}->send_message(
				{chat_id => $chat_id, text => lz("instructor_start")});
		},

		send_cancel_message => sub {
			$self->{api}->send_message({chat_id => $chat_id,
					text => lz("instructor_operation_cancelled")});
		},

		send_menu => sub {
			my @keyboard = (
				lz("instructor_show_schedule"),
				lz("instructor_add_record"),
			);
			$self->{api}->send_keyboard({
				chat_id => $chat_id,
				text => lz("instructor_menu"),
				keyboard => \@keyboard
			});
		},

		is_schedule_selected => sub {
			my ($text) = @_;
			$text eq lz("instructor_show_schedule");
		},

		is_add_record_selected => sub {
			my ($text) = @_;
			$text eq lz("instructor_add_record");
		},

		send_schedule => sub {
			$self->{api}->send_message(
				{chat_id => $chat_id, text => lz("instructor_schedule")});

			my $instructor = $self->{instructors}->name($user->{id});
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
				$text = lz("instructor_schedule_is_empty")
			}

			$self->{api}->send_message({chat_id => $chat_id, text => $text});
		},

		ask_record_time => sub {
			my @keyboard = (
				lz("instructor_cancel_operation"),
			);
			$self->{api}->send_keyboard({
				chat_id => $chat_id,
				text => lz("instructor_record_time"),
				keyboard => \@keyboard
			});
		},

		is_cancel_operation_selected => sub {
			my ($text) = @_;
			$text eq lz("instructor_cancel_operation");
		},

		ask_record_time_failed => sub {
			$self->{api}->send_message({
				chat_id => $chat_id, text => lz("invalid_record_time")});
		},

		parse_record_time => sub {
			my ($text) = @_;
			$self->{recordtimeparser}->parse($text);
		},

		save_record => sub {
			my ($record) = @_;

			$self->{api}->send_message({
				chat_id => $chat_id, text => DumperUtils::span2str($record)});
		},
	);
}

sub user_fsm {
	my ($self, $user, $chat_id) = @_;
	UserFSM->new(UserFSMController->new(
			$user,
			$chat_id,
			$self->{api},
			$self->{contacts},
			$self->{durations},
			$self->{instructors},
			$self->{resources}));
}

1;

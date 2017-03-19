package FSMFactory;

use strict;
use warnings;
use utf8;

use Contacts;
use DateTimeFactory;
use UserFSM;
use UserFSMController;
use InstructorFSM;
use InstructorFSMController;
use Instructors;
use Localization qw(lz dt);
use Resources;
use RecordTimeParser;

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
	InstructorFSM->new(InstructorFSMController->new(
			$user,
			$chat_id,
			$self->{api},
			$self->{instructors},
			$self->{resources},
			$self->{recordtimeparser}));
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

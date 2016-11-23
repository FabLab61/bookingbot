package FSMFactory;

use strict;
use warnings;

use Contacts;
use DateTimeFactory;
use FSM;
use Instructors;
use Localization qw(lz dt);
use Resources;

sub new {
	my ($class, $api, $groups, $config) = @_;

	my $contacts = Contacts->new($api);
	my $dtf = DateTimeFactory->new;
	my $instructors = Instructors->new(
		$api, $contacts, $groups, $config->{instructors});
	my $resources = Resources->new($config->{resources});

	my $self = {
		api => $api,
		contacts => $contacts,
		dtf => $dtf,
		instructors => $instructors,
		resources => $resources,
		durations => $config->{durations},
		log => Log->new("fsmfactory")

	};
	bless $self, $class;
}

sub create {
	my ($self, $user, $chat_id) = @_;
	$self->user_fsm($user, $chat_id);
}

sub user_fsm {
	my ($self, $user, $chat_id) = @_;

	FSM->new(
		send_start_message => sub {
			$self->{api}->send_message(
				{chat_id => $chat_id, text => lz("start")});
		},

		send_contact_message => sub {
			$self->{api}->send_message(
				{chat_id => $chat_id, text => lz("contact")});
		},

		save_contact => sub {
			my ($contact) = @_;
			if (defined $contact) {
				$self->{contacts}->add($user->{id}, $contact);
				1;
			}
		},

		send_contact_failed => sub {
			$self->{api}->send_message({
					chat_id => $chat_id, text => lz("invalid_contact")});
		},

		send_begin_message => sub {
			$self->{api}->send_message(
				{chat_id => $chat_id, text => lz("begin")});
		},

		send_resources => sub {
			my @durations = sort { $a <=> $b }
				values %{$self->{durations}};
			my $min = $self->{dtf}->dur(minutes => shift @durations);

			my @keyboard = grep {
				scalar @{$self->{resources}->vacancies($_, $min)} > 0;
			} @{$self->{resources}->names};

			if (scalar @keyboard > 0) {
				$self->{api}->send_keyboard({
					chat_id => $chat_id,
					text => lz("select_resource"),
					keyboard => \@keyboard
				});
			} else {
				undef;
			}
		},

		parse_resource => sub {
			my ($name) = @_;
			$self->{resources}->exists($name) ? $name : undef;
		},

		send_resource_not_found => sub {
			$self->{api}->send_message({
				chat_id => $chat_id, text => lz("resource_not_found")});
		},

		send_resource_failed => sub {
			$self->{api}->send_message({
				chat_id => $chat_id, text => lz("invalid_resource")});
		},

		send_durations => sub {
			my ($resource) = @_;

			my $durations = $self->{durations};

			my @keyboard =
				map { lz($_->[1]) }
				sort { $a->[0] <=> $b->[0] }
				map { [$durations->{$_}, $_] }
				grep {
					my $duration = $self->{dtf}->dur(
						minutes => $durations->{$_});
					my $vacancies = $self->{resources}->vacancies(
						$resource, $duration);
					scalar @$vacancies > 0;
				} keys %$durations;

			if (scalar @keyboard > 0) {
				$self->{api}->send_keyboard({
					chat_id => $chat_id,
					text => lz("select_duration"),
					keyboard => \@keyboard
				});
			} else {
				undef;
			}
		},

		parse_duration => sub {
			my ($arg) = @_;
			my $durations = $self->{durations};
			my @result = grep { lz($_) eq $arg } keys %$durations;
			scalar @result > 0
				? $self->{dtf}->dur(minutes => $durations->{$result[0]})
				: undef;
		},

		send_duration_not_found => sub {
			$self->{api}->send_message({
				chat_id => $chat_id, text => lz("duration_not_found")});
		},

		send_duration_failed => sub {
			$self->{api}->send_message({
				chat_id => $chat_id, text => lz("invalid_duration")});
		},

		send_datetime_selector => sub {
			my ($resource, $duration) = @_;

			my $vacancies = $self->{resources}->vacancies(
				$resource, $duration);
			my @keyboard = map { dt($_->{span}->start) } @$vacancies;

			$self->{api}->send_keyboard({
				chat_id => $chat_id,
				text => lz("select_datetime"),
				keyboard => \@keyboard
			});
		},

		parse_datetime => sub {
			my ($inputstr) = @_;
			$self->{dtf}->parse($inputstr);
		},

		send_datetime_failed => sub {
			$self->{api}->send_message({
				chat_id => $chat_id, text => lz("invalid_datetime")});
		},

		parse_instructor => sub {
			my ($resource, $datetime, $duration) = @_;

			my $span = $self->{dtf}->span_d($datetime, $duration);
			my $vacancies = $self->{resources}->vacancies(
				$resource, $duration);

			my @result = map { $_->{instructor} }
				grep { $_->{span}->contains($span) } @$vacancies;

			scalar @result ? $result[0] : undef;
		},

		send_instructor_failed => sub {
			$self->{api}->send_message({
				chat_id => $chat_id, text => lz("instructor_not_found")});
		},

		book => sub {
			my ($resource, $datetime, $duration, $instructor) = @_;

			my $span = $self->{dtf}->span_d($datetime, $duration);
			$self->{resources}->book(
				lz("booked_by", $self->{contacts}->fullname($user->{id})),
				$resource, $span);

			$self->{api}->send_message({
				chat_id => $chat_id,
				text => lz("booked", $resource, dt($datetime))});

			if ($self->{instructors}->exists($instructor)) {
				$self->{instructors}->share_contact($instructor, $chat_id);
				$self->{instructors}->notify_instructor(
					$instructor, $user, $resource, $span);
			}
			$self->{instructors}->notify_groups(
				$instructor, $user, $resource, $span);
		},

		send_refresh => sub {
			$self->{api}->send_keyboard({
				chat_id => $chat_id,
				text => lz("press_refresh_button"),
				keyboard => [lz("refresh")]
			});
		},
	);
}

sub instructor_fsm {
	my ($self) = @_;
}

1;

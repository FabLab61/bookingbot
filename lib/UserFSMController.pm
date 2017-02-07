package UserFSMController;

use strict;
use warnings;

use Localization qw(lz dt);

use parent ("BaseFSMController");

sub new {
	my ($class, $user, $chat_id, $api, $contacts, $durations, $instructors, $resources) = @_;

	my $self = $class->SUPER::new($chat_id, $api);
	$self->{user} = $user;
	$self->{contacts} = $contacts;
	$self->{durations} = $durations;
	$self->{instructors} = $instructors;
	$self->{resources} = $resources;
	$self->{log} = Log->new("userfsmcontroller");

	$self;
}

sub send_start_message {
	my ($self) = @_;
	$self->send_message(lz("start"));
}

sub send_contact_message {
	my ($self) = @_;
	$self->send_message(lz("contact"));
}

sub save_contact {
	my ($self, $contact) = @_;
	if (defined $contact) {
		$self->{contacts}->add($self->{user}->{id}, $contact);
		1;
	}
}

sub send_contact_failed {
	my ($self) = @_;
	$self->send_message(lz("invalid_contact"));
}

sub send_begin_message {
	my ($self) = @_;
	$self->send_message(lz("begin"));
}

sub send_resources {
	my ($self) = @_;

	my @durations = sort { $a <=> $b } values %{$self->{durations}};
	my $min = $self->{dtf}->dur(minutes => shift @durations);

	my @keyboard = grep {
		scalar @{$self->{resources}->vacancies($_, $min)};
	} @{$self->{resources}->names};

	if (@keyboard) {
		$self->send_keyboard(lz("select_resource"), \@keyboard);
	} else {
		undef;
	}
}

sub _parse_resource {
	my ($self, $name) = @_;
	$self->{resources}->exists($name) ? $name : undef;
}

sub get_resource_parser {
	my ($self) = @_;
	$self->_parse_resource;
}

sub send_resource_not_found {
	my ($self) = @_;
	$self->send_message(lz("resource_not_found"));
}

sub send_resource_failed {
	my ($self) = @_;
	$self->send_message(lz("invalid_resource"));
}

sub send_durations {
	my ($self, $resource) = @_;

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
			scalar @$vacancies;
		} keys %$durations;

	if (@keyboard) {
		$self->{api}->send_keyboard({
			text => lz("select_duration"),
			keyboard => \@keyboard
		});
	} else {
		undef;
	}
}

sub parse_duration {
	my ($self, $arg) = @_;
	my $durations = $self->{durations};
	my @result = grep { lz($_) eq $arg } keys %$durations;
	scalar @result
		? $self->{dtf}->dur(minutes => $durations->{$result[0]})
		: undef;
}

sub send_duration_not_found {
	my ($self) = @_;
	$self->send_message(lz("duration_not_found"));
}

sub send_duration_failed {
	my ($self) = @_;
	$self->send_message(lz("invalid_duration"));
}

sub send_datetime_selector {
	my ($self, $resource, $duration) = @_;

	my $vacancies = $self->{resources}->vacancies(
		$resource, $duration);
	my @keyboard = map { dt($_->{span}->start) } @$vacancies;

	$self->{api}->send_keyboard({
		text => lz("select_datetime"),
		keyboard => \@keyboard
	});
}

sub parse_datetime {
	my ($self, $inputstr) = @_;
	$self->{dtf}->parse($inputstr);
}

sub send_datetime_failed {
	my ($self) = @_;
	$self->send_message(lz("invalid_datetime"));
}

sub parse_instructor {
	my ($self, $resource, $datetime, $duration) = @_;

	my $span = $self->{dtf}->span_d($datetime, $duration);
	my $vacancies = $self->{resources}->vacancies(
		$resource, $duration);

	my @result = map { $_->{instructor} }
		grep { $_->{span}->contains($span) } @$vacancies;

	scalar @result ? $result[0] : undef;
}

sub send_instructor_failed {
	my ($self) = @_;
	$self->send_message(lz("instructor_not_found"));
}

sub book {
	my ($self, $resource, $datetime, $duration, $instructor) = @_;

	my $span = $self->{dtf}->span_d($datetime, $duration);
	$self->{resources}->book(
		lz("booked_by", $self->{contacts}->fullname($self->{user}->{id})),
		$resource, $span);

	$self->send_message(lz("booked", $resource, dt($datetime)));

	if ($self->{instructors}->exists($instructor)) {
		$self->{instructors}->share_contact($instructor, $self->{chat_id});
		$self->{instructors}->notify_instructor(
			$instructor, $self->{user}, $resource, $span);
	}
	$self->{instructors}->notify_groups(
		$instructor, $self->{user}, $resource, $span);
}

sub send_refresh {
	my ($self) = @_;
	$self->send_keyboard(lz("press_refresh_button"), [lz("refresh")]);
}

1;

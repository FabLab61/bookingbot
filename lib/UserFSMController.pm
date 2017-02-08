package UserFSMController;

use strict;
use warnings;

use FSMUtils;
use Localization qw(lz dt);

use parent ("BaseFSMController");

sub new {
	my ($class, $user,
		$chat_id, $api,
		$contacts, $durations, $instructors, $resources) = @_;

	my $self = $class->SUPER::new($chat_id, $api);
	$self->{user} = $user;
	$self->{contacts} = $contacts;
	$self->{durations} = $durations;
	$self->{instructors} = $instructors;
	$self->{resources} = $resources;
	$self->{log} = Log->new("userfsmcontroller");

	$self;
}

################################################################################
# START

sub do_start {
	my ($self, $state) = @_;
	$self->transition($state, lz("user_start"));
	$self->remove_keyboard();
}

################################################################################
# CANCEL

sub do_cancel {
	my ($self, $state) = @_;
	$self->transition($state, lz("operation_cancelled"));
}

################################################################################
# CONTACT

sub do_contact {
	my ($self, $state) = @_;
	$self->send_keyboard(lz("user_contact"), [{
		text => lz("user_share_contact"),
		request_contact => \1
	}]);
}

sub contact_rule_begin {
	my ($self, $state, $update) = @_;
	my $contact = $update->{message}->{contact};
	if (defined $contact) {
		$self->{contacts}->add($self->{user}->{id}, $contact);
		1;
	}
}

################################################################################
# CONTACT_FAILED

sub do_contact_failed {
	my ($self, $state) = @_;
	$self->transition($state, lz("user_invalid_contact"));
}

################################################################################
# BEGIN

sub do_begin {
	my ($self, $state) = @_;
	$self->transition($state, lz("user_begin"));
}

################################################################################
# RESOURCE

sub do_resource {
	my ($self, $state) = @_;

	my @durations = sort { $a <=> $b } values %{$self->{durations}};
	my $min = $self->{dtf}->dur(minutes => shift @durations);

	my @keyboard = grep {
		scalar @{$self->{resources}->vacancies($_, $min)};
	} @{$self->{resources}->names};

	if (@keyboard) {
		$self->send_keyboard(lz("user_select_resource"), \@keyboard);
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

sub resource_rule_duration {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub {
		FSMUtils::_parse_value($state, sub {
			my ($name) = @_;
			$self->{resources}->exists($name) ? $name : undef;
		}, shift);
	});
}

################################################################################
# RESOURCE_NOT_FOUND

sub do_resource_not_found {
	my ($self, $state) = @_;
	$self->transition($state, lz("user_resource_not_found"));
}

################################################################################
# RESOURCE_FAILED

sub do_resource_failed {
	my ($self, $state) = @_;
	$self->transition($state, lz("user_invalid_resource"));
}

################################################################################
# DURATION

sub do_duration {
	my ($self, $state) = @_;

	my $machine = $state->machine;
	my $resource = $machine->last_result("RESOURCE");
	my $durations = $self->{durations};

	my @keyboard =
		map { lz($_->[1]) }
		sort { $a->[0] <=> $b->[0] }
		map { [$durations->{$_}, $_] }
		grep {
			my $duration = $self->{dtf}->dur(minutes => $durations->{$_});
			my $vacancies = $self->{resources}->vacancies($resource, $duration);
			scalar @$vacancies;
		} keys %$durations;

	if (@keyboard) {
		push @keyboard, lz("cancel");
		$self->send_keyboard(lz("user_select_duration"), \@keyboard);
		$state->result(1);
	} else {
		$self->transition($state);
		$state->result(undef);
	}
}

sub duration_rule_duration_not_found {
	my ($self, $state) = @_;
	not defined $state->result;
}

sub duration_rule_datetime {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub {
		FSMUtils::_parse_value($state, sub {
			my ($value) = @_;
			my $durations = $self->{durations};
			my @result = grep { lz($_) eq $value } keys %$durations;
			scalar @result
				? $self->{dtf}->dur(minutes => $durations->{$result[0]})
				: undef;
		}, shift);
	});
}

sub duration_rule_cancel {
	my ($self, $state, $update) = @_;
	$self->rule_cancel($state, $update);
}

################################################################################
# DURATION_NOT_FOUND

sub do_duration_not_found {
	my ($self, $state) = @_;
	$self->transition($state, lz("user_duration_not_found"));
}

################################################################################
# DURATION_FAILED

sub do_duration_failed {
	my ($self, $state) = @_;
	$self->transition($state, lz("user_invalid_duration"));
}

################################################################################
# DATETIME

sub do_datetime {
	my ($self, $state) = @_;

	my $machine = $state->machine;
	my $resource = $machine->last_result("RESOURCE");
	my $duration = $machine->last_result("DURATION");

	my $vacancies = $self->{resources}->vacancies($resource, $duration);
	my @keyboard = map { dt($_->{span}->start) } @$vacancies;

	push @keyboard, lz("back"), lz("cancel");
	$self->send_keyboard(lz("user_select_datetime"), \@keyboard)
}

sub datetime_rule_instructor {
	my ($self, $state, $update) = @_;
	FSMUtils::_with_text($update, sub {
		FSMUtils::_parse_value($state, sub {
			$self->{dtf}->parse(shift);
		}, shift);
	});
}

sub datetime_rule_duration {
	my ($self, $state, $update) = @_;
	$self->rule_back($state, $update);
}

sub datetime_rule_cancel {
	my ($self, $state, $update) = @_;
	$self->rule_cancel($state, $update);
}

################################################################################
# DATETIME_FAILED

sub do_datetime_failed {
	my ($self, $state) = @_;
	$self->transition($state, lz("user_invalid_datetime"));
}

################################################################################
# INSTRUCTOR

sub do_instructor {
	my ($self, $state) = @_;
	$self->transition($state);
}

sub instructor_rule_book {
	my ($self, $state) = @_;

	my $machine = $state->machine;
	my $resource = $machine->last_result("RESOURCE");
	my $datetime = $machine->last_result("DATETIME");
	my $duration = $machine->last_result("DURATION");

	FSMUtils::_parse_value($state, sub {
		my ($resource, $datetime, $duration) = @_;

		my $span = $self->{dtf}->span_d($datetime, $duration);
		my $vacancies = $self->{resources}->vacancies(
			$resource, $duration);

		my @result = map { $_->{instructor} }
			grep { $_->{span}->contains($span) } @$vacancies;

		scalar @result ? $result[0] : undef;
	}, $resource, $datetime, $duration);
}

################################################################################
# INSTRUCTOR_NOT_FOUND

sub do_instructor_not_found {
	my ($self, $state) = @_;
	$self->transition($state, lz("user_instructor_not_found"));
}

################################################################################
# BOOK

sub do_book {
	my ($self, $state) = @_;
	$self->transition($state);

	my $machine = $state->machine;
	my $resource = $machine->last_result("RESOURCE");
	my $datetime = $machine->last_result("DATETIME");
	my $duration = $machine->last_result("DURATION");
	my $instructor = $machine->last_result("INSTRUCTOR");

	my $span = $self->{dtf}->span_d($datetime, $duration);
	$self->{resources}->book(
		lz("booked_by", $self->{contacts}->fullname($self->{user}->{id})),
		$resource, $span);

	$self->send_message(lz("user_booked", $resource, dt($datetime)));

	if ($self->{instructors}->exists($instructor)) {
		$self->{instructors}->share_contact($instructor, $self->{chat_id});
		$self->{instructors}->notify_instructor(
			$instructor, $self->{user}, $resource, $span);
	}
	$self->{instructors}->notify_groups(
		$instructor, $self->{user}, $resource, $span);
}

################################################################################
# REFRESH

sub do_refresh {
	my ($self, $state) = @_;
	$self->send_keyboard(lz("user_press_refresh_button"), [lz("user_refresh")]);
}

################################################################################

1;

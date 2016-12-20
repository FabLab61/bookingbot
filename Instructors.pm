package Instructors;

use strict;
use warnings;

use Instructor;
use Localization qw(lz dt);

sub new {
	my ($class, $api, $contacts, $groups, $config) = @_;

	my %instructors = ();
	foreach my $name (keys %$config) {
		my $record = $config->{$name};
		$instructors{$name} = Instructor->new($api, $record);
	}

	my $self = {api => $api, contacts => $contacts, groups => $groups,
		instructors => \%instructors};
	bless $self, $class;
}

sub exists {
	my ($self, $name) = @_;
	defined $self->{instructors}->{$name};
}

sub is_instructor {
	my ($self, $id) = @_;
	my @result = grep { $_->id eq $id } values %{$self->{instructors}};
	scalar @result;
}

sub name {
	my ($self, $id) = @_;

	my @result = grep {
		$self->{instructors}->{$_}->id eq $id;
	} keys %{$self->{instructors}};

	scalar @result ? $result[0] : undef;
}

sub share_contact {
	my ($self, $name, $chat_id) = @_;
	die unless $self->exists($name);

	$self->{instructors}->{$name}->share_contact($chat_id);
}

sub notify_instructor {
	my ($self, $name, $user, $resource, $span) = @_;
	die unless $self->exists($name);

	my $instructor = $self->{instructors}->{$name};
	$self->{api}->send_message({chat_id => $instructor->{id},
		text => lz("instructor_new_book", $resource,
			dt($span->start), dt($span->end))
	});
	$self->{contacts}->send($instructor->{id}, $user->{id});
}

sub notify_groups {
	my ($self, $name, $user, $resource, $span) = @_;

	my $text = $self->exists($name)
		? lz("group_new_book",
				$self->{instructors}->{$name}->fullname, $name,
				$resource, dt($span->start), dt($span->end)) 
		: lz("group_new_book_fallback",
				$resource, dt($span->start), dt($span->end));

	foreach my $group (@{$self->{groups}->{groups}}) {
		$self->{api}->send_message({chat_id => $group, text => $text});
		$self->{contacts}->send($group, $user->{id});
	}
}

1;

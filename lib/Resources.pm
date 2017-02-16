package Resources;

use strict;
use warnings;
use utf8;

use Resource;

sub new {
	my ($class, $config) = @_;

	my %resources = ();
	foreach my $id (keys %$config) {
		my $record = $config->{$id};
		$resources{$id} = Resource->new($record);
	}

	my $self = {resources => \%resources};
	bless $self, $class;
}

sub names {
	my ($self) = @_;
	my $resources = $self->{resources};
	my @result = sort { $a cmp $b } keys %$resources;
	\@result;
}

sub exists {
	my ($self, $name) = @_;
	my $resources = $self->{resources};
	grep { $_ eq $name } keys %$resources;
}

sub vacancies {
	my ($self, $name, $duration, $span) = @_;
	$self->{resources}->{$name}->vacancies($duration, $span);
}

sub schedule {
	my ($self, $instructor, $span) = @_;

	my %result = ();
	foreach my $name (keys %{$self->{resources}}) {
		my $resource = $self->{resources}->{$name};
		my $schedule = $resource->schedule($instructor, $span);
		if (@$schedule) {
			$result{$name} = $schedule;
		}
	}

	\%result;
}

sub remove {
	my ($self, $instructor, $name, $span) = @_;
	$self->{resources}->{$name}->remove($instructor, $span);
}

sub book {
	my ($self, $summary, $name, $span) = @_;
	$self->{resources}->{$name}->book($summary, $span);
}

sub record {
	my ($self, $instructor, $name, $span) = @_;
	$self->{resources}->{$name}->record($instructor, $span);
}

1;

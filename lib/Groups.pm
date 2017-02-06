package Groups;

use strict;
use warnings;

sub new {
	my ($class, $myid) = @_;
	my $self = {myid => $myid, groups => []};
	bless $self, $class;
}

sub process {
	my ($self, $message) = @_;
	if (defined $message->{new_chat_participant}
			and $message->{new_chat_participant}->{id} eq $self->{myid}) {
		push @{$self->{groups}}, $message->{chat}->{id};
	} elsif (defined $message->{left_chat_participant}
			and $message->{left_chat_participant}->{id} eq $self->{myid}) {
		my @groups = grep { $_ ne $message->{chat}->{id} } @{$self->{groups}};
		$self->{groups} = \@groups;
	}
}

1;

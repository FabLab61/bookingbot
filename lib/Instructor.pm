package Instructor;

use strict;
use warnings;

use Try::Tiny qw(try catch);

use Localization qw(lz);

sub new {
	my ($class, $api, $record) = @_;
	my %self = ((api => $api), %$record);
	bless \%self, $class;
}

sub id {
	my ($self) = @_;
	$self->{id};
}

sub fullname {
	my ($self) = @_;
	my $first_name = $self->{first_name};
	my $last_name = $self->{last_name} // "";
	my $result = "$first_name $last_name";
	$result =~ s/^\s+|\s+$//g; # trim
	$result;
}

sub share_contact {
	my ($self, $chat_id) = @_;

	$self->{api}->send_message({chat_id => $chat_id,
		text => lz("instructor_contact")});

	try {
		$self->{api}->send_contact({chat_id => $chat_id, contact => {
			phone_number => $self->{phone_number},
			first_name => $self->{first_name},
			last_name => $self->{last_name}
		}});
	} catch {
		$self->{api}->send_message({chat_id => $chat_id, text =>
			lz("contact_format", $self->{first_name}, $self->{last_name} // "",
			$self->{phone_number})});
	}
}

1;

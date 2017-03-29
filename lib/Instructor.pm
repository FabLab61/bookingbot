package Instructor;

use strict;
use warnings;
use utf8;

use Try::Tiny qw(try catch);

use StringUtils;
use Localization qw(lz);

sub new {
	my ($class, $api, $record) = @_;
	my %self = ((api => $api), %$record);
	bless \%self, $class;
}

sub id {
	shift->{id};
}

sub fullname {
	my $self = shift;
	my $first_name = $self->{first_name};
	my $last_name = $self->{last_name} // "";
	StringUtils::trim("$first_name $last_name");
}

sub share_contact {
	my ($self, $chat_id) = @_;

	$self->{api}->send_message({chat_id => $chat_id,
		text => lz("user_instructor_contact")});

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

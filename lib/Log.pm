package Log;

use strict;
use warnings;

use Log::Any ();
use Log::Any::Adapter ('Stdout');
use Log::Any::For::Std;

use DateTimeFactory;

my $sid = 0;
sub incsid {
	$sid++;
}

sub new {
	my ($class, $category) = @_;
	my $log = Log::Any->get_logger(category => $category // "general");
	my $self = {log => $log, dtf => DateTimeFactory->new};
	bless $self, $class;
}

sub _prefix {
	my ($self) = @_;
	$self->{dtf}->now->datetime . " [$sid] ";
}

sub debugf {
	my ($self, $message, @params) = @_;
	$self->{log}->debugf($self->_prefix . $message, @params);
}

sub infof {
	my ($self, $message, @params) = @_;
	$self->{log}->infof($self->_prefix . $message, @params);
}

1;

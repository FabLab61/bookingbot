package Log;

use strict;
use warnings;
use utf8;
use overload;

use Data::Dumper::AutoEncode;
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

sub _edump {
	local $Data::Dumper::Indent = 0;
	local $Data::Dumper::Sortkeys = 1;
	local $Data::Dumper::Quotekeys = 0;
	local $Data::Dumper::Terse = 1;
	eDumper(@_);
};

# see also Log::Any::Proxy module
sub _formatter {
    my ($format, @params) = @_;

    return $format->() if ref($format) eq 'CODE';

    my @new_params = map {
		!defined($_)
			? "<undef>"
			: ref($_)
				? (overload::OverloadedStringify($_) ? "$_" : _edump($_))
				: $_
	} @params;

    # Perl 5.22 adds a 'redundant' warning if the number parameters exceeds
    # the number of sprintf placeholders.  If a user does this, the warning
    # is issued from here, which isn't very helpful.  Doing something
    # clever would be expensive, so instead we just disable warnings for
    # the final line of this subroutine.
    no warnings;

    return sprintf($format, @new_params);
}

sub debugf {
	my ($self, $message, @params) = @_;
	$self->{log}->debugf(_formatter($self->_prefix . $message, @params));
}

sub infof {
	my ($self, $message, @params) = @_;
	$self->{log}->infof(_formatter($self->_prefix . $message, @params));
}

1;

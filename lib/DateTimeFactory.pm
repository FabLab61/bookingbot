package DateTimeFactory;

use strict;
use warnings;

use Date::Parse qw(str2time);
use DateTime;
use DateTime::Duration;
use DateTime::Format::RFC3339;
use DateTime::Span;
use DateTime::SpanSet;

use Scalar::Util qw(blessed);

my $default_timezone;
sub set_default_timezone {
	$default_timezone = shift;
}

sub new {
	my ($class, $timezone) = @_;
	my $self = {timezone => $timezone // $default_timezone};
	bless $self, $class;
}

sub now {
	my ($self) = @_;
	die unless defined $self->{timezone};

	DateTime->now(time_zone => $self->{timezone});
}

sub tomorrow {
	my ($self) = @_;
	die unless defined $self->{timezone};

	DateTime->today(time_zone => $self->{timezone})->add(days => 1);
}

sub epoch {
	my ($self, $unixtime) = @_;
	die unless defined $self->{timezone};

	my $result = DateTime->from_epoch(
		epoch => $unixtime, time_zone => "floating");
	$result->set_time_zone($self->{timezone});

	$result;
}

sub cmp {
	my ($self, $left, $right) = @_;
	DateTime->compare($left, $right);
}

sub parse {
	my ($self, $inputstr) = @_;
	my $unixtime = str2time($inputstr);
	defined $unixtime ? $self->epoch($unixtime) : undef;
}

sub parse_rfc3339 {
	my ($self, $inputstr) = @_;
	die unless defined $self->{timezone};

	my $result = DateTime::Format::RFC3339->parse_datetime($inputstr);
	$result->set_time_zone($self->{timezone});
}

sub dur {
	my ($self, %params) = @_;
	DateTime::Duration->new(%params);
}

sub durcmp {
	my ($self, $left, $right, $start) = @_;
	DateTime::Duration->compare($left, $right, $start);
}

sub rfc3339 {
	my ($self, $datetime) = @_;
	DateTime::Format::RFC3339->format_datetime($datetime);
}

sub span_d {
	my ($self, $datetime, $data) = @_;
	my $duration = blessed($data) ? $data : $self->dur(%$data);
	DateTime::Span->from_datetime_and_duration(
		start => $datetime, duration => $duration);
}

sub span_se {
	my ($self, $start, $end) = @_;
	DateTime::Span->from_datetimes(start => $start, before => $end);
}

sub spanset {
	my ($self, $spans) = @_;
	DateTime::SpanSet->from_spans(spans => $spans);
}

1;

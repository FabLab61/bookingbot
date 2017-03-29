#!/usr/bin/perl
use common::sense;
use Data::Dumper;
use DateTime;
use DateTime::Format::RFC3339;

use API::Google::GCal;
my $gapi = API::Google::GCal->new({ tokensfile => 'gapi.conf' });

my $user = 'fablab61ru@gmail.com';
my $timeZone = 'Europe/Moscow';
my $start_date = DateTime->now->set_time_zone($timeZone);
my $end_date = DateTime->now->add_duration( DateTime::Duration->new( days => 1) );

my $calendar_id = $gapi->get_calendar_id_by_name($user, 'Lasersaur');

warn $calendar_id;

my $freebusy_data = {
    user => $user,
    calendarId => $calendar_id,
    # dt_start => DateTime::Format::RFC3339->format_datetime($start_date),
    # dt_end => DateTime::Format::RFC3339->format_datetime($end_date),
    # timeZone => $timeZone
};

# $gapi->busy_time_ranges($freebusy_data);

my @events = @ { $gapi->events_list($freebusy_data) };
warn "Total events: ".scalar @events;

for my $e (@events) {
    $e = { map { $_ => $e->{$_} } grep { exists $e->{$_} } qw\summary start end description\ };   # fields to leave
}


warn Dumper @events;

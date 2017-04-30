use lib 'lib';

use Data::Printer;
use Data::Dumper;
$Data::Dumper::Maxdepth = 3;
use Resource;
use DateTimeFactory;
use DateTime;
use DateTime::Span;
use DateTime::Duration;

my $l = 'b7qv527m99oqlq3md28cof16jc@group.calendar.google.com';
my $r= Resource->new({ calendar => $l});

my $span = DateTime::Span->from_datetimes( start => DateTime->now); # open span, from now
#warn Dumper $r->events_inside_span($span);
my $dur = DateTime::Duration->new(hours=>1);
# warn Dumper $r->vacancies($dur, $span);

warn Dumper $r->schedule('pavel.p.serikov@gmail.com', $span); # returns all instructor schedule in specified time span




# my $span2 = DateTime::Span->from_datetimes( start => DateTime->now, end => DateTime->now->add_duration($dur) ); # from now till +1 hour
#
# warn Dumper $r->book('Ivan Ivanov',$span2)->json; # return Google API response formatted in Perl hash



# p ($r);



# my $f = DateTimeFactory->new;
# warn Dumper $f->durcmp(DateTime::Duration->new(days=>4, hours=>2), DateTime::Duration->new(days=>10, hours =>5));

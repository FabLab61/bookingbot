use lib 'lib';

use Data::Printer;
use Data::Dumper;
$Data::Dumper::Maxdepth = 2;
use Resource;
use DateTimeFactory;

my $l = 'b7qv527m99oqlq3md28cof16jc@group.calendar.google.com';
my $r= Resource->new({ calendar => $l});

warn Dumper $r->vacancies;
# p ($r);



# my $f = DateTimeFactory->new;
# warn Dumper $f->durcmp(DateTime::Duration->new(days=>4, hours=>2), DateTime::Duration->new(days=>10, hours =>5));

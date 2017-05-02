package FSMUtils;

use strict;
use warnings;
use utf8;
use Data::Dumper;

=method  _with_text

Perform a callback on message text

=cut

sub _with_text {
    my ( $update, $callback ) = @_;
    defined $update
      && defined $update->{message}
      && defined $update->{message}->{text}
      ? $callback->( $update->{message}->{text} )
      : undef;
}


=method _parse_value

Perform a callback on message text

$state = FSA::State object

$parser =

@data = previous sent data

=cut

sub _parse_value {
    my ( $state, $parser, @data ) = @_;
    warn "".(caller(0))[3]."() : ".Dumper \@_;

    my $parsed = $parser->(@data);
    if ( defined $parsed ) {
        $state->result($parsed);
    }

    defined $parsed;
}

1;

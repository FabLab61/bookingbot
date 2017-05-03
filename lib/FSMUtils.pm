package FSMUtils;

use strict;
use warnings;
use utf8;
use Data::Dumper;

=method  _with_text

Perform a callback on message text

Performing on SCALAR

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

Perform a callback on data. Depends on FSA::State object

@data = previous sent data in some cases (kind of serialization)

Return https://metacpan.org/pod/FSA::Rules#result

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

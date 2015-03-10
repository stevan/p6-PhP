#!perl6

use v6;

use PhP;

sub MAIN ($source) {
    my $unit = PhP::run( ~ $source );
    say ~ $unit.root;
    say ~ $unit.result;
}

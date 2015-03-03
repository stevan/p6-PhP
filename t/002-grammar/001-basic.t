#!perl6

use v6;
use lib 'lib';
use Test;

use PhP::Parser;

plan *;


# 'let add = func (x, y) { x + y } in add( 10, 10 ) ;;',
# 'let x = 10 in if (x == 10) then true else false ;;', 

my $source = 'let rec factorial = func (n) { if ( n == 1 ) then 1 else n * factorial( n - 1 ) } in factorial( 5 ) ;;';

ok ?( PhP::Parser::parse( $source ) ), '... this successfully parsed';

done;


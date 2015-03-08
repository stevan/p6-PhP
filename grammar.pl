#!perl6

use v6;

use PhP;

my $actions = PhP::Parser::Actions.new;
my $match   = PhP::Parser::Grammar.parse(
q[

let x = 10, 
    y = 20,
    z = 30 in 
    x + y
;;

],
:$actions
);
say ~ $match.made.gist;

#!perl6

use v6;

grammar PhP {
    token TOP  { <statement> }

    rule statement {
        [
        | <let-statement>  
        ]
    }

    rule let-statement {
        "let" <.ws>? <identifier> <.ws>? "=" <.ws>? <expression> <.ws>? "in" <.ws>? <expression> <.ws>? ";;"
    }    

    rule expression {
        [    
        | <binary-expression>
        | <literal>        
        | <identifier>              
        ]
    }

    rule binary-expression {
        [
        | <literal>    <.ws>? <binary-op> <.ws>? <expression> 
        | <identifier> <.ws>? <binary-op> <.ws>? <expression> 
        ]
    }

    token binary-op {
        [
        | "+"  | "-"  | "*" | "/" 
        | "==" | "!=" 
        | "<"  | "<=" | "=>" | ">"
        ]
    }

    token literal {
        [
        | "true" | "false" | "nil"
        | <quoted-text>
        | \d+  # FIXME - this is wildly insufficient
        ]
    }

    token quoted-text {
        \"
        [
        | <-["\\]> # Anything not a " or \
        | '\"'     # Or \", an escaped quotation mark
        ]*         # Any number of times 
        \"         # "
    }

    token identifier       { <.identifier-start><.identifier-rest>* }
    token identifier-start { <[A..Za..z_]>     }
    token identifier-rest  { <[A..Za..z0..9_]> }
}

my $match = PhP.parse('let x = 2 + 2 in x + 3 * 10 / x ;;');
say ~ $match.gist;

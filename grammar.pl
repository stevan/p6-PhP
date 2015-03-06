#!perl6

use v6;

grammar PhP {
    token TOP  { <statement> }

    rule statement {
        [
        | <let-statement> 
        | <let-rec-statement> 
        ]
    }

    # let blocks ...

    rule let-statement {
        "let" <.ws>? <let-value> <.ws>? "in" <.ws>? <let-body> <.ws>? ";;"
    }    

    rule let-value {
        <identifier> <.ws>? "=" <.ws>? <let-statement-value>
    }

    rule let-statement-value {
        [
        | <func-statement>  
        | <expression>
        ]
    } 

    rule let-body {
        <expression>
    } 

    # let rec

    rule let-rec-statement {
        "let" <.ws>? "rec" <.ws>? <let-value-set> <.ws>? "in" <.ws>? <let-body> <.ws>? ";;"
    }    

    rule let-value-set {
        <let-value> ("," <let-value-set>)?
    }

    # functions ...

    rule func-statement {
        "fun" <.ws>? "(" <func-param-list> ")" <.ws>? "\{" <.ws>? <func-body> <.ws>? "\}"
    }    

    rule func-param-list {
        <func-param> ("," <func-param-list>)?
    }

    rule func-param {
        <identifier>
    }

    rule func-body {
        <expression>
    }

    # expressions ...

    rule expression {
        [    
        | <cons-cell-expression>
        | <apply-expression>
        | <cond-expression>
        | <binary-expression>
        | <literal>        
        | <identifier>  
        | "(" <expression> ")"            
        ]
    }

    rule cons-cell-expression {
        "[" <.ws>? <cons-cell-expression-head> <.ws>? <cons-cell-expression-tail>+ <.ws>? "]"
    }

    rule cons-cell-expression-head {
        <expression>
    }

    rule cons-cell-expression-tail {
        "::" <.ws>? <expression>
    }

    rule apply-expression {
        <identifier> <.ws>? "(" <.ws>? <apply-argument-list> <.ws>? ")"
    }

    rule apply-argument-list {
        <expression> ("," <apply-argument-list>)?
    }

    rule cond-expression {
        "if" <.ws>? <expression> <.ws>? "then" <.ws>? <expression> <.ws>? "else" <.ws>? <expression>
    }

    rule binary-expression {
        [
        | <literal>    <.ws>? <binary-op> <.ws>? <expression> 
        | <identifier> <.ws>? <binary-op> <.ws>? <expression> 
        ]
    }

    # tokens ....

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

my $match = PhP.parse('let rec bar = (20 + 2), foo = [ 10 :: 30 :: 40 ] in (if x == 10 then foo(20, 30, 2+2) else 30 - bar) ;;');
say ~ $match.gist;

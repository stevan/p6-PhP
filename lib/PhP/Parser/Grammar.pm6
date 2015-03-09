use v6;

grammar PhP::Parser::Grammar {

    token TOP  { <.ws>? <statement> }

    rule statement {
        [
        | <let-statement> 
        | <expression>
        ]
    }

    # let blocks ...

    rule let-statement {
        "let" <.ws>? <let-value>+ <.ws>? "in" <.ws>? <let-body=statement> <.ws>? ";;"?
    }    

    rule let-value {
        <identifier> <.ws>? "=" <.ws>? <let-statement-value> (",")?
    }

    rule let-statement-value {
        [
        | <func-statement>  
        | <expression>
        ]
    } 

    # functions ...

    rule func-statement {
        "func" <.ws>? "(" <func-param>+ ")" <.ws>? "\{" <.ws>? <func-body> <.ws>? "\}"
    }    

    rule func-param {
        <identifier> (",")?
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
        | "("    <.ws>?    ")"
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
        <identifier> <.ws>? "(" <.ws>? <apply-argument>+ <.ws>? ")"
    }

    rule apply-argument {
        <expression> (",")?
    }

    rule cond-expression {
        "if" <.ws>? <condition=.expression> <.ws>? "then" <.ws>? <if_true=.expression> <.ws>? "else" <.ws>? <if_false=.expression>
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
        | "<"  | "<=" | ">=" | ">"
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



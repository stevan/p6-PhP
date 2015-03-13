use v6;

grammar PhP::Parser::Grammar {

    token TOP  { <.ws>? <statement> }

    rule statement {
        [
        | <let-statement> 
        | <expression>
        | { die "I was expecting either a `let` block or a bare expression, I got neither."}
        ]
    }

    # let blocks ...

    rule let-statement {
        "let" <.ws>? <let-binding>+ <.ws>? "in" <.ws>? <let-body=statement> <.ws>? ";;"?
    }    

    rule let-binding {
        <identifier> <.ws>? "=" <.ws>? <let-statement-value> (",")?
    }

    rule let-statement-value {
        [
        | <func-statement>  
        | <expression>
        | { die "I was expecting either a `func` definition or a bare expression, I got neither."}
        ]
    } 

    # functions ...

    rule func-statement {
        "func" <.ws>? "(" <func-param>* ")" <.ws>? "\{" <.ws>? <func-body> <.ws>? "\}"
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
        | <tuple-expression>
        | <apply-expression>
        | <cond-expression>
        | <binary-expression>
        | <literal>        
        | <identifier>  
        | "("    <.ws>?    ")"        
        | "(" <expression> ")"
        ]
    }

    rule apply-expression {
        <identifier> <.ws>? "(" <.ws>? <apply-argument>* <.ws>? ")"
    }

    rule apply-argument {
        <expression> (",")?
    }

    rule cond-expression {
        "if" <.ws>? <condition=.expression> <.ws>? "then" <.ws>? <if_true=.expression> <.ws>? "else" <.ws>? <if_false=.expression>
    }

    rule tuple-expression {
        "[" <.ws>? <tuple-expression-item>* <.ws>? "]"
    }

    rule tuple-expression-item {
        <expression> (",")?
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
        | '::'
        ]
    }

    token literal {
        [
        | <literal-boolean>
        | <literal-string>
        | <literal-number>
        ]
    }

    token literal-number {
        \d+  # FIXME - this is wildly insufficient
    }

    token literal-boolean {
        [
        | "true" 
        | "false" 
        ]
    }

    token literal-string {
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



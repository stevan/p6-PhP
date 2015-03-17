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
        [
        | <let-simple-bind>
        | <let-destructuring-bind>
        ]
    }

    rule let-simple-bind {
        <identifier> <.ws>? "=" <.ws>? <let-statement-value> (",")?
    }

    rule let-destructuring-bind {
        "[" <.ws>? <let-destructuring-pattern=.list-of-identifiers>+ <.ws>? <splat>? <.ws>? "]" <.ws>? "=" <.ws>? <tuple-expression> (",")?
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
        "func" <.ws>? "(" <func-param=.list-of-identifiers>* ")" <.ws>? "\{" <.ws>? <func-body=.expression> <.ws>? "\}"
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
        <identifier> <.ws>? "(" <.ws>? <apply-argument=.list-of-expressions>* <.ws>? ")"
    }

    rule cond-expression {
        "if" <.ws>? <condition=.expression> <.ws>? "then" <.ws>? <if_true=.expression> <.ws>? "else" <.ws>? <if_false=.expression>
    }

    rule tuple-expression {
        "[" <.ws>? <tuple-expression-item=.list-of-expressions>* <.ws>? "]"
    }

    rule binary-expression {
        [
        | <literal>          <.ws>? <binary-op> <.ws>? <expression> 
        | <identifier>       <.ws>? <binary-op> <.ws>? <expression> 
        | <apply-expression> <.ws>? <binary-op> <.ws>? <expression> 
        ]
    }

    rule list-of-expressions {
        <expression> (",")?
    }

    rule list-of-identifiers {
        <identifier> (",")?
    }

    # tokens ....

    token splat {
        "*"
    }

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

    token identifier {
        [
        | <namespaced-identifier>
        | <local-identifier>
        ]
    }

    token namespaced-identifier { <namespace=.local-identifier> "." <name=.local-identifier> }

    token local-identifier       { <.local-identifier-start><.local-identifier-rest>* }
    token local-identifier-start { <[A..Za..z_]>     }
    token local-identifier-rest  { <[A..Za..z0..9_]> }
}



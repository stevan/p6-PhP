#!perl6

## ---------------------------------------------

class Env {
    has %.pad;

    method get    ( Str $key )             { %.pad{ $key }          }
    method set    ( Str $key, Any $value ) { %.pad{ $key } = $value }
}

## ---------------------------------------------

class Ast {

    method evaluate ( Env $env ) {
        die "Unknown Ast Node: " ~ self;
    }
}

class Const is Ast {
    has Any $.value;

    method evaluate ( Env $env ) {
        return self;
    }

    method Str { "Const(" ~ $.value ~ ")" }
}

class Var is Ast {
    has Str $.name;

    method evaluate ( Env $env ) {
        return $env.get( $.name ) // die "Unable to find the variable: " ~ $.name;
    }

    method Str { "Var\{" ~ $.name ~ "\}" }
}

class Cons is Ast {
    has Ast $.head;
    has Ast $.tail;

    method evaluate ( Env $env ) {
        return self;
    }    
 
    method Str { "Cons[ " ~ $.head ~ " :: " ~ $.tail ~ " ]" }
}

class Fun is Ast {
    has     @.params;
    has Ast $.body;

    method evaluate ( Env $env ) {
        return -> @args {
            my $new_env = $env.clone;
            loop (my $i = 0; $i < @args.elems; $i++ ) {
                $new_env.set( @.params[ $i ], @args[ $i ] )
            }
            $.body.evaluate( $new_env );
        }
    }

    method Str { "Fun (" ~ @.params.join(", ") ~ ") \{ " ~ $.body ~ " \}" }
}

class Let is Ast {
    has Str $.name;
    has Ast $.value;
    has Ast $.body;

    method evaluate ( Env $env ) {
        my $new_env = $env.clone;
        $new_env.set( $.name, $.value.evaluate( $env ) );
        return $.body.evaluate( $new_env );
    }

    method Str { "Let " ~ $.name ~ " = " ~ $.value ~ "; " ~ $.body ~ ";" }
}

class Apply is Ast {
    has Str $.name;
    has     @.args;

    method evaluate ( Env $env ) {

        my $code    = $env.get( $.name ) // die "Unable to find function to apply: " ~ $.name;;
        my $new_env = $env.clone;
        $code(
            self.args.map( -> $arg { 
                $arg.evaluate( $new_env ) 
            })
        );
    }

    method Str { "Appy " ~ $.name ~ "(" ~ @.args.join(", ") ~ ")" }
}

## ---------------------------------------------

my Env $root_env = Env.new;

$root_env.set(
    '+', -> ($l, $r) { 
        Const.new( value => $l.value + $r.value )
    }
);

say ~ Let.new(
        name  => 'add',
        value => Fun.new(
            params => [ 'x', 'y' ],
            body   => Apply.new(
                name => '+',
                args => [
                    Var.new( name => 'x' ),
                    Var.new( name => 'y' ),
                ]
            )
        ),
        body  => Apply.new(
            name => 'add',
            args => [
                Const.new( value => 20 ),
                Const.new( value => 30 ),
            ]
        ),
    ); #.evaluate( $root_env );

## ---------------------------------------------

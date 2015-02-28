#!perl6

## ---------------------------------------------

class Ast {}
class Const is Ast {
    has Any $.value;

    method Str { "Const< " ~ $.value ~ " >" }
}

class Var is Ast {
    has Str $.name;

    method Str { "Var< " ~ $.name ~ " >" }
}

class Cons is Ast {
    has Ast $.head;
    has Ast $.tail;
 
    method Str { "Cons< " ~ $.head ~ " :: " ~ $.tail ~ " >" }
}

class Fun is Ast {
    has     @.params;
    has Ast $.body;

    method Str { "Fun< (" ~ @.params.join(", ") ~ ") " ~ $.body ~ " >" }
}

class Let is Ast {
    has Str $.name;
    has Ast $.value;
    has Ast $.body;

    method Str { "Let< " ~ $.name ~ " = " ~ $.value ~ "; " ~ $.body ~ " >" }
}

class Apply is Ast {
    has Str $.name;
    has     @.args;

    method Str { "Appy< " ~ $.name ~ " (" ~ @.args.join(", ") ~ ") >" }
}

## ---------------------------------------------

class Env {
    has %.pad;

    method get    ( Str $key )             { %.pad{ $key }          }
    method set    ( Str $key, Any $value ) { %.pad{ $key } = $value }
}

## ---------------------------------------------

multi evalPhP ( Fun $exp, Env $env ) {
    return -> @args {
        my $new_env = $env.clone;
        loop (my $i = 0; $i < @args.elems; $i++ ) {
            $new_env.set( $exp.params[ $i ], @args[ $i ] )
        }
        evalPhP( $exp.body, $new_env );
    }
}

multi evalPhP ( Apply $exp, Env $env ) {

    my $code    = $env.get( $exp.name );
    my $new_env = $env.clone;
    $code(
        $exp.args.map( -> $arg { 
            evalPhP( $arg, $new_env ) 
        })
    );
}

multi evalPhP ( Let $exp, Env $env ) {
    my $new_env = $env.clone;
    $new_env.set( $exp.name, evalPhP( $exp.value, $env ) );
    return evalPhP( $exp.body, $new_env );
}

multi evalPhP ( Cons $exp, Env $env ) {
    return $exp;
}

multi evalPhP ( Var $exp, Env $env ) {
    return $env.get( $exp.name ) // die "Unable to find the variable: " ~ $exp.name;
}

multi evalPhP ( Const $exp, Env $env ) {
    return $exp;
}

multi evalPhP ( Ast $exp, Env $env ) {
    die "Unknown Ast Node: $exp";
}

## ---------------------------------------------

my Env $root_env = Env.new;

$root_env.set(
    '+', -> ($l, $r) { 
        Const.new( value => $l.value + $r.value )
    }
);

say ~ evalPhP( 
    Let.new(
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
    ), 
    $root_env
);

## ---------------------------------------------

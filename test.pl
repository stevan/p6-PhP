#!perl6

## ---------------------------------------------

class Env {
    has %.pad;

    method get    ( Str $key )             { %.pad{ $key }          }
    method set    ( Str $key, Any $value ) { %.pad{ $key } = $value }
}

## ---------------------------------------------

class Ast {}

class Literal is Ast {
    has Any $.value;
}

class Variable is Ast {
    has Str $.name;
}

class ConsCell is Ast {
    has Ast $.head;
    has Ast $.tail;
}

class Function is Ast {
    has     @.params;
    has Ast $.body;
}

class Let is Ast {
    has Str $.name;
    has Ast $.value;
    has Ast $.body;
}

class LetRec is Ast {
    has     @.definitions;
    has Ast $.body;
}

class Condition is Ast { 
    has Ast $.condition;
    has Ast $.if_true;
    has Ast $.if_false;
}

class Apply is Ast {
    has Str $.name;
    has     @.args;
}

## ---------------------------------------------

multi pprint ( Ast       $node ) { "" }
multi pprint ( Literal   $node ) { "Literal(" ~ $node.value ~ ")" }
multi pprint ( Variable  $node ) { "Variable(" ~ $node.name ~ ")" }
multi pprint ( ConsCell  $node ) { "Cons[ " ~ $node.head ~ " !! " ~ $node.tail ~ " ]" }
multi pprint ( Function  $node ) { "Fun (" ~ $node.params.join(", ") ~ ") \{ " ~ $node.body ~ " \}" }
multi pprint ( Let       $node ) { "Let " ~ $node.name ~ " = " ~ $node.value ~ "; " ~ $node.body ~ ";" }
multi pprint ( LetRec    $node ) { "Let Rec " ~ $node.definitions ~ "; " ~ $node.body ~ ";" }
multi pprint ( Apply     $node ) { "Appy " ~ $node.name ~ "(" ~ $node.args.join(", ") ~ ")" }
multi pprint ( Condition $node ) { "Condition " ~ $node.condition ~ "{" ~ $node.if_true ~ "} else {" ~ $node.if_false ~ "}" }

## ---------------------------------------------

multi evaluate ( Ast $exp, Env $env ) {
    die "Unknown Ast Node: " ~ $exp;
}

multi evaluate ( Literal $exp, Env $env ) {
    return $exp;
}

multi evaluate ( Variable $exp, Env $env ) {
    return $env.get( $exp.name ) // die "Unable to find the variable: " ~ $exp.name;
}

multi evaluate ( ConsCell $exp, Env $env ) {
    return $exp;
}    

multi evaluate ( Function $exp, Env $env ) {
    return -> @args {
        my $new_env = $env.clone;
        loop (my $i = 0; $i < @args.elems; $i++ ) {
            $new_env.set( $exp.params[ $i ], @args[ $i ] )
        }
        evaluate( $exp.body, $new_env );
    }
}

multi evaluate ( Let $exp, Env $env ) {
    my $new_env = $env.clone;
    $new_env.set( $exp.name, evaluate( $exp.value, $env ) );
    return evaluate( $exp.body, $new_env );
}

multi evaluate ( LetRec $exp, Env $env ) {
    my $new_env = $env.clone;
    my @defs    = $exp.definitions.clone;

    while ( @defs ) {
        my ($var, $value) = (@defs.shift, @defs.shift);
        $env.set( $var, evaluate( $value, $new_env ) );
    }

    return evaluate( $exp.body, $new_env );
}

multi evaluate ( Apply $exp, Env $env ) {
    my $code    = $env.get( $exp.name ) // die "Unable to find function to apply: " ~ $exp.name;
    my $new_env = $env.clone;
    $code(
        $exp.args.map( -> $arg { evaluate( $arg, $new_env ) })
    );
}

multi evaluate ( Condition $exp, Env $env ) {
    evaluate( $exp.condition, $env ) === $env.get('#TRUE')
        ?? evaluate( $exp.if_true, $env )
        !! evaluate( $exp.if_false, $env )
}

## ---------------------------------------------

my $TRUE  = Literal.new( value => 1 );
my $FALSE = Literal.new( value => 0 );

## ---------------------------------------------

my Env $root_env = Env.new;

$root_env.set('#TRUE',  $TRUE);
$root_env.set('#FALSE', $FALSE);

$root_env.set('+', -> ($l, $r) { Literal.new( value => $l.value + $r.value ) });
$root_env.set('*', -> ($l, $r) { Literal.new( value => $l.value * $r.value ) });
$root_env.set('/', -> ($l, $r) { Literal.new( value => $l.value / $r.value ) });
$root_env.set('-', -> ($l, $r) { Literal.new( value => $l.value - $r.value ) });

$root_env.set('==', -> ($l, $r) { ($l.value == $r.value) ?? $TRUE !! $FALSE });
$root_env.set('!=', -> ($l, $r) { ($l.value != $r.value) ?? $TRUE !! $FALSE });
$root_env.set('<' , -> ($l, $r) { ($l.value <  $r.value) ?? $TRUE !! $FALSE });
$root_env.set('<=', -> ($l, $r) { ($l.value <= $r.value) ?? $TRUE !! $FALSE });
$root_env.set('>' , -> ($l, $r) { ($l.value >  $r.value) ?? $TRUE !! $FALSE });
$root_env.set('>=', -> ($l, $r) { ($l.value >= $r.value) ?? $TRUE !! $FALSE });

say pprint evaluate
    LetRec.new(
        definitions => [
            'mul', Function.new(
                params => [ 'x', 'y' ],
                body   => Condition.new(
                    condition => Apply.new( 
                        name => '==',
                        args => [
                            Variable.new( name => 'y' ),
                            Literal.new( value => 1 )
                        ]
                    ),
                    if_true  => Variable.new( name => 'x' ),
                    if_false => Apply.new(
                        name => '+',
                        args => [
                            Variable.new( name => 'x' ),
                            Apply.new(
                                name => 'mul',
                                args => [
                                    Variable.new( name => 'x' ),
                                    Apply.new(
                                        name => '-',
                                        args => [
                                            Variable.new( name => 'y' ),
                                            Literal.new( value => 1 )
                                        ]
                                    )
                                ]
                            )
                        ]
                    )
                )
            )
        ],
        body => Apply.new(
            name => 'mul',
            args => [
                Literal.new( value => 5 ),
                Literal.new( value => 5 )
            ]
        )
    ),
    #Condition.new(
    #    condition => Apply.new(
    #        name => '==',
    #        args => [
    #            Literal.new( value => 2 ),
    #            Literal.new( value => 3 ),
    #        ]
    #    ),
    #    if_true  => Literal.new( value => 'TRUE!!!'  ),
    #    if_false => Literal.new( value => 'FALSE!!!' ),
    #), 
    $root_env 
;

## ---------------------------------------------

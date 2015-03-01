#!perl6

## ---------------------------------------------

class Ast {}

class Literal is Ast {
    has Any $.value;
}

class Var is Ast {
    has Str $.name;
}

class ConsCell is Ast {
    has Ast $.head;
    has Ast $.tail;
}

class Func is Ast {
    has Str @.params;
    has Ast $.body;
}

class NativeFunc is Ast {
    has Str   @.params;
    has Block $.extern;
}

class Let is Ast {
    has Str $.name;
    has Ast $.value;
    has Ast $.body;
}

class LetRec is Ast {
    has Pair @.definitions;
    has Ast  $.body;
}

class Cond is Ast { 
    has Ast $.condition;
    has Ast $.if_true;
    has Ast $.if_false;
}

class Apply is Ast {
    has Str $.name;
    has Ast @.args;
}

## ---------------------------------------------

class Env {
    has Env $.parent;
    has Ast %.pad;

    method get ( Str  $key  ) { %.pad{ $key } // $.parent.?get( $key ) }
    method set ( Pair $pair ) { %.pad{ $pair.key } = $pair.value       }
}

## ---------------------------------------------

multi evaluate ( Ast $exp, Env $env ) {
    die "Unknown Ast Node: " ~ $exp;
}

multi evaluate ( Literal $exp, Env $env ) {
    return $exp;
}

multi evaluate ( Var $exp, Env $env ) {
    return $env.get( $exp.name ) // die "Unable to find the variable: " ~ $exp.name;
}

multi evaluate ( ConsCell $exp, Env $env ) {
    return $exp;
}    

multi evaluate ( Let $exp, Env $env ) {
    my $new_env = Env.new( :parent( $env ) );
    $new_env.set: $exp.name => evaluate( $exp.value, $new_env );
    evaluate( $exp.body, $new_env );
}

multi evaluate ( LetRec $exp, Env $env ) {
    my $new_env = Env.new( :parent( $env ) );
    for $exp.definitions -> $def { 
        $new_env.set: $def.key => evaluate( $def.value, $new_env ) 
    }
    evaluate( $exp.body, $new_env );
}

multi evaluate ( Func $exp, Env $env ) {
    return $exp;
}

multi evaluate ( NativeFunc $exp, Env $env ) {
    return $exp;
}

multi evaluate ( Apply $exp, Env $env ) {
    my $code    = $env.get( $exp.name ) // die "Unable to find function to apply: " ~ $exp.name;
    my $new_env = Env.new( :parent( $env ) );

    loop (my $i = 0; $i < $exp.args.elems; $i++ ) {
        $new_env.set: $code.params[ $i ] => evaluate( $exp.args[ $i ], $new_env );
    }

    return $code.extern.( $new_env ) if $code.?extern;
    return evaluate( $code.body, $new_env );
}

multi evaluate ( Cond $exp, Env $env ) {
    evaluate( $exp.condition, $env ) === $env.get('#TRUE')
        ?? evaluate( $exp.if_true, $env )
        !! evaluate( $exp.if_false, $env )
}

## ---------------------------------------------

my $TRUE  = Literal.new( :value( True  ) );
my $FALSE = Literal.new( :value( False ) );

## ---------------------------------------------

my Env $root_env .= new;

$root_env.set: '#TRUE'  => $TRUE;
$root_env.set: '#FALSE' => $FALSE;

$root_env.set: '+' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { Literal.new( :value( $env.get('l').value + $env.get('r').value ) ) } ) );
$root_env.set: '*' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { Literal.new( :value( $env.get('l').value * $env.get('r').value ) ) } ) );
$root_env.set: '/' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { Literal.new( :value( $env.get('l').value / $env.get('r').value ) ) } ) );
$root_env.set: '-' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { Literal.new( :value( $env.get('l').value - $env.get('r').value ) ) } ) );

$root_env.set: '==' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value == $env.get('r').value) ?? $TRUE !! $FALSE } ) );
$root_env.set: '!=' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value != $env.get('r').value) ?? $TRUE !! $FALSE } ) );
$root_env.set: '<'  => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value <  $env.get('r').value) ?? $TRUE !! $FALSE } ) );
$root_env.set: '<=' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value <= $env.get('r').value) ?? $TRUE !! $FALSE } ) );
$root_env.set: '>'  => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value >  $env.get('r').value) ?? $TRUE !! $FALSE } ) );
$root_env.set: '>=' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value >= $env.get('r').value) ?? $TRUE !! $FALSE } ) );

my $root_node = LetRec.new(
    :definitions(
        'mul' => Func.new(
            :params( 'x', 'y' ),
            :body(
                Cond.new(
                    :condition(
                        Apply.new( 
                            :name( '==' ),
                            :args(
                                Var.new( :name( 'y' ) ),
                                Literal.new( :value(  1  ) ),
                            )
                        )
                    ),
                    :if_true( Var.new( :name( 'x' ) ) ),
                    :if_false(
                        Apply.new(
                            :name( '+' ),
                            :args(
                                Var.new( :name( 'x' ) ),
                                Apply.new(
                                    :name( 'mul' ),
                                    :args(
                                        Var.new( :name( 'x' ) ),
                                        Apply.new(
                                            :name( '-' ),
                                            :args(
                                                Var.new( :name( 'y' ) ),
                                                Literal.new( :value(  1  ) ),
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    ),
    :body(
        Apply.new(
            :name( 'mul' ),
            :args(
                Literal.new( :value( 5 ) ),
                Literal.new( :value( 5 ) ),
            )
        )
    )
);

say evaluate( $root_node, $root_env ).perl;

## ---------------------------------------------

#Cond.new(
#    condition => Apply.new(
#        :name( '==' ),
#        :args(
#            Literal.new( value => 2 ),
#            Literal.new( value => 3 ),
#        )
#    ),
#    if_true  => Literal.new( value => 'TRUE!!!'  ),
#    if_false => Literal.new( value => 'FALSE!!!' ),
#),


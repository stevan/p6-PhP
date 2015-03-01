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

class Scope {
    has Env @.env;

    method current { @.env[*-1] }
    method enter   { @.env.push( Env.new( :parent( self.current ) ) ) }
    method leave   { @.env.pop }
}

## ---------------------------------------------

multi evaluate ( Ast $exp, Scope $scope ) {
    die "Unknown Ast Node: " ~ $exp;
}

multi evaluate ( Literal $exp, Scope $scope ) {
    return $exp;
}

multi evaluate ( Var $exp, Scope $scope ) {
    return $scope.current.get( $exp.name ) // die "Unable to find the variable: " ~ $exp.name;
}

multi evaluate ( ConsCell $exp, Scope $scope ) {
    return $exp;
}    

multi evaluate ( Let $exp, Scope $scope ) {
    $scope.enter;
    $scope.current.set: $exp.name => evaluate( $exp.value, $scope );
    my $result = evaluate( $exp.body, $scope );
    $scope.leave;
    $result;
}

multi evaluate ( LetRec $exp, Scope $scope ) {
    $scope.enter;
    for $exp.definitions -> $def { 
        $scope.current.set: $def.key => evaluate( $def.value, $scope ) 
    }
    my $result = evaluate( $exp.body, $scope );
    $scope.leave;
    $result;
}

multi evaluate ( Func $exp, Scope $scope ) {
    return $exp;
}

multi evaluate ( NativeFunc $exp, Scope $scope ) {
    return $exp;
}

multi evaluate ( Apply $exp, Scope $scope ) {
    my $code = $scope.current.get( $exp.name ) // die "Unable to find function to apply: " ~ $exp.name;

    $scope.enter;

    loop (my $i = 0; $i < $exp.args.elems; $i++ ) {
        $scope.current.set: $code.params[ $i ] => evaluate( $exp.args[ $i ], $scope );
    }

    my $result = do if $code.?extern {
        $code.extern.( $scope );
    } else {
        evaluate( $code.body, $scope );
    };

    $scope.leave;
    $result;
}

multi evaluate ( Cond $exp, Scope $scope ) {
    evaluate( $exp.condition, $scope ) === $scope.current.get('#TRUE')
        ?? evaluate( $exp.if_true, $scope )
        !! evaluate( $exp.if_false, $scope )
}

## ---------------------------------------------

my $TRUE  = Literal.new( :value( True  ) );
my $FALSE = Literal.new( :value( False ) );

## ---------------------------------------------

my Env $root_env .= new;

$root_env.set: '#TRUE'  => $TRUE;
$root_env.set: '#FALSE' => $FALSE;

$root_env.set: '+' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($scope) { Literal.new( :value( $scope.current.get('l').value + $scope.current.get('r').value ) ) } ) );
$root_env.set: '*' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($scope) { Literal.new( :value( $scope.current.get('l').value * $scope.current.get('r').value ) ) } ) );
$root_env.set: '/' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($scope) { Literal.new( :value( $scope.current.get('l').value / $scope.current.get('r').value ) ) } ) );
$root_env.set: '-' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($scope) { Literal.new( :value( $scope.current.get('l').value - $scope.current.get('r').value ) ) } ) );

$root_env.set: '==' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($scope) { ($scope.current.get('l').value == $scope.current.get('r').value) ?? $TRUE !! $FALSE } ) );
$root_env.set: '!=' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($scope) { ($scope.current.get('l').value != $scope.current.get('r').value) ?? $TRUE !! $FALSE } ) );
$root_env.set: '<'  => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($scope) { ($scope.current.get('l').value <  $scope.current.get('r').value) ?? $TRUE !! $FALSE } ) );
$root_env.set: '<=' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($scope) { ($scope.current.get('l').value <= $scope.current.get('r').value) ?? $TRUE !! $FALSE } ) );
$root_env.set: '>'  => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($scope) { ($scope.current.get('l').value >  $scope.current.get('r').value) ?? $TRUE !! $FALSE } ) );
$root_env.set: '>=' => NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($scope) { ($scope.current.get('l').value >= $scope.current.get('r').value) ?? $TRUE !! $FALSE } ) );

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

say evaluate( $root_node, Scope.new( :env($root_env) ) ).perl;

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


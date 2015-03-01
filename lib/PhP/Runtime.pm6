package PhP::Runtime {

    use PhP::Parser;

    class Env {
        has Env              $.parent;
        has PhP::Parser::Ast %.pad;

        method get ( Str  $key  ) { %.pad{ $key } // $.parent.?get( $key ) }
        method set ( Pair $pair ) { %.pad{ $pair.key } = $pair.value       }
    }

    my Bool $IS_BOOTSTRAPPED = False;
    my Env  $ROOT_ENV;

    our sub is_bootstrapped { $IS_BOOTSTRAPPED }
    our sub root_env        { $ROOT_ENV }

    our sub bootstrap {
        state $TRUE  = PhP::Parser::Literal.new( :value( True  ) );
        state $FALSE = PhP::Parser::Literal.new( :value( False ) );

        return if $IS_BOOTSTRAPPED;

        $ROOT_ENV .= new;
        $ROOT_ENV.set: '#TRUE'  => $TRUE;
        $ROOT_ENV.set: '#FALSE' => $FALSE;

        $ROOT_ENV.set: '+' => PhP::Parser::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::Parser::Literal.new( :value( $env.get('l').value + $env.get('r').value ) ) } ) );
        $ROOT_ENV.set: '*' => PhP::Parser::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::Parser::Literal.new( :value( $env.get('l').value * $env.get('r').value ) ) } ) );
        $ROOT_ENV.set: '/' => PhP::Parser::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::Parser::Literal.new( :value( $env.get('l').value / $env.get('r').value ) ) } ) );
        $ROOT_ENV.set: '-' => PhP::Parser::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::Parser::Literal.new( :value( $env.get('l').value - $env.get('r').value ) ) } ) );

        $ROOT_ENV.set: '==' => PhP::Parser::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value == $env.get('r').value) ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: '!=' => PhP::Parser::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value != $env.get('r').value) ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: '<'  => PhP::Parser::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value <  $env.get('r').value) ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: '<=' => PhP::Parser::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value <= $env.get('r').value) ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: '>'  => PhP::Parser::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value >  $env.get('r').value) ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: '>=' => PhP::Parser::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value >= $env.get('r').value) ?? $TRUE !! $FALSE } ) );

        $IS_BOOTSTRAPPED = True;
    }
}
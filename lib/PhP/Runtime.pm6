use v6;

package PhP::Runtime {

    use PhP::AST;

    class Env {
        has Env           $.parent;
        has Env           @.children;        
        has PhP::AST::Ast %.pad;

        submethod BUILD ( :$parent ) {
            if $parent.defined {
                $parent.children.push: self;
                $!parent = $parent;
            }
        }

        method get ( Str  $key  ) { %.pad{ $key } // $.parent.?get( $key ) }
        method set ( Pair $pair ) { %.pad{ $pair.key } = $pair.value       }
    }

    my Bool $IS_BOOTSTRAPPED = False;
    my Env  $ROOT_ENV;

    our sub is_bootstrapped { $IS_BOOTSTRAPPED }
    our sub root_env        { $ROOT_ENV }

    our sub bootstrap {
        state $TRUE  = PhP::AST::Literal.new( :value( True  ) );
        state $FALSE = PhP::AST::Literal.new( :value( False ) );
        state $NIL   = PhP::AST::ConsCell.new;

        return if $IS_BOOTSTRAPPED;

        $ROOT_ENV .= new;
        $ROOT_ENV.set: '#TRUE'  => $TRUE;
        $ROOT_ENV.set: '#FALSE' => $FALSE;
        $ROOT_ENV.set: '#NIL'   => $NIL;

        $ROOT_ENV.set: '+' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::AST::Literal.new( :value( $env.get('l').value + $env.get('r').value ) ) } ) );
        $ROOT_ENV.set: '*' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::AST::Literal.new( :value( $env.get('l').value * $env.get('r').value ) ) } ) );
        $ROOT_ENV.set: '/' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::AST::Literal.new( :value( $env.get('l').value / $env.get('r').value ) ) } ) );
        $ROOT_ENV.set: '-' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::AST::Literal.new( :value( $env.get('l').value - $env.get('r').value ) ) } ) );

        $ROOT_ENV.set: '==' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value == $env.get('r').value) ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: '!=' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value != $env.get('r').value) ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: '<'  => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value <  $env.get('r').value) ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: '<=' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value <= $env.get('r').value) ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: '>'  => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value >  $env.get('r').value) ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: '>=' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value >= $env.get('r').value) ?? $TRUE !! $FALSE } ) );

        $ROOT_ENV.set: '::'     => PhP::AST::NativeFunc.new( :params( 'h', 't' ) :extern( sub ($env) { PhP::AST::ConsCell.new(:head($env.get('h')), :tail($env.get('t'))) } ) );
        $ROOT_ENV.set: 'head'   => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_nil ?? die "Cannot call `head` on #NIL" !! $env.get('x').head } ) );
        $ROOT_ENV.set: 'tail'   => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_nil ?? die "Cannot call `tail` on #NIL" !! $env.get('x').tail } ) );
        $ROOT_ENV.set: 'is_nil' => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_nil ?? $TRUE !! $FALSE } ) );

        $IS_BOOTSTRAPPED = True;
    }
}
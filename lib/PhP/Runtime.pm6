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

    our $TRUE  = PhP::AST::Literal.new( :value( True  ) );
    our $FALSE = PhP::AST::Literal.new( :value( False ) );
    our $NIL   = PhP::AST::ConsCell.new;

    class RootEnv is Env {
        has Bool $!is_bootstrapped = False;

        method bootstrap {
            return self if $!is_bootstrapped;

            self.set: '#TRUE'  => $TRUE;
            self.set: '#FALSE' => $FALSE;
            self.set: '#NIL'   => $NIL;

            self.set: '+' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::AST::Literal.new( :value( $env.get('l').value + $env.get('r').value ) ) } ) );
            self.set: '*' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::AST::Literal.new( :value( $env.get('l').value * $env.get('r').value ) ) } ) );
            self.set: '/' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::AST::Literal.new( :value( $env.get('l').value / $env.get('r').value ) ) } ) );
            self.set: '-' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { PhP::AST::Literal.new( :value( $env.get('l').value - $env.get('r').value ) ) } ) );

            self.set: '==' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value == $env.get('r').value) ?? $TRUE !! $FALSE } ) );
            self.set: '!=' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value != $env.get('r').value) ?? $TRUE !! $FALSE } ) );
            self.set: '<'  => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value <  $env.get('r').value) ?? $TRUE !! $FALSE } ) );
            self.set: '<=' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value <= $env.get('r').value) ?? $TRUE !! $FALSE } ) );
            self.set: '>'  => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value >  $env.get('r').value) ?? $TRUE !! $FALSE } ) );
            self.set: '>=' => PhP::AST::NativeFunc.new( :params( 'l', 'r' ) :extern( sub ($env) { ($env.get('l').value >= $env.get('r').value) ?? $TRUE !! $FALSE } ) );

            self.set: '::'     => PhP::AST::NativeFunc.new( :params( 'h', 't' ) :extern( sub ($env) { PhP::AST::ConsCell.new(:head($env.get('h')), :tail($env.get('t'))) } ) );
            self.set: 'head'   => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_nil ?? die "Cannot call `head` on #NIL" !! $env.get('x').head } ) );
            self.set: 'tail'   => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_nil ?? die "Cannot call `tail` on #NIL" !! $env.get('x').tail } ) );
            self.set: 'is_nil' => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_nil ?? $TRUE !! $FALSE } ) );

            $!is_bootstrapped = True;

            return self;
        }
    }

}
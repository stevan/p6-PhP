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

        method set ( Pair $pair ) { %.pad{ $pair.key } = $pair.value }
        method get ( Str  $key  ) { 
            return %.pad{ $key } if %.pad{ $key };
            if $.parent { 
                return $.parent.?get( $key );
            } else {
                die "Cannot find '$key' in the local Env: " ~ %.pad.gist;
            }
        }        
    }

    my Bool $IS_BOOTSTRAPPED = False;
    my Env  $ROOT_ENV;    

    our sub root_env        { $ROOT_ENV        }
    our sub is_bootstrapped { $IS_BOOTSTRAPPED }

    our sub bootstrap {
        state $TRUE  = PhP::AST::BooleanLiteral.new( value => True  );
        state $FALSE = PhP::AST::BooleanLiteral.new( value => False );

        return if $IS_BOOTSTRAPPED;

        $ROOT_ENV .= new;
        $ROOT_ENV.set: '#TRUE'  => $TRUE;
        $ROOT_ENV.set: '#FALSE' => $FALSE;

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

        $ROOT_ENV.set: '::'      => PhP::AST::NativeFunc.new( :params( 'h', 't' ) :extern( sub ($env) { PhP::AST::Tuple.new(:items($env.get('h'), $env.get('t'))) } ) );
        $ROOT_ENV.set: 'head'    => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_empty ?? die "Cannot call `head` on empty tuple" !! $env.get('x').get_item_at(0) } ) );
        $ROOT_ENV.set: 'tail'    => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_empty ?? die "Cannot call `tail` on empty tuple" !! $env.get('x').get_item_at(1) } ) );
        $ROOT_ENV.set: 'is_nil'  => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_empty ?? $TRUE !! $FALSE } ) );
        $ROOT_ENV.set: 'first'   => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_empty ?? die "Cannot call `first` on empty tuple"  !! $env.get('x').get_item_at(0) } ) );
        $ROOT_ENV.set: 'second'  => PhP::AST::NativeFunc.new( :params( 'x' ) :extern( sub ($env) { $env.get('x').is_empty ?? die "Cannot call `second` on empty tuple" !! $env.get('x').get_item_at(1) } ) );        
        $ROOT_ENV.set: 'item_at' => PhP::AST::NativeFunc.new( :params( 't', 'i' ) :extern( sub ($env) { $env.get('t').get_item_at( $env.get('i').value ) } ) );

        $IS_BOOTSTRAPPED = True;
    }

    class CompilationUnit {
        has                 %.options; # the set of options this was compiled
        has PhP::AST::Ast   $.root;    # the root node of the AST 
        has PhP::AST::Ast   $.result;  # the result of compiling the AST
        has Env             $.env;     # the environment everything will be compiled into  
        has CompilationUnit $.linked;                                       

        submethod BUILD (:%options, :$root, :$env, :$link) {
            %!options = %options;
            $!root    = $root;

            if $link.defined {
                $!linked = $link;
                $!env    = PhP::Runtime::Env.new( parent => $link.env.children[0] );
            }
            else {
                $!env = $env // PhP::Runtime::Env.new( parent => $ROOT_ENV );
            }

        }

        method has_root                       { $!root.defined }
        method set_root (PhP::AST::Ast $root) { $!root = $root }

        method has_result                         { $!result.defined   }
        method set_result (PhP::AST::Ast $result) { $!result = $result }
    }

}
package PhP::Interpreter {

    use PhP::Parser;
    use PhP::Runtime;

    our sub run ( PhP::Parser::Ast $exp ) {
        PhP::Runtime::bootstrap;
        evaluate( $exp, PhP::Runtime::root_env );
    }

    multi evaluate ( PhP::Parser::Ast $exp, PhP::Runtime::Env $env ) {
        die "Unknown Ast Node: " ~ $exp;
    }

    multi evaluate ( PhP::Parser::Literal $exp, PhP::Runtime::Env $env ) {
        return $exp;
    }

    multi evaluate ( PhP::Parser::Var $exp, PhP::Runtime::Env $env ) {
        return $env.get( $exp.name ) // die "Unable to find the variable: " ~ $exp.name;
    }

    multi evaluate ( PhP::Parser::ConsCell $exp, PhP::Runtime::Env $env ) {
        return $exp;
    }    

    multi evaluate ( PhP::Parser::Let $exp, PhP::Runtime::Env $env ) {
        my $new_env = PhP::Runtime::Env.new( :parent( $env ) );
        $new_env.set: $exp.name => evaluate( $exp.value, $new_env );
        evaluate( $exp.body, $new_env );
    }

    multi evaluate ( PhP::Parser::LetRec $exp, PhP::Runtime::Env $env ) {
        my $new_env = PhP::Runtime::Env.new( :parent( $env ) );
        for $exp.definitions -> $def { 
            $new_env.set: $def.key => evaluate( $def.value, $new_env ) 
        }
        evaluate( $exp.body, $new_env );
    }

    multi evaluate ( PhP::Parser::Func $exp, PhP::Runtime::Env $env ) {
        return $exp;
    }

    multi evaluate ( PhP::Parser::NativeFunc $exp, PhP::Runtime::Env $env ) {
        return $exp;
    }

    multi evaluate ( PhP::Parser::Apply $exp, PhP::Runtime::Env $env ) {
        my $code    = $env.get( $exp.name ) // die "Unable to find function to apply: " ~ $exp.name;
        my $new_env = PhP::Runtime::Env.new( :parent( $env ) );

        loop (my $i = 0; $i < $exp.args.elems; $i++ ) {
            $new_env.set: $code.params[ $i ] => evaluate( $exp.args[ $i ], $new_env );
        }

        return $code.extern.( $new_env ) if $code.?extern;
        return evaluate( $code.body, $new_env );
    }

    multi evaluate ( PhP::Parser::Cond $exp, PhP::Runtime::Env $env ) {
        evaluate( $exp.condition, $env ) === $env.get('#TRUE')
            ?? evaluate( $exp.if_true, $env )
            !! evaluate( $exp.if_false, $env )
    }

}
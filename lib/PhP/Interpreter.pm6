use v6;

package PhP::Interpreter {

    use PhP::AST;
    use PhP::Runtime;

    our sub run ( PhP::Runtime::CompilationUnit $unit ) {
        my $result = evaluate( $unit.root, $unit.env );
        $unit.set_result( $result );
        return $unit;
    }

    # private ...

    # handle an unknown node type ...
    multi evaluate ( PhP::AST::Ast $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        die "Unknown Ast Node: " ~ $exp;
    }

    # handle terminal nodes, they all do this ...
    multi evaluate ( PhP::AST::Terminal $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        return $exp;
    }

    # evaluate all the things!

    multi evaluate ( PhP::AST::Var $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        return $env.get( $exp.name ) // die "Unable to find the variable: " ~ $exp.name;
    } 

    multi evaluate ( PhP::AST::Let $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        my $new_env = PhP::Runtime::Env.new( :parent( $env ) );
        for $exp.definitions -> $def { 
            $new_env.set: $def.key => evaluate( $def.value, $new_env ) 
        }
        evaluate( $exp.body, $new_env );
    }

    multi evaluate ( PhP::AST::Apply $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        my $code    = $env.get( $exp.name ) // die "Unable to find function to apply: " ~ $exp.name;
        my $new_env = PhP::Runtime::Env.new( :parent( $env ) );

        die "Incorrect number of arguments, got : " ~ $exp.args.elems ~ " expected: " ~ $code.params.elems
            unless $exp.args.elems == $code.params.elems;

        loop (my $i = 0; $i < $exp.args.elems; $i++ ) {
            $new_env.set: $code.params[ $i ] => evaluate( $exp.args[ $i ], $new_env );
        }

        return $code.extern.( $new_env ) if $code.?extern;
        return evaluate( $code.body, $new_env );
    }

    multi evaluate ( PhP::AST::Cond $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        evaluate( $exp.condition, $env ) === $env.get('#TRUE')
            ?? evaluate( $exp.if_true, $env )
            !! evaluate( $exp.if_false, $env )
    }

}
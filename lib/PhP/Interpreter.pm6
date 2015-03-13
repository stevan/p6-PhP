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

    multi evaluate ( PhP::AST::Func $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        $exp.set_declaration_env( $env );
        return $exp;
    }

    multi evaluate ( PhP::AST::Var $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        return $env.get( $exp.name ) // die "Unable to find the variable: " ~ $exp.name;
    } 

    multi evaluate ( PhP::AST::SimpleBinding $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        my $value = evaluate( $exp.value, $env );
        $env.set: $exp.var.name => $value;
        return $value;
    }

    multi evaluate ( PhP::AST::Let $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        my $new_env = PhP::Runtime::Env.new( :parent( $env ) );
        for $exp.bindings -> $binding { 
            evaluate( $binding, $new_env );
        }
        evaluate( $exp.body, $new_env );
    }

    multi evaluate ( PhP::AST::Apply $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        my $code = $env.get( $exp.name ) // die "Unable to find function to apply: " ~ $exp.name;
        
        die "Incorrect number of arguments, got : " ~ $exp.args.elems ~ " expected: " ~ $code.params.elems
            unless $exp.args.elems == $code.params.elems;

        # NOTE:
        # We need to evaluate our arguments within the 
        # current execution environment ($external_env)
        # but we need to add the results of that evaluation
        # to the environment that the function was originally
        # declared in. We then evaluate the body of the 
        # func using the declared environment since it will
        # still have access to closed over vars and other
        # subs declared at the same time. For NativeFunc 
        # nodes, they will not have a specific declared env, 
        # so just use the root one for now (might want to 
        # fix this later, but for now works).
        # - SL 

        my $external_env = PhP::Runtime::Env.new( :parent( $env ) );
        my $internal_env = PhP::Runtime::Env.new( 
            :parent( 
                $code.has_declaration_env 
                    ?? $code.get_declaration_env 
                    !! PhP::Runtime::root_env 
            ) 
        );

        loop (my $i = 0; $i < $exp.args.elems; $i++ ) {
            $internal_env.set: $code.params[ $i ] => evaluate( $exp.args[ $i ], $external_env );
        }

        return $code.extern.( $internal_env ) if $code.?extern;
        return evaluate( $code.body, $internal_env );
    }

    multi evaluate ( PhP::AST::Cond $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        evaluate( $exp.condition, $env ) === $env.get('#TRUE')
            ?? evaluate( $exp.if_true, $env )
            !! evaluate( $exp.if_false, $env )
    }

}
use v6;

package PhP::Interpreter {

    use PhP::AST;
    use PhP::Runtime;

    our sub run ( PhP::Runtime::CompilationUnit $unit ) returns PhP::Runtime::CompilationUnit {
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

    # NOTE:
    # the return values of the binds 
    # are actually ignored, they would
    # be captured down in the Let evaluate
    # method, inside the for loop, if we 
    # did capture them. Right now, I don't 
    # think we care.
    # - SL

    multi evaluate ( PhP::AST::SimpleBind $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        my $value = evaluate( $exp.value, $env );
        $env.set: $exp.var.name => $value;
        return $value;
    }

    multi evaluate ( PhP::AST::DestructuringBind $exp, PhP::Runtime::Env $env ) returns PhP::AST::Ast {
        my $value = evaluate( $exp.value, $env );
        if ( $exp.is_slurpy ) {
            my $num_patterns = $exp.pattern.elems - 1;
            loop (my $i = 0; $i < $num_patterns; $i++ ) {
                $env.set: $exp.pattern[$i].name => $value.get_item_at($i);
            }
            $env.set: $exp.pattern[ $num_patterns ].name => PhP::AST::Tuple.new(
                :items( $value.items[ $num_patterns .. ($value.items.elems - 1) ] )
            );
        }
        else {
            die "Incorrect number of elements in the destructing bind pattern, got : " ~ $exp.pattern.elems ~ " expected: " ~ $value.items.elems
                unless $exp.pattern.elems == $value.items.elems;

            loop (my $i = 0; $i < $exp.pattern.elems; $i++ ) {
                $env.set: $exp.pattern[$i].name => $value.get_item_at($i);
            }
        }
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
        
        die "Incorrect number of arguments for " ~ $exp.name ~ ", got : " ~ $exp.args.elems ~ " expected: " ~ $code.params.elems
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
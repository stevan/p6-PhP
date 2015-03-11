use v6;

package PhP::AST {
    
    class Ast {}

    class Terminal is Ast {}

    # Terminals

    class Unit is Terminal {
        method Str { '()' }
    }

    class Literal is Terminal {
        has Any $.value;

        method Str { ~ $.value }
    }

    class Tuple is Terminal {
        has Ast @.items;

        method get_item_at ($idx) { 
            die "Cannot access tuple item at (zero-based) index: $idx, tuple only has " ~ @.items.elems ~ " items(s)"
                if $idx >= @.items.elems;
            @.items[ $idx ];
        }

        method is_empty { @.items.elems == 0 }

        method Str { '[ ' ~ @.items.join(', ') ~ ' ]' }
    }

    role HasDeclarationEnv {
        has $!decl_env;
        method has_declaration_env          { $!decl_env.defined }
        method get_declaration_env          { $!decl_env         }
        method set_declaration_env ( $env ) { $!decl_env = $env  }
    }

    class Func is Terminal is HasDeclarationEnv {
        has Str @.params;
        has Ast $.body;

        method arity { @.params.elems }

        method Str { 'func (' ~ @.params.join(', ') ~ ') { ' ~ $.body ~ ' }' }
    }

    class NativeFunc is Terminal is HasDeclarationEnv {
        has Str   @.params;
        has Block $.extern;

        method arity { @.params.elems }

        method Str { 'func (' ~ @.params.join(', ') ~ ') => ' ~ $.body }
    }

    # Non-Terminals

    class Var is Ast {
        has Str $.name;

        method Str { $.name }
    }

    class Let is Ast {
        has Pair @.definitions;
        has Ast  $.body;

        method Str { 'let ' ~ @.definitions.map({ $_.key ~ ' = ' ~ $_.value }).join(', ') ~ ' in ' ~ $.body }
    }

    class Cond is Ast { 
        has Ast $.condition;
        has Ast $.if_true;
        has Ast $.if_false;

        method Str { 'if ' ~ $.condition ~ ' then ' ~ $.if_true ~ ' else ' ~ $.if_false }
    }

    class Apply is Ast {
        has Str $.name;
        has Ast @.args;

        method Str { $.name ~ '(' ~ @.args.join(', ') ~ ')' }
    }
}


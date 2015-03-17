use v6;

package PhP::AST {
    
    class Ast             {}
    class Terminal is Ast {}

    # Terminals

    class Unit is Terminal {
        method Str { '()' }
    }

    ## Literals

    class Literal is Terminal {
        has Any $.value;

        method Str { ~ $.value }
    }

    class StringLiteral  is Literal {}
    class NumberLiteral  is Literal {}
    class BooleanLiteral is Literal {}
 
    ## Compound Literals

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

    ## Functions

    class FunCallable is Terminal {
        has $!decl_env;

        method has_declaration_env          { $!decl_env.defined }
        method get_declaration_env          { $!decl_env         }
        method set_declaration_env ( $env ) { $!decl_env = $env  }
    }

    class Func is FunCallable {
        has Str @.params; # XXX - think about converting these to Var objects
        has Ast $.body;

        method arity { @.params.elems }

        method Str { 'func (' ~ @.params.join(', ') ~ ') { ' ~ $.body ~ ' }' }
    }

    class NativeFunc is FunCallable {
        has Str   @.params; # XXX - think about converting these to Var objects
        has Block $.extern;

        method arity { @.params.elems }

        method Str { 'func (' ~ @.params.join(', ') ~ ') => ' ~ $.body }
    }

    # Non-Terminals

    class Var is Ast {
        has Str $.namespace;
        has Str $.name;

        method has_namespace { $.namespace.defined }

        method Str { ($.namespace ?? $.namespace ~ '.' !! '') ~ $.name }
    }

    class Bind is Ast {}

    class SimpleBind is Bind {
        has Var $.var;
        has Ast $.value;

        method Str { $.var ~ " = " ~ $.value }
    }    

    class DestructuringBind is Bind {
        has Var   @.pattern;
        has Tuple $.value;
        has Bool  $.is_slurpy;

        method Str { @.pattern.join(", ") ~ ($.is_slurpy ?? "*" !! "") ~ " = " ~ $.value }
    }    

    class Let is Ast {
        has Bind @.bindings;
        has Ast  $.body;

        method Str { 'let ' ~ @.bindings.join(', ') ~ ' in ' ~ $.body }
    }

    class Cond is Ast { 
        has Ast $.condition;
        has Ast $.if_true;
        has Ast $.if_false;

        method Str { 'if ' ~ $.condition ~ ' then ' ~ $.if_true ~ ' else ' ~ $.if_false }
    }

    class Apply is Ast {
        has Var $.func;
        has Ast @.args;

        method Str { $.func.name ~ '(' ~ @.args.join(', ') ~ ')' }
    }
}


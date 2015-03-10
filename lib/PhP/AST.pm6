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

    class ConsCell is Terminal {
        has Ast      $.head;
        has ConsCell $.tail;

        method is_nil { !$.head and !$.tail  }

        method Str { 
            return '[]' unless $.head;
            return $.head ~ ' :: ' ~ $.tail; 
        }
    }

    class Func is Terminal {
        has Str @.params;
        has Ast $.body;

        method arity { @.params.elems }

        method Str { 'func (' ~ @.params.join(', ') ~ ') { ' ~ $.body ~ ' }' }
    }

    class NativeFunc is Terminal {
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


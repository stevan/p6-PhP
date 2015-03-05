package PhP::AST {
    
    class Ast {}

    class Terminal is Ast {}

    # Terminals

    class Literal is Terminal {
        has Any $.value;
    }

    class ConsCell is Terminal {
        has Ast      $.head;
        has ConsCell $.tail;

        method is_nil { !$.head and !$.tail  }
    }

    class Func is Terminal {
        has Str @.params;
        has Ast $.body;

        method arity { @.params.elems }
    }

    class NativeFunc is Terminal {
        has Str   @.params;
        has Block $.extern;

        method arity { @.params.elems }
    }

    # Non-Terminals

    class Var is Ast {
        has Str $.name;
    }

    class Let is Ast {
        has Str $.name;
        has Ast $.value;
        has Ast $.body;
    }

    class LetRec is Ast {
        has Pair @.definitions;
        has Ast  $.body;
    }

    class Cond is Ast { 
        has Ast $.condition;
        has Ast $.if_true;
        has Ast $.if_false;
    }

    class Apply is Ast {
        has Str $.name;
        has Ast @.args;
    }
}


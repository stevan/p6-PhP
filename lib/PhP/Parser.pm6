package PhP::Parser {
    
    class Ast {}

    class Literal is Ast {
        has Any $.value;
    }

    class Var is Ast {
        has Str $.name;
    }

    class ConsCell is Ast {
        has Ast $.head;
        has Ast $.tail;
    }

    class Func is Ast {
        has Str @.params;
        has Ast $.body;
    }

    class NativeFunc is Ast {
        has Str   @.params;
        has Block $.extern;
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


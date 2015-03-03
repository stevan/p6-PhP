package PhP::Compiler {

    use PhP::AST;

    our sub compile ( PhP::AST::Ast $exp ) { ... }

    # private ...

    multi emit ( PhP::AST::Ast $exp ) { ... }

    multi emit ( PhP::AST::Literal $exp ) { ... }

    multi emit ( PhP::AST::Var $exp ) { ... }

    multi emit ( PhP::AST::ConsCell $exp ) { ... }    

    multi emit ( PhP::AST::Let $exp ) { ... }

    multi emit ( PhP::AST::LetRec $exp ) { ... }

    multi emit ( PhP::AST::Func $exp ) { ... }

    multi emit ( PhP::AST::NativeFunc $exp ) { ... }

    multi emit ( PhP::AST::Apply $exp ) { ... }

    multi emit ( PhP::AST::Cond $exp ) { ... }
}
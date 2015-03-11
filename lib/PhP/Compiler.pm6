use v6;

package PhP::Compiler {

    use PhP::AST;
    use PhP::Runtime;

    our sub compile ( PhP::Runtime::CompilationUnit $unit ) { ... }

    # private ...

    multi emit ( PhP::AST::Ast $exp ) { ... }

    multi emit ( PhP::AST::Literal $exp ) { ... }

    multi emit ( PhP::AST::Tuple $exp ) { ... }

    multi emit ( PhP::AST::Unit $exp ) { ... }

    multi emit ( PhP::AST::Var $exp ) { ... }   

    multi emit ( PhP::AST::Let $exp ) { ... }

    multi emit ( PhP::AST::Func $exp ) { ... }

    multi emit ( PhP::AST::NativeFunc $exp ) { ... }

    multi emit ( PhP::AST::Apply $exp ) { ... }

    multi emit ( PhP::AST::Cond $exp ) { ... }
}
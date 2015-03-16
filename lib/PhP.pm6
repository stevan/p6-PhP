use v6;

package PhP {
    
    use PhP::Parser;
    use PhP::Runtime;
    use PhP::Interpreter;
    use PhP::Compiler;

    our constant VERSION = '0.0.0';

    our sub run ( Str $source, %opts? ) returns PhP::Runtime::CompilationUnit {
        PhP::Runtime::bootstrap;
        return PhP::Interpreter::run(
            PhP::Runtime::CompilationUnit.new(
                options => %opts,
                root    => parse( $source, %opts ),
                env     => PhP::Runtime::Env.new( parent => PhP::Runtime::root_env ),
            )
        );        
    }

    our sub compile ( Str $source, %opts? ) returns PhP::Runtime::CompilationUnit {
        return PhP::Compiler::compile( 
            PhP::Runtime::CompilationUnit.new(
                options => %opts,
                root    => parse( $source, %opts ),
            )
        );
    }

    our sub parse ( Str $source, %opts? ) returns PhP::AST::Ast {
        return PhP::Parser::parse( $source, %opts );
    }
}
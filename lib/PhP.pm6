use v6;

package PhP {
    
    use PhP::Parser;
    use PhP::Runtime;
    use PhP::Interpreter;
    use PhP::Compiler;

    our sub run ( Str $source, %opts? ) {
        PhP::Runtime::bootstrap;
        PhP::Interpreter::run(
            PhP::Runtime::CompilationUnit.new(
                :options( %opts ),
                :root( PhP::Parser::parse( $source, %opts ) ),
                :env( 
                    PhP::Runtime::Env.new( 
                        :parent( PhP::Runtime::root_env ) 
                    ) 
                )
            )
        );        
    }

    our sub compile ( Str $source, %opts? ) {
        PhP::Compiler::compile( 
            PhP::Runtime::CompilationUnit.new(
                :options( %opts ),
                :root( PhP::Parser::parse( $source, %opts ) ),
            )
        );
    }
}
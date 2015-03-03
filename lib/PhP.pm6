package PhP {
    
    use PhP::Parser;
    use PhP::Interpreter;
    use PhP::Compiler;

    our sub run ( Str $source, %opts? ) {
        PhP::Interpreter::run( PhP::Parser::parse( $source, %opts ) );        
    }

    our sub compile ( Str $source, %opts? ) {
        PhP::Compiler::compile( PhP::Parser::parse( $source, %opts ) );        
    }
}
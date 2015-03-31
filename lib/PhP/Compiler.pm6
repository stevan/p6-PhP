use v6;

package PhP::Compiler {

    use PhP::AST;
    use PhP::Runtime;

    use MCVM::Instructions;

    our sub compile ( PhP::Runtime::CompilationUnit $unit ) returns PhP::Runtime::CompilationUnit {
        my MCVM::Instructions::INST @acc;
        emit( $unit.root, @acc );
        $unit.set_bytecode( @acc );
        return $unit;
    }

    my %NATIVE = (
        '+' => ( MCVM::Instructions::ADD.new ),
        '-' => ( MCVM::Instructions::SUB.new ),
        '*' => ( MCVM::Instructions::MUL.new ),
        '%' => ( MCVM::Instructions::DIV.new ),
    );

    # private ...

    multi emit ( PhP::AST::Ast $exp, MCVM::Instructions::INST @acc ) { ... }

    multi emit ( PhP::AST::StringLiteral $exp, MCVM::Instructions::INST @acc ) { ... }

    multi emit ( PhP::AST::NumberLiteral $exp, MCVM::Instructions::INST @acc ) {
        @acc.push: MCVM::Instructions::PUSH.new( value => $exp.value )
    }

    multi emit ( PhP::AST::Tuple $exp, MCVM::Instructions::INST @acc ) { ... }

    multi emit ( PhP::AST::Unit $exp, MCVM::Instructions::INST @acc ) { ... }

    multi emit ( PhP::AST::Var $exp, MCVM::Instructions::INST @acc ) { ... }   

    multi emit ( PhP::AST::Let $exp, MCVM::Instructions::INST @acc ) { ... }

    multi emit ( PhP::AST::Func $exp, MCVM::Instructions::INST @acc ) { ... }

    multi emit ( PhP::AST::NativeFunc $exp, MCVM::Instructions::INST @acc ) { ... }

    multi emit ( PhP::AST::Apply $exp, MCVM::Instructions::INST @acc ) {
        $exp.args.map: { emit( $_, @acc ) };
        my @code = %NATIVE{ $exp.func.name } || die "Cannot find function: (" ~ $exp.func.name ~ ")";
        @acc.push: @code;
    }

    multi emit ( PhP::AST::Cond $exp, MCVM::Instructions::INST @acc ) { ... }
}
use v6;

package PhP::Compiler {

    use PhP::AST;
    use PhP::Runtime;

    use MCVM;
    use MCVM::Utils;

    class Assembler {
        has %.symbols;       
        has @.instructions;

        method get_symbol ( Str $key ) { %!symbols{ $key } }
        method add_symbol ( Pair $sym ) {
            %!symbols{ $sym.key } = $sym.value;
        }

        method add_instructions ( *@inst ) {
            @!instructions.push: @inst.list;
        }
    }

    class Executable {
        has               %.options;   # the set of options this was compiled
        has PhP::AST::Ast $.root;      # the root node of the AST 
        has Assembler     $.result;    # the result of compiling the AST

        method has_root                       { $!root.defined }
        method set_root (PhP::AST::Ast $root) { $!root = $root }

        method has_result                     { $!result.defined   }
        method set_result (Assembler $result) { $!result = $result }         
    }

    our sub compile ( Executable $unit ) returns Executable {
        my $assm = init_assembler();
        emit( $unit.root, $assm );
        $unit.set_result( $assm );
        return $unit;
    }

    sub init_assembler () {
        my $assm = Assembler.new;
        $assm.add_symbol( '+' => ( MCVM::Instructions::ADD.new ) );
        $assm.add_symbol( '-' => ( MCVM::Instructions::SUB.new ) );
        $assm.add_symbol( '*' => ( MCVM::Instructions::MUL.new ) );
        $assm.add_symbol( '%' => ( MCVM::Instructions::DIV.new ) );
        return $assm;
    }

    # private ...

    multi emit ( PhP::AST::Ast $exp, Assembler $assm ) { ... }

    multi emit ( PhP::AST::StringLiteral $exp, Assembler $assm ) { ... }

    multi emit ( PhP::AST::NumberLiteral $exp, Assembler $assm ) {
        $assm.add_instructions( 
            MCVM::Instructions::PUSH.new( value => $exp.value )
        );
    }

    multi emit ( PhP::AST::Tuple $exp, Assembler $assm ) { ... }

    multi emit ( PhP::AST::Unit $exp, Assembler $assm ) { ... }

    multi emit ( PhP::AST::Var $exp, Assembler $assm ) { ... }   

    multi emit ( PhP::AST::Let $exp, Assembler $assm ) { ... }

    multi emit ( PhP::AST::Func $exp, Assembler $assm ) { ... }

    multi emit ( PhP::AST::NativeFunc $exp, Assembler $assm ) { ... }

    multi emit ( PhP::AST::Apply $exp, Assembler $assm ) {
        $exp.args.map: { emit( $_, $assm ) };

        my @code = $assm.get_symbol( $exp.func.name ) 
            || die "Cannot find function: (" ~ $exp.func.name ~ ")";

        $assm.add_instructions( @code );
    }

    multi emit ( PhP::AST::Cond $exp, Assembler $assm ) { ... }
}
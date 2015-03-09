use v6;

use PhP::AST;
use PhP::Runtime;

class PhP::Parser::Actions {

    method TOP ($/) { 
        $/.make( 
            PhP::Runtime::CompilationUnit.new(
                :root( $/.<statement>.made )
            )
        );
    }

    method statement ($/) {
        $/.make( 
            $/.<let-statement>.made 
                //
            $/.<expression>.made 
        );
    }

    ## let statement

    method let-statement ($/) {
        $/.make(
            PhP::AST::Let.new(
                :definitions( $/.<let-value>.map: { $_.made } ),
                :body( $/.<let-body>.made )
            )
        );
    }

    method let-value ($/) {    
        my $ident = ~ $/.<identifier>;
        my $value = $/.<let-statement-value>.made;

        $/.make( $ident => $value );
    }

    method let-statement-value ($/) {
        $/.make( 
            #$/.<func-statement>.made
                #//
            $/.<expression>.made
        );
    }

    # ...

    method expression ($/) {
        $/.make( 
            $/.<apply-expression>.made
                //
            $/.<cond-expression>.made
                //
            $/.<binary-expression>.made
                //
            $/.<identifier>.made
                //
            $/.<literal>.made 
                //
            $/.<expression>.made
        );
    }

    method apply-expression ($/) {
        $/.make(
            PhP::AST::Apply.new(
                :name( ~ $/.<identifier> ),
                :args(
                    $/.<apply-argument>.map: { $_.made }
                )
            )
        );
    }

    method apply-argument ($/) {
        $/.make( $/.<expression>.made );
    }

    method cond-expression ($/) {
        $/.make(
            PhP::AST::Cond.new(
                :condition( $/.<condition>.made ),
                :if_true(   $/.<if_true>.made   ),
                :if_false(  $/.<if_false>.made  ),
            )
        );
    }

    method binary-expression ($/) {
        $/.make( 
            PhP::AST::Apply.new( 
                :name( ~ $/.<binary-op> ),
                :args( 
                    ($/.<literal> // $/.<identifier>).made,
                    $/.<expression>.made 
                )
            ) 
        );
    }

    method literal ($/) {
        $/.make( PhP::AST::Literal.new( :value( ~$/ ) ) );
    }

    method identifier ($/) {
        $/.make( PhP::AST::Var.new( :name( ~ $/ ) ) );
    }
}
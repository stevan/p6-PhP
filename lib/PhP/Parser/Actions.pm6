use v6;

use PhP::AST;

class PhP::Parser::Actions {

    method TOP ($/) { 
        $/.make( $/.<statement>.made );
    }

    method statement ($/) {
        $/.make( $/.<let-statement>.made );
    }

    ## let statement

    method let-statement ($/) {
        $/.make(
            PhP::AST::Let.new(
                :definitions( $/.<let-value-set>.made ),
                :body( $/.<let-body>.made )
            )
        );
    }

    method let-value-set ($/) {
        $/.make( $/.<let-value>.map: { $_.made } );
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

    method let-body ($/) {
        $/.make( $/.<expression>.made );
    }

    # ...

    method expression ($/) {
        $/.make( 
            $/.<binary-expression>.made
                //
            $/.<identifier>.made
                //
            $/.<literal>.made 
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
        $/.make( PhP::AST::Literal.new( :value( ~ $/ ) ) );
    }

    method identifier ($/) {
        $/.make( PhP::AST::Var.new( :name( ~ $/ ) ) );
    }
}
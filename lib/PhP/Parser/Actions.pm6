use v6;

use PhP::AST;

class PhP::Parser::Actions {

    method TOP ($/) { 
        $/.make( $/.<statement>.made );
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
                bindings => $/.<let-binding>>>.made,
                body     => $/.<let-body>.made,
            )
        );
    }

    method let-binding ($/) {    
        $/.make(
            $/.<let-simple-bind>.made
                //
            $/.<let-destructuring-bind>.made
        );
    }

    method let-simple-bind ($/) {    
        my $ident = ~ $/.<identifier>;
        my $value = $/.<let-statement-value>.made;

        $/.make( 
            PhP::AST::SimpleBind.new(
                var   => PhP::AST::Var.new( name => $ident ),
                value => $value,
            )
        );
    }

    method let-destructuring-bind ($/) {    
        $/.make( 
            PhP::AST::DestructuringBind.new(
                is_slurpy => $/.<splat>.defined,
                pattern   => $/.<let-destructuring-pattern>>>.made,
                value     => $/.<tuple-expression>.made
            )
        );
    }

    method let-destructuring-pattern ($/) {
        $/.make( ~ $/.<identifier> )
    }

    method let-statement-value ($/) {
        $/.make( 
            $/.<func-statement>.made
                //
            $/.<expression>.made
        );
    }

    # func statements

    method func-statement ($/) {
        $/.make(
            PhP::AST::Func.new(
                params => $/.<func-param>>>.made>>.name,
                body   => $/.<func-body>.made,
            )
        );
    }    

    method func-body ($/) {
        $/.make( $/.<expression>.made )
    }

    # ...

    method expression ($/) {
        $/.make( 
            $/.<tuple-expression>.made
                //
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
                //
            PhP::AST::Unit.new
        );
    }

    method cond-expression ($/) {
        $/.make(
            PhP::AST::Cond.new(
                condition => $/.<condition>.made,
                if_true   => $/.<if_true>.made,
                if_false  => $/.<if_false>.made,
            )
        );
    }

    method apply-expression ($/) {
        $/.make(
            PhP::AST::Apply.new(
                func => $/.<identifier>.made,
                args => $/.<apply-argument>>>.made
            )
        );
    }

    method tuple-expression ($/) {
        $/.make( PhP::AST::Tuple.new( items => $/.<tuple-expression-item>>>.made ) );
    }    

    method binary-expression ($/) {
        $/.make( 
            PhP::AST::Apply.new( 
                func => $/.<binary-op>.made,
                args => [ 
                    $/.<lhs>.made,
                    $/.<rhs>.made 
                ]
            ) 
        );
    }

    method list-of-expressions ($/) {
        $/.make( $/.<expression>.made );
    }

    method list-of-identifiers ($/) {
        $/.make( $/.<identifier>.made );
    }

    method literal ($/) {
        if ( my $bool = $/.<literal-boolean> ) {
            if ( ~$bool eq 'true' ) {
                $/.make( PhP::AST::Var.new( name => "#TRUE" ) );
            }
            elsif ( ~$bool eq 'false' ) {
                $/.make( PhP::AST::Var.new( name => "#FALSE" ) );
            }
        }
        elsif ( my $string = $/.<literal-string> ) {
            $/.make( PhP::AST::StringLiteral.new( value => ~$string ) );
        }
        elsif ( my $number = $/.<literal-number> ) {
            $/.make( PhP::AST::NumberLiteral.new( value => 0+$number ) );
        }
        else {
            die "I have no idea what kind of literal this is: $/"; 
        }
    }

    method binary-op ($/) {
        $/.make( PhP::AST::Var.new( name => ~ $/ ) );
    }

    method identifier ($/) {
        $/.make(
            $/.<local-identifier>.made 
                //
            $/.<namespaced-identifier>.made                 
        );
    }

    method local-identifier ($/) {
        $/.make( PhP::AST::Var.new( name => ~ $/ ) );
    }

    method namespaced-identifier ($/) {
        $/.make( 
            PhP::AST::Var.new( 
                name      => ~ $/.<name>,
                namespace => ~ $/.<namespace> 
            ) 
        );
    }
}
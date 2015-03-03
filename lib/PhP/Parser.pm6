package PhP::Parser {

    use PhP::AST;
    use PhP::Parser::TokenParser;

    our sub parse ( Str $source, %opts? --> PhP::AST::Ast ) {

        my @tokens = PhP::Parser::TokenParser::parse( $source );

        for @tokens -> $token {
            given $token.type {
                when LITERAL {

                }
                when KEYWORD {

                }
                when IDENT {

                }
                when OP {

                }
                when BRACE {

                }
            }
        }

        warn @tokens.map({ $_.perl }).join("\n");

        return PhP::AST::Ast.new;
    } 
}
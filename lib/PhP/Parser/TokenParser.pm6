package PhP::Parser::TokenParser {

    enum TokenType is export <
        LITERAL
        KEYWORD
        IDENT
        OP
        BRACE
    >;

    class Token {
        has TokenType $.type;
        has Str       $.token;
    }

    class Actions {
        has Token @.tokens;

        method keywords    ($/) { @.tokens.push: Token.new( :token(~$/), :type(KEYWORD) ) }
        method literals    ($/) { @.tokens.push: Token.new( :token(~$/), :type(LITERAL) ) }
        method identifiers ($/) { @.tokens.push: Token.new( :token(~$/), :type(IDENT)   ) }
        method operators   ($/) { @.tokens.push: Token.new( :token(~$/), :type(OP)      ) }
        method braces      ($/) { @.tokens.push: Token.new( :token(~$/), :type(BRACE)   ) }
    }

    grammar Parser {

        token TOP  { [ <line> \n? ]+ }
        token line { ^^  <all_tokens>* % \s $$ }

        token all_tokens {
            [ <literals> | <keywords> | <identifiers> | <operators> | <braces> ]*
        }

        token identifiers       { <.identifiers_start><.identifiers_rest>* }
        token identifiers_start { <[A..Za..z_]>     }
        token identifiers_rest  { <[A..Za..z0..9_]> }

        token literals {
            [
            | "true" | "false" | "nil"
            | <quoted_text>
            | \d+  # FIXME - this is wildly insufficient
            ]
        }

        token quoted_text {
            \"
            [
            | <-["\\]> # Anything not a " or \
            | '\"'     # Or \", an escaped quotation mark
            ]*         # Any number of times 
            \"         # " << stupid syntax highlighting
        }    

        token keywords {
            [
            | "let" | "rec" | "in"
            | "fun"
            | "if" | "then" | "else"
            ]
        }

        token operators {
            [
            | "="
            | ","
            | "::"
            | "->"
            | ";;"
            | "+"  | "-"  | "*" | "/" 
            | "==" | "!=" 
            | "<"  | "<=" | "=>" | ">"
            ]
        }

        token braces {
            [ "("  | ")" | "\{" | "\}" ]
        }

    }

    # Public API

    our sub parse ( Str $source ) {
        my $actions = Actions.new;
        my $match   = Parser.parse( $source, :$actions );
        return $actions.tokens;
    }

}
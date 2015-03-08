use v6;

package PhP::Parser {

    use PhP::AST;

    use PhP::Parser::Grammar;
    use PhP::Parser::Actions;

    our sub parse ( Str $source, %opts? ) returns PhP::AST::Ast { ... } 

}
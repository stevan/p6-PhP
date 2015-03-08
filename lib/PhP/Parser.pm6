use v6;

package PhP::Parser {

    use PhP::AST;

    use PhP::Parser::Grammar;
    use PhP::Parser::Actions;

    our sub parse ( Str $source, %opts? ) returns PhP::AST::Ast {
        my $actions = PhP::Parser::Actions.new;
        my $match   = PhP::Parser::Grammar.parse( $source, :$actions );
        
        if %opts{'DEBUG'} {
            say ~ $match.gist;
            say ~ $match.made.gist;
        }
        
        die "Syntax Error" unless $match.defined;

        return $match.made;
    } 

}
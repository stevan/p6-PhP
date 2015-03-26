use v6;

package MCVM {

    use MCVM::Machine;
    use MCVM::Instructions;

    our constant VERSION = '0.0.0';

    our sub run ( @program, %opts? )  {
        MCVM::Machine::execute( @program, %opts )
    }

}
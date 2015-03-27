use v6;

package MCVM {

    use MCVM::Machine;
    use MCVM::Instructions;

    our constant VERSION = '0.0.0';

    our sub run ( @program, %opts? ) returns MCVM::Machine::Process {
        return MCVM::Machine::execute( @program, %opts )
    }
}
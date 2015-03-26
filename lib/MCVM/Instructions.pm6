use v6;

package MCVM::Instructions {

    use MCVM::Machine;

    class INST {}

    class LOAD is INST {
        has $.label = die 'label is required';

        method run ( MCVM::Machine::Process $process ) {
            $process.data.push( $process.memory{ $.label } );
        }   
    }

    class STOR is INST {
        has $.label = die 'label is required';
        has $.value;

        method run ( MCVM::Machine::Process $process ) { 
            $process.memory{ $.label } = $.value // $process.data.pop;
        }
    }

    class LLOAD is INST {
        has $.label = die 'label is required';

        method run ( MCVM::Machine::Process $process ) {
            $process.data.push( $process.current_frame.memory{ $.label } );
        }
    }

    class LSTOR is INST {
        has $.label = die 'label is required';
        has $.value;    

        method run ( MCVM::Machine::Process $process ) {              
            $process.current_frame.memory{ $.label } = $.value // $process.data.pop;
        }
    }

    class DUP is INST {

        method run ( MCVM::Machine::Process $process ) {
            $process.data.push( $process.data[*-1].clone );
        }
    }

    class PUSH is INST {
        has $.value = die 'value is required';

        method run ( MCVM::Machine::Process $process ) {
            $process.data.push( $.value );
        }
    }

    class POP is INST {

        method run ( MCVM::Machine::Process $process ) {
            $process.data.pop;
        }
    }

    class JUMP is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $addr = $process.data.pop;
            $process.pc = $addr;
        }
    }

    class COND is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $addr  = $process.data.pop;                
            my $value = $process.data.pop;
            if $value == True {
                #warn "Got a true value $value, jumping to $addr";
                $process.pc = $addr;
            } else {
                #warn "Did not get a true value: $value"
            }
        }
    }

    class LJUMP is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $addr = $process.data.pop;
            $process.pc = $addr + $process.current_frame.laddr;
        }
    }

    class LCOND is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $addr  = $process.data.pop;                
            my $value = $process.data.pop;
            if $value == True {
                #warn "Got a true value $value, jumping to $addr";
                $process.pc = $addr + $process.current_frame.laddr;
            } else {
                #warn "Did not get a true value: $value"
            }
        }
    }

    class CALL is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $addr = $process.data.pop;
            $process.new_frame(
                raddr => $process.pc.clone, 
                laddr => $addr.clone,
            );
            #say "WTF!!!!" ~ $process.current_frame.perl;
            $process.pc = $addr;
        }
    }

    class RETN is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $frame = $process.frame.pop;
            $process.pc = $frame.raddr;   
        }
    }

    class ADD is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.data.pop;
            my $r = $process.data.pop;
            $process.data.push( $l + $r );
        }
    }

    class SUB is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.data.pop;
            my $r = $process.data.pop;
            $process.data.push( $l - $r );
        }
    }

    class MUL is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.data.pop;
            my $r = $process.data.pop;
            $process.data.push( $l * $r );   
        }
    }

    class DIV is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.data.pop;
            my $r = $process.data.pop;
            $process.data.push( $l / $r );
        }
    }

    class EQ is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.data.pop;
            my $r = $process.data.pop;
            $process.data.push( $l == $r );
        }
    }

    class NEQ is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.data.pop;
            my $r = $process.data.pop;
            $process.data.push( $l != $r );   
        }
    }

    class NOOP is INST {

        method run ( MCVM::Machine::Process $process ) {}
    }

    class OUT is INST {

        method run ( MCVM::Machine::Process $process ) {
            print $process.data.pop;
        }
    }

    class HALT is INST {

        method run ( MCVM::Machine::Process $process ) {
            $process.halt;
        }
    }


}
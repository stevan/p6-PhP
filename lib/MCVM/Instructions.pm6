use v6;

package MCVM::Instructions {

    use MCVM::Machine;

    class INST {}

    class LOAD is INST {
        has $.label = die 'label is required';

        method run ( MCVM::Machine::Process $process ) {
            $process.push_data( $process.get_memory( $.label ) );
        }   
    }

    class STOR is INST {
        has $.label = die 'label is required';
        has $.value;

        method run ( MCVM::Machine::Process $process ) { 
            $process.set_memory( $.label, $.value // $process.pop_data );
        }
    }

    class LLOAD is INST {
        has $.label = die 'label is required';

        method run ( MCVM::Machine::Process $process ) {
            $process.push_data( $process.current_frame.get_memory( $.label ) );
        }
    }

    class LSTOR is INST {
        has $.label = die 'label is required';
        has $.value;    

        method run ( MCVM::Machine::Process $process ) {              
            $process.current_frame.set_memory( $.label, $.value // $process.pop_data );
        }
    }

    class DUP is INST {

        method run ( MCVM::Machine::Process $process ) {
            $process.push_data( $process.peek_data.clone );
        }
    }

    class PUSH is INST {
        has $.value = die 'value is required';

        method run ( MCVM::Machine::Process $process ) {
            $process.push_data( $.value );
        }
    }

    class POP is INST {

        method run ( MCVM::Machine::Process $process ) {
            $process.pop_data;
        }
    }

    class JUMP is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $addr = $process.pop_data;
            $process.jump( to => $addr );
        }
    }

    class COND is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $addr  = $process.pop_data;                
            my $value = $process.pop_data;
            if $value == True {
                #warn "Got a true value $value, jumping to $addr";
                $process.jump( to => $addr );
            } else {
                #warn "Did not get a true value: $value"
            }
        }
    }

    class LJUMP is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $addr = $process.pop_data;
            $process.jump( to => $addr, is_local => True );
        }
    }

    class LCOND is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $addr  = $process.pop_data;                
            my $value = $process.pop_data;
            if $value == True {
                #warn "Got a true value $value, jumping to $addr";
                $process.jump( to => $addr, is_local => True );
            } else {
                #warn "Did not get a true value: $value"
            }
        }
    }

    class CALL is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $addr = $process.pop_data;
            $process.new_frame( goto => $addr );
        }
    }

    class RETN is INST {

        method run ( MCVM::Machine::Process $process ) {
            $process.exit_frame;
        }
    }

    class ADD is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.pop_data;
            my $r = $process.pop_data;
            $process.push_data( $l + $r );
        }
    }

    class SUB is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.pop_data;
            my $r = $process.pop_data;
            $process.push_data( $l - $r );
        }
    }

    class MUL is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.pop_data;
            my $r = $process.pop_data;
            $process.push_data( $l * $r );   
        }
    }

    class DIV is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.pop_data;
            my $r = $process.pop_data;
            $process.push_data( $l / $r );
        }
    }

    class EQ is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.pop_data;
            my $r = $process.pop_data;
            $process.push_data( $l == $r );
        }
    }

    class NEQ is INST {

        method run ( MCVM::Machine::Process $process ) {
            my $l = $process.pop_data;
            my $r = $process.pop_data;
            $process.push_data( $l != $r );   
        }
    }

    class NOOP is INST {

        method run ( MCVM::Machine::Process $process ) {}
    }

    class OUT is INST {

        method run ( MCVM::Machine::Process $process ) {
            print $process.pop_data;
        }
    }

    class HALT is INST {

        method run ( MCVM::Machine::Process $process ) {
            $process.halt;
        }
    }


}
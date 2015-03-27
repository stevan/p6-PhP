use v6;

package MCVM::Machine {

    class Frame {
        has %.memory;
        has $.return_address;
        has $.local_offset;

        # memory 

        method get_memory ( $addr )       { %.memory{ $addr }        }
        method set_memory ( $addr, $val ) { %.memory{ $addr } = $val }
    }

    class Process {
        has Any   %.memory;
        has Any   @.data;
        has Frame @.frame;
        has Int   $.program_counter is rw = 0;

        # frames ...

        method current_frame { @.frame[*-1] }

        method new_frame ( :$goto is copy ) {
            @.frame.push( Frame.new( return_address => $.program_counter.clone, local_offset => $goto ) );
            $.program_counter = $goto;
        }

        method exit_frame { 
            my $frame = @.frame.pop;
            $.program_counter = $frame.return_address;
        }

        # data 

        method peek_data          { @.data[*-1]         }
        method pop_data           { @.data.pop          }
        method push_data ( $val ) { @.data.push( $val ) }

        # memory 

        method get_memory ( $addr )       { %.memory{ $addr }        }
        method set_memory ( $addr, $val ) { %.memory{ $addr } = $val }

        # control 

        method halt { $.program_counter = -1  }

        method jump ( Int :$to, Bool :$is_local ) { 
            $.program_counter = $to + ($is_local ?? self.current_frame.local_offset !! 0);
        }

        method execute ( @program, %opts? ) {
            say "== START ===========" if %opts<DEBUG>;

            while ( $.program_counter >= 0 && $.program_counter < @program.elems ) {
                my $inst = @program[ $.program_counter++ ];        
                $inst.run( self );

                if %opts<DEBUG> {
                    self._dump_for_debug( $inst );
                    say "--------------------";
                }
            }

            say "== END =============" if %opts<DEBUG>;
        }

        method _dump_for_debug ($inst) {
            say "COUNTER : " ~ $.program_counter;
            say "CURRENT : " ~ $inst.gist;
            say "-------->";
            say "MEMORY  : " ~ %.memory.gist;
            say "DATA    : " ~ @.data.gist;
            say "FRAME   : " ~ @.frame>>.gist.join("\n        | ");
        }
    }

    our sub execute ( @program, %opts? ) {
        my $process = Process.new;
        $process.execute( @program, %opts );
        return $process;
    }

}


use v6;

package MCVM::Machine {

    class Frame {
        has %.memory;
        has $.raddr;
        has $.laddr;
    }

    class Process {
        has Any   %.memory;
        has Any   @.data;
        has Frame @.frame;
        has Int   $.pc is rw = 0;

        method current_frame { @.frame[*-1] }

        method new_frame ( :$raddr, :$laddr ) {
            @.frame.push: Frame.new( :$raddr, :$laddr )
        }

        method halt { $.pc = -1 }

        method execute ( @program, %opts? ) {
            say "== START ===========" if %opts<DEBUG>;

            while ( $.pc >= 0 && $.pc < @program.elems ) {
                my $inst = @program[ $.pc++ ];        
                $inst.run( self );

                if %opts<DEBUG> {
                    self._dump_for_debug( $inst );
                    say "--------------------";
                }
            }

            say "== END =============" if %opts<DEBUG>;
        }

        method _dump_for_debug ($inst) {
            say "COUNTER : " ~ $.pc;
            say "CURRENT : " ~ $inst.gist;
            say "-------->";
            say "MEMORY  : " ~ %.memory.gist;
            say "DATA    : " ~ @.data.gist;
            say "FRAME   : " ~ @.frame>>.gist.join("\n        | ");
        }
    }

    our sub execute ( @program, %opts? ) {
        Process.new.execute( @program, %opts )
    }

}


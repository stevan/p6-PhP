#!perl6

class Process {
    has %.memory;
    has @.data;
    has @.frame;
    has $.pc is rw = 0;

    method current_frame { @.frame[*-1] }

    method halt { $.pc = -1 }

    method execute ( @program, %opts? ) {
        if %opts<DEBUG> {
            say "== START ===========";            
        }

        while ( $.pc >= 0 && $.pc < @program.elems ) {
            my $inst = @program[ $.pc++ ];        
            $inst.call( self );

            if %opts<DEBUG> {
                self._dump_for_debug( $inst );
                say "--------------------";
            }
        }

        if %opts<DEBUG> {
            say "== END =============";
        }
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

class Frame {
    has %.memory;
    has $.raddr;
    has $.laddr;
}

role Instruction {}

class LOAD is Instruction {
    has $.label = die 'label is required';

    method call ( Process $process ) {
        $process.data.push( $process.memory{ $.label } );
    }   
}

class STOR is Instruction {
    has $.label = die 'label is required';
    has $.value;

    method call ( Process $process ) { 
        $process.memory{ $.label } = $.value // $process.data.pop;
    }
}

class LLOAD is Instruction {
    has $.label = die 'label is required';

    method call ( Process $process ) {
        $process.data.push( $process.current_frame.memory{ $.label } );
    }
}

class LSTOR is Instruction {
    has $.label = die 'label is required';
    has $.value;    

    method call ( Process $process ) {              
        $process.current_frame.memory{ $.label } = $.value // $process.data.pop;
    }
}

class DUP is Instruction {

    method call ( Process $process ) {
        $process.data.push( $process.data[*-1].clone );
    }
}

class PUSH is Instruction {
    has $.value = die 'value is required';

    method call ( Process $process ) {
        $process.data.push( $.value );
    }
}

class POP is Instruction {

    method call ( Process $process ) {
        $process.data.pop;
    }
}

class JUMP is Instruction {

    method call ( Process $process ) {
        my $addr = $process.data.pop;
        $process.pc = $addr;
    }
}

class COND is Instruction {

    method call ( Process $process ) {
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

class LJUMP is Instruction {

    method call ( Process $process ) {
        my $addr = $process.data.pop;
        $process.pc = $addr + $process.current_frame.laddr;
    }
}

class LCOND is Instruction {

    method call ( Process $process ) {
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

class CALL is Instruction {

    method call ( Process $process ) {
        my $addr = $process.data.pop;
        $process.frame.push: Frame.new(
            raddr => $process.pc.clone, 
            laddr => $addr.clone,
        );
        #say "WTF!!!!" ~ $process.current_frame.perl;
        $process.pc = $addr;
    }
}

class RETN is Instruction {

    method call ( Process $process ) {
        my $frame = $process.frame.pop;
        $process.pc = $frame.raddr;   
    }
}

class ADD is Instruction {

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l + $r );
    }
}

class SUB is Instruction {

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l - $r );
    }
}

class MUL is Instruction {

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l * $r );   
    }
}

class DIV is Instruction {

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l / $r );
    }
}

class EQ is Instruction {

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l == $r );
    }
}

class NEQ is Instruction {

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l != $r );   
    }
}

class NOOP is Instruction {

    method call ( Process $process ) {}
}

class OUT is Instruction {

    method call ( Process $process ) {
        print $process.data.pop;
    }
}

class HALT is Instruction {

    method call ( Process $process ) {
        $process.halt;
    }
}

# ... 
# sub mul ($x, $y) {
#     if ( $y != 1 ) {
#         return $x + mul( $x, $y - 1 );
#     }
#     return $x
# }

# let mul = fun (x, y) 
#               if ( y == 1 ) 
#                   then x 
#                   else x + mul( x, y - 1 ) 
# in
#    mul 13, 2
# ;;

    
my @mul = build_symbol_table( 
    [
        LSTOR.new( label => '$x' ),     # pull $x off the stack
        LSTOR.new( label => '$y' ),     # pull $y off the stack
    ], 
    [ LLOAD.new( label => '&main'), LJUMP.new ],
    {
        '&cond001-if-true' => [
            LLOAD.new( label => '$x'     ),  # put $x on the stack
            LLOAD.new( label => '&leave' ),  # put the local-exit address on the stack
            LJUMP.new,                       # jump to the postlude
        ],
        '&cond001-if-false' => [ 
            PUSH.new( value => 1 ),         # put 1 on the stack
            LLOAD.new( label => '$y' ),     # put $y on the stack
            SUB.new,                        # then subtract 1 from $y
            LLOAD.new( label => '$x' ),     # put $x on the stack            
            LOAD.new( label => '&mul' ),    # put the address of &mul on the stack
            CALL.new,                       # call &mul
                                            # this leaves the result of mul on the stack
            LLOAD.new( label => '$x' ),     # put x on the stack
            ADD.new,                        # and add the value of $x and the return value of &mul
            LLOAD.new( label => '&leave' ), # put the local-exit address on the stack
            LJUMP.new,                      # jump to the postlude
        ],
        '&main' => [
            LLOAD.new( label => '$y' ),                # put $y on the stack
            PUSH.new( value => 1 ),                    # put 1 on the stack
            EQ.new,                                    # compare $y to 1, leave bool on the stack
            LLOAD.new( label => '&cond001-if-true' ),  # load the address of the 'true' block
            LCOND.new,                                 # if top of the stack is true, goto 'true' block
            LLOAD.new( label => '&cond001-if-false' ), # if we are still here, load the address of the 'false' block
            LJUMP.new,                                 # and then jump to the 'false' block
        ],
        '&leave' => [
            RETN.new   # return from the sub
        ]
    },  
    local => True
);

my @main = 
    (PUSH.new( value => 2 ), PUSH.new( value => 13)),
    (LOAD.new( label => '&mul'), CALL.new),
    (OUT.new),
;

my @exit = 
    (HALT.new)
;

my @init = build_symbol_table( 
    [], 
    [ 
        LOAD.new( label => '&main' ), 
        CALL.new, 
        HALT.new, 
    ],
    {
        '&mul'  => @mul,
        '&main' => @main,     
        '&exit' => @exit, 
    }
);

# utils ...

sub build_symbol_table ( @prelude, @postlude, %symbols, :$local = False ) {
    my @unit;

    my $start = @prelude.elems;
    my $end   = $start + %symbols.keys.elems + @postlude.elems; 

    @unit.push: @prelude.list;

    my %locals;

    for %symbols.kv -> $k, $v {
        %locals{ $k } = $end;
        @unit.push: ($local ?? LSTOR !! STOR).new( label => $k, value => $end );
        $end += $v.elems;       
    }

    warn %locals.gist;

    @unit.push: @postlude.list;

    for %symbols.values -> $v {
        @unit.push: $v.list;
    }

    return @unit;
}

sub pprint_program (@program) {
    my $c = 0;
    while ( $c < @program.elems ) {
        my $inst = @program[$c];
        say sprintf("%3d", $c) ~": "~ @program[$c].perl;
        $c++;
    }
}

#pprint_program( @program );

Process.new.execute( 
    @init,
    { DEBUG => %*ENV<DEBUG> }
);


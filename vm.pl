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
            say "== START ========";            
        }

        while ( $.pc >= 0 && $.pc < @program.elems ) {
            my $inst = @program[ $.pc++ ];        
            $inst.call( self );

            if %opts<DEBUG> {
                self._dump_for_debug( $inst );
                say "-----------------";
            }
        }

        if %opts<DEBUG> {
            say "== END ==========";
        }
    }

    method _dump_for_debug ($inst) {
        say "COUNTER : " ~ $.pc;
        say "CURRENT : " ~ $inst.gist;
        say "--------|";
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

class CONST is Instruction {
    has Any $.value;

    method arity { 0 }

    method call ( Process $process ) {
        $process.data.push( $.value );
    }       
}

class LOAD is Instruction {
    method arity { 1 }

    method call ( Process $process ) {
        my $label = $process.data.pop;
        $process.data.push( $process.memory{ $label } );
    }   
}

class STOR is Instruction {
    method arity { 2 }

    method call ( Process $process ) {
        my $label = $process.data.pop;                       
        my $value = $process.data.pop;                
        $process.memory{ $label } = $value;
    }
}

class LLOAD is Instruction {
    method arity { 1 }

    method call ( Process $process ) {
        my $label = $process.data.pop;
        $process.data.push( $process.current_frame.memory{ $label } );
    }
}

class LSTOR is Instruction {
    method arity { 2 }

    method call ( Process $process ) {
        my $label = $process.data.pop;                       
        my $value = $process.data.pop;                
        $process.current_frame.memory{ $label } = $value;
    }
}

class DUP is Instruction {
    method arity { 0 }

    method call ( Process $process ) {
        $process.data.push( $process.data[*-1].clone );
    }
}

class POP is Instruction {
    method arity { 0 } 

    method call ( Process $process ) {
        $process.data.pop;
    }
}

class JUMP is Instruction {
    method arity { 1 }

    method call ( Process $process ) {
        my $addr = $process.data.pop;
        $process.pc = $addr;
    }
}

class COND is Instruction {
    method arity { 2 }

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
    method arity { 1 }

    method call ( Process $process ) {
        my $addr = $process.data.pop;
        $process.pc = $addr + $process.current_frame.laddr;
    }
}

class LCOND is Instruction {
    method arity { 2 }

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
    method arity { 1 }

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
    method arity { 0 }

    method call ( Process $process ) {
        my $frame = $process.frame.pop;
        $process.pc = $frame.raddr;   
    }
}

class ADD is Instruction {
    method arity { 2 }

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l + $r );
    }
}

class SUB is Instruction {
    method arity { 2 }

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l - $r );
    }
}

class MUL is Instruction {
    method arity { 2 }

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l * $r );   
    }
}

class DIV is Instruction {
    method arity { 2 }

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l / $r );
    }
}

class EQ is Instruction {
    method arity { 2 }

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l == $r );
    }
}

class NEQ is Instruction {
    method arity { 2 }

    method call ( Process $process ) {
        my $l = $process.data.pop;
        my $r = $process.data.pop;
        $process.data.push( $l != $r );   
    }
}

class NOOP is Instruction {
    method arity { 0 }

    method call ( Process $process ) {}
}

class OUT is Instruction {
    method arity { 1 }

    method call ( Process $process ) {
        print $process.data.pop;
    }
}

class HALT is Instruction {
    method arity { 0 }

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
        ('$x', LSTOR),            # pull x off the stack
        ('$y', LSTOR),            # pull y off the stack
    ], 
    [  (('&main', LLOAD), LJUMP) ],
    {
        '&cond001-if-true' => [
            ('$x', LLOAD),              # put x on the stack
            (('&leave', LLOAD), LJUMP), # jump to the postlude
        ],
        '&cond001-if-false' => [ 
            (1, ('$y', LLOAD), SUB),    # put y on the stack, then subtract by one
            ('$x', LLOAD),              # put x on the stack            
            (('&mul', LOAD), CALL),     # now call mul with the stack
                                        # this leaves the result of mul on the stack
            ('$x', LLOAD),              # put x on the stack
            (ADD),                      # and add them together, leaving the result on the stack
            (('&leave', LLOAD), LJUMP), # jump to the postlude
        ],
        '&main' => [
            ('$y', LLOAD),                # put y on the stack
            (1, EQ),                      # compares y to 1, gets y from the stack
            ('&cond001-if-true', LLOAD),  # if y == 1, jump to the `then` portion
            (LCOND),                        
            ('&cond001-if-false', LLOAD), # jump to the `else` portion  
            (LJUMP),                      
        ],
        '&leave' => [
            (RETN)                      # return from the sub
        ]
    },  
    local => True
);

my @main = 
    (2, 13),
    (('&mul', LOAD), CALL),
    (OUT),
;

my @exit = 
    (HALT)
;

my @init = build_symbol_table( 
    [], 
    [ ((('&main', LOAD), CALL), (HALT)) ],
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
    my $end   = $start + (3 * %symbols.keys.elems) + @postlude.elems; 

    @unit.push: @prelude.list;

    for %symbols.kv -> $k, $v {
        @unit.push: $end, $k, ($local ?? LSTOR !! STOR);
        $end += $v.elems;       
    }

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
    @init.map({ $_.does(Instruction) ?? $_.new !! CONST.new( value => $_ ) }), 
    #{ :DEBUG }
);


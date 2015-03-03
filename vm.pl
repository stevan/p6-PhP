#!perl6

our $DEBUG = 1;

enum INSTRUCTIONS (
    LOAD => 'LOAD',
    STOR => 'STOR',

    LLOAD => 'LLOAD',
    LSTOR => 'LSTOR',

    DUP  => 'DUP',
    POP  => 'POP',

    JUMP => 'JUMP',
    COND => 'COND',

    LJUMP => 'LJUMP',
    LCOND => 'LCOND',

    CALL => 'CALL',
    RETN => 'RETN',

    HALT => 'HALT',
    NOOP => 'NOOP',    

    ADD  => 'ADD',
    SUB  => 'SUB',
    MUL  => 'MUL',
    DIV  => 'DIV',

    EQ   => 'EQ',
    NEQ  => 'NEQ',

    OUT  => 'OUT',
);

sub execute (@program) {

    my %memory;
    my @data;
    my @frame;

    my $pc = 0;

    while ( $pc < @program.elems ) {

        my $inst = @program[ $pc++ ];

        if $DEBUG {
            warn "DEBUG: Running instruction <$inst> at <$pc> with:\n"
                ~ "data-stack: [" ~ @data.join(', ') ~ "]\n"
                ~ "frame-stack: [\n"
                    ~ @frame.map(-> $f {
                        "\t[\n" ~
                        "\t\traddr: " ~ $f{'raddr'}     ~ "\n" ~
                        "\t\tladdr: " ~ $f{'laddr'}     ~ "\n" ~
                        "\t\tdata: "  ~ $f{'data'}.perl ~ "\n" ~
                        "\t]"        
                    }).join(', ')
                ~ "\n]\n"
                ~ "memory: " ~ %memory.perl 
                ~ "\n";
        }

        given $inst {
                
            # accessing memory 
            when LOAD {
                my $label = @data.pop;
                @data.push( %memory{ $label } );
            }
            when STOR {         
                my $label = @data.pop;                       
                my $value = @data.pop;                
                %memory{ $label } = $value;
            }

            # accessing local memory
            when LLOAD {
                my $label = @data.pop;
                @data.push( @frame[*-1]{'data'}{ $label } );
            }
            when LSTOR {         
                my $label = @data.pop;                       
                my $value = @data.pop;                
                @frame[*-1]{'data'}{ $label } = $value;
            }

            # stack manipulation
            when DUP {
                @data.push( @data[*-1].clone );
            }
            when POP {
                @data.pop;
            }

            # labels
            when LJUMP {
                my $addr = @data.pop;
                $pc = $addr + @frame[*-1]{'laddr'};
            }
            when LCOND {
                my $addr  = @data.pop;                
                my $value = @data.pop;
                if $value == True {
                    #warn "Got a true value $value, jumping to $addr";
                    $pc = $addr + @frame[*-1]{'laddr'};
                } else {
                    #warn "Did not get a true value: $value"
                }
            }

            when LJUMP {
                my $addr = @data.pop;
                $pc = $addr;
            }
            when COND {
                my $addr  = @data.pop;                
                my $value = @data.pop;
                if $value == True {
                    #warn "Got a true value $value, jumping to $addr";
                    $pc = $addr;
                } else {
                    #warn "Did not get a true value: $value"
                }
            }

            when CALL {
                my $addr = @data.pop;
                @frame.push: { 
                    raddr => $pc.clone, 
                    laddr => $addr.clone, 
                    data  => {} 
                };
                #say "WTF!!!!" ~ @frame[*-1].perl;
                $pc = $addr;
            }
            when RETN {
                my %frame = %( @frame.pop );
                $pc = %frame{'raddr'};
            }

            # Maths
            when ADD {
                my $l = @data.pop;
                my $r = @data.pop;
                @data.push( $l + $r );
            }
            when SUB {
                my $l = @data.pop;
                my $r = @data.pop;
                @data.push( $l - $r );
            }
            when MUL {
                my $l = @data.pop;
                my $r = @data.pop;
                @data.push( $l * $r );
            }
            when DIV {
                my $l = @data.pop;
                my $r = @data.pop;
                @data.push( $l / $r );
            }

            # Logic
            when EQ {
                my $l = @data.pop;
                my $r = @data.pop;
                @data.push( $l == $r );
            }
            when NEQ {
                my $l = @data.pop;
                my $r = @data.pop;
                @data.push( $l != $r );
            }

            # I/O
            when OUT {
                print @data.pop;
            }

            # Misc
            when NOOP { next }
            when HALT { last }

            # Data 
            default {
                @data.push( $inst );
            }
        } 
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

# pprint_program( @mul );

execute( @init );

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
    say @program.keys.map({ sprintf("%3d", $_) ~ ": " ~ @program[$_] }).join("\n");
}





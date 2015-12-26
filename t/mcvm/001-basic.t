#!perl6

use v6;
use lib 'lib';
use Test;

use MCVM;
use MCVM::Utils;

plan *;

# in PhP:
#
# let mul = fun (x, y)
#               if ( y == 1 )
#                   then x
#                   else x + mul( x, y - 1 )
# in
#    mul 13, 2
# ;;
#
# in MCVM Assembler:
#
# SUB multiply {
#     ARGS {
#         LSTOR $x
#         LSTOR $y
#     }
#     BODY {
#         init:
#             LLOAD &enter
#             LJUMP
#         enter:
#             LLOAD $y
#             PUSH @(1)
#             EQ
#             LLOAD &cond_if_true
#             LCOND
#             LLOAD &cond_if_false
#             LJUMP
#         cond_if_true:
#             LLOAD $x
#             LLOAD &leave
#             LJUMP
#         cond_if_false:
#             PUSH @(1)
#             LLOAD $y
#             SUB
#             LLOAD $x
#             LOAD &multiply
#             CALL
#             LLOAD $x
#             ADD
#             LLOAD &leave
#             LJUMP
#         leave:
#             RETN
#     }
# }



my @mul = MCVM::Utils::assemble(
    [
        MCVM::Instructions::LSTOR.new( label => '$x' ),     # pull $x off the stack
        MCVM::Instructions::LSTOR.new( label => '$y' ),     # pull $y off the stack
    ],
    [
        MCVM::Instructions::LLOAD.new( label => '&enter'),
        MCVM::Instructions::LJUMP.new
    ],
    {
        '&enter' => [
            MCVM::Instructions::LLOAD.new( label => '$y' ),                # put $y on the stack
            MCVM::Instructions::PUSH.new( value => 1 ),                    # put 1 on the stack
            MCVM::Instructions::EQ.new,                                    # compare $y to 1, leave bool on the stack
            MCVM::Instructions::LLOAD.new( label => '&cond001-if-true' ),  # load the address of the 'true' block
            MCVM::Instructions::LCOND.new,                                 # if top of the stack is true, goto 'true' block
            MCVM::Instructions::LLOAD.new( label => '&cond001-if-false' ), # if we are still here, load the address of the 'false' block
            MCVM::Instructions::LJUMP.new,                                 # and then jump to the 'false' block
        ],
        '&cond001-if-true' => [
            MCVM::Instructions::LLOAD.new( label => '$x'     ),  # put $x on the stack
            MCVM::Instructions::LLOAD.new( label => '&leave' ),  # put the local-exit address on the stack
            MCVM::Instructions::LJUMP.new,                       # jump to the postlude
        ],
        '&cond001-if-false' => [ 
            MCVM::Instructions::PUSH.new( value => 1 ),         # put 1 on the stack
            MCVM::Instructions::LLOAD.new( label => '$y' ),     # put $y on the stack
            MCVM::Instructions::SUB.new,                        # then subtract 1 from $y
            MCVM::Instructions::LLOAD.new( label => '$x' ),     # put $x on the stack
            MCVM::Instructions::LOAD.new( label => '&mul' ),    # put the address of &mul on the stack
            MCVM::Instructions::CALL.new,                       # call &mul
                                                                # this leaves the result of mul on the stack
            MCVM::Instructions::LLOAD.new( label => '$x' ),     # put x on the stack
            MCVM::Instructions::ADD.new,                        # and add the value of $x and the return value of &mul
            MCVM::Instructions::LLOAD.new( label => '&leave' ), # put the local-exit address on the stack
            MCVM::Instructions::LJUMP.new,                      # jump to the postlude
        ],
        '&leave' => [
            MCVM::Instructions::RETN.new   # return from the sub
        ]
    },
    local => True
);

my @main = (
    MCVM::Instructions::PUSH.new( value => 2 ),
    MCVM::Instructions::PUSH.new( value => 13),
    MCVM::Instructions::LOAD.new( label => '&mul'),
    MCVM::Instructions::CALL.new
);

my @exit = (MCVM::Instructions::HALT.new);

my @init = MCVM::Utils::assemble(
    [],
    [
        MCVM::Instructions::LOAD.new( label => '&main' ),
        MCVM::Instructions::CALL.new,
        MCVM::Instructions::HALT.new,
    ],
    {
        '&mul'  => @mul,
        '&main' => @main,
        '&exit' => @exit,
    }
);

MCVM::Utils::pprint( @init );

my $process = MCVM::run( @init, { DEBUG => %*ENV<DEBUG> } );
isa-ok($process, MCVM::Machine::Process);
is($process.data[*-1], 26, '... found the right value on the top of the stack');

#$process._dump_for_debug(MCVM::Instructions::NOOP.new);

done-testing;

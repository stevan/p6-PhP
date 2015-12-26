use v6;

package MCVM::Utils {

    use MCVM::Instructions;

    our sub assemble ( @prelude, @postlude, %symbols, :$local = False ) {
        my @unit;

        my $start = @prelude.elems;
        my $end   = $start + %symbols.keys.elems + @postlude.elems;

        for @prelude -> $inst {
            @unit.push: $inst;
        }

        my %locals;

        for %symbols.kv -> $k, $v {
            %locals{ $k } = $end;
            @unit.push(
                $local
                    ?? MCVM::Instructions::LSTOR.new( label => $k, value => $end )
                    !! MCVM::Instructions::STOR.new( label => $k, value => $end )
            );
            $end += $v.elems;
        }

        #warn %locals.gist;


        for @postlude -> $inst {
            @unit.push: $inst;
        }

        for %symbols.values -> @insts {
            for @insts -> $inst {
                @unit.push: $inst;
            }
        }

        return @unit;
    }

    our sub pprint (@program, $printer = &say ) {
        my $c = 0;
        while ( $c < @program.elems ) {
            my $inst = @program[$c];
            $printer.( sprintf("%3d", $c) ~": "~ @program[$c].perl );
            $c++;
        }
    }
}


use v6;

package MCVM::Utils {

    use MCVM::Instructions;

    our sub assemble ( @prelude, @postlude, %symbols, :$local = False ) {
        my @unit;

        my $start = @prelude.elems;
        my $end   = $start + %symbols.keys.elems + @postlude.elems; 

        @unit.push: @prelude.list;

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

        @unit.push: @postlude.list;

        for %symbols.values -> $v {
            @unit.push: $v.list;
        }

        return @unit;
    }

    our sub pprint (@program) {
        my $c = 0;
        while ( $c < @program.elems ) {
            my $inst = @program[$c];
            say sprintf("%3d", $c) ~": "~ @program[$c].perl;
            $c++;
        }
    }
}


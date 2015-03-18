set -x

clean_up_moar () {
    rm -f lib/PhP.pm6.moarvm
    rm -f lib/PhP/AST.pm6.moarvm
    rm -f lib/PhP/Compiler.pm6.moarvm
    rm -f lib/PhP/Interpreter.pm6.moarvm
    rm -f lib/PhP/Parser.pm6.moarvm
    rm -f lib/PhP/Parser/Actions.pm6.moarvm
    rm -f lib/PhP/Parser/Grammar.pm6.moarvm
    rm -f lib/PhP/Runtime.pm6.moarvm
    rm -f bin/php.moarvm
}

compile_to_moar () {
    perl6 -I lib/ --target=mbc --encoding=utf8 --output=lib/PhP/Parser/Grammar.pm6.moarvm lib/PhP/Parser/Grammar.pm6
    perl6 -I lib/ --target=mbc --encoding=utf8 --output=lib/PhP/AST.pm6.moarvm lib/PhP/AST.pm6
    perl6 -I lib/ --target=mbc --encoding=utf8 --output=lib/PhP/Parser/Actions.pm6.moarvm lib/PhP/Parser/Actions.pm6    
    perl6 -I lib/ --target=mbc --encoding=utf8 --output=lib/PhP/Parser.pm6.moarvm lib/PhP/Parser.pm6
    perl6 -I lib/ --target=mbc --encoding=utf8 --output=lib/PhP/Runtime.pm6.moarvm lib/PhP/Runtime.pm6
    perl6 -I lib/ --target=mbc --encoding=utf8 --output=lib/PhP/Compiler.pm6.moarvm lib/PhP/Compiler.pm6
    perl6 -I lib/ --target=mbc --encoding=utf8 --output=lib/PhP/Interpreter.pm6.moarvm lib/PhP/Interpreter.pm6
    perl6 -I lib/ --target=mbc --encoding=utf8 --output=lib/PhP.pm6.moarvm lib/PhP.pm6
    perl6 -I lib/ --target=mbc --encoding=utf8 --output=bin/php.moarvm bin/php
}

clean_up_moar

if [ "$1" != "clean" ]; then 
    compile_to_moar
fi

echo "Complete."

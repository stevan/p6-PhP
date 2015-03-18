# Questions

- what is the difference between a package and a module?

# Environment

- rakudobrew is awesome! nuff said
- Getting syntax highlighting working was a must
    - the color scheme had to be different
- the REPL is great for testing things
    - like a usable one-liner

# Documentation

- #1 issue is that the documentation is a mess
    - old stuff is still out there and heavily indexed
    - new stuff is spread all over the place
        - Advent Calendars (useful but too slim)
        - Synopsis (usful but too fat (and not everything has been implemented))
        - perl6 docs (lots of stuff about Cool, Mu, etc. not as much about actual type)

- the docs on `multi` were a little slim
- given/when dispatching is tricky
    - I know this is tied to smartmatch, ... and smartmatch is tricky

- documentation on testing was easy to find
    - testing was very easy to do as it hasn't changed much
    - but I couldn't find Test.pm anywhere
        - https://github.com/rakudo/rakudo/blob/nom/lib/Test.pm

- documentation on how to pre-compile Perl 6 files to moarvm was non-existant
    - I had to dig through the panda source
    - I found the basics, but was unclear of exactly how it works
    - finally managed to find it by trial and error and vague recollections of the panda source
    - so what is it??
        - topologically sort your .p6/.pm6 files
        - build them with the following:
            --target=mbc
            --encoding=utf8
            --output=SameFileName.pm6.moarvm
        - then just use perl6 in the same way
            - and it will automagically find the .moarvm files
    - see build.sh for details

- documentation about MoarVM speedup was not easy to find
    - it cut the test run to 29% of total 
    - it cut the parse time to 17% of total 
    - this very much changes the usability of the language!

# Error messages

- error messages vary widely
    - they can be really amazingly helpful
        - syntax error placement indicated by the use of unicode characters is very nice
        - guessing class/type names is very nice
            - you said "Foo", but did you mean "Faux" ...
    - they can be kinda useful and kinda cryptic 
        - once you get used to them, you recognize the pattern 
    - they can be completely useless
        - some type errors can get down right esoteric
    - examples:
        - 'Cannot look up attributes in a type object'
            - this is similar to the "Cannot find method blah on (Any)", not helpful

# Syntax

- choosing a named parameter passing syntax is actually hard
    - foo => 10  # old standby
    - :foo(10)   # new fancy Rubyish symbol style
    - :foo<10>   # new Perl 6 hash key style
    - TIMTOWTDI gone wild?
    - What did I do??
        - I started out with => p5 style
        - but switched to :foo() style afterwards
            - I liked it, but it did feel a little verbose
            - i did not like how it wasn't conducive to vertical alignment
                foo => 10,
                bo  => 20,
                etc => 30,
            - v.s.
                :foo(10)
                :bo(20)
                :etc(30)            
        - eventually I switched back to the p5 style
            - during conversion I am realizing how verbose the p6 style is
              and how slim the p5 style is, and clearer as well
        - notes from switching
            - the p5 style takes up less horizontal and verticle space
                - the p6 style ends up being multiple levels deeper indent-wise
            - the p6 style obscures Array parameters (attributes like: @.params, etc)
                - since you can do:
                    - :foo(10, 20, 30)
                - but this is much clearer and familiar
                    - foo => [ 10, 20, 30 ]
                - one of the key strengths of the p5 reference syntax is how clear
                  it is within a data structure, the same is true of JSON, which I think
                  partially lead to it's success, the fact that it is easy for humans
                  and for computers to parse. The same is true above.

# Types

- container typing is odd, until you think about it
    - has Int @.foo; # an Array of Ints

- the various container types can be confusing, not always clear what you are going to get
    - when is it a Positional[Int] vs. Array[Int], etc
    - this might be in the docs, but was not easy to find

- types on `our` variables is off
    - the fact I can't attach a type to them is really odd
        > package Foo { our Int $FOO = 10; }
        ===SORRY!=== Error while compiling <unknown file>
        Cannot put a type constraint on an 'our'-scoped variable
        at <unknown file>:1
        ------> package Foo { our Int $FOO ⏏= 10; }
            expecting any of:
                constraint
    - the fact that I have to do it like this, is very very odd
        > package Foo { our $FOO is Int = 10; }
        ===SORRY!=== Error while compiling
        Variable trait 'is TypeObject' not yet implemented. Sorry.
        at :1
        ------> package Foo { our $FOO is Int ⏏= 10; }
            expecting any of:
                constraint

# Style/Idioms

- a lot of the Perl 6 code out there seems to avoid looking liker Perl 5
    - for instance: lots of paren-less `if` statements
    - lots of usage of `<>` for hash key access
    - lots of `-` in subroutine names
    - colon method call syntax (ex. obj.method: @args)

- new for loop was hard to remember, makes sense, but unintuitive for p5
    - having C style for loop just use 'loop' is odd
    - reversing the args is nice, but initially awkward 
        - for @list -> $topic {}

- it is not clear how to organize packages/classes
    - this is something we encountered in p5-mop as well
    - in Perl 5 there is a clear correspondence with package and files
        - this is no longer the case

- the fact that subroutines need an `our` before them to be public was odd

- at first, when I heard about the MAIN arguments -> ARGV behavior, I was like, wtf
    - but then I used it:
        $file?,           # <file> evaluate the code in a file and print the result
        :$e?,             # -e evaluate a string of code and print the result
        Bool :$c = False, # -c Just compile the source
        Bool :$d = False, # -d turn on debugging (just dumping extra info for now) 
        Bool :$v = False, # -v print out version information  
    - and it translated beautifully

# refactors to show

- e7106955f0f60cbd83bf2e16552e223c00a2f8f2 => adding in the terminal nodes





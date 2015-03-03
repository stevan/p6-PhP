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

# Syntax

- choosing a named parameter passing syntax is actually hard
    - foo => 10  # old standby
    - :foo(10)   # new fancy Rubyish symbol style
    - :foo<10>   # new Perl 6 hash key style
    - TIMTOWTDI gone wild?

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




# Syntax

- choosing a parameter passing syntax is actually hard
    - TIMTOWTDI gone wild?

# Semantics

# Types

- container typing is odd, until you think about it
    - has Int @.foo; # an Array of Ints

# Style/Idioms

- a lot of the Perl 6 code out there seems to avoid looking liker Perl 5
    - for instance: lots of paren-less `if` statements
    - lots of usage of `<>` for hash key access
    - lots of `-` in subroutine names

- new for loop was hard to remember, makes sense, but unintuitive for p5

- it is not clear how to organize packages/classes
    - this is something we encountered in p5-mop as well
    - in Perl 5 there is a clear correspondence with package and files
        - this is not as clear ...

- the fact that subroutines need an `our` before them to be public was odd

# Misc

- Getting syntax highlighting working was a must
    - the color scheme had to be different
- the docs on `multi` were a little slim

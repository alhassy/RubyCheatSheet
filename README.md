Reference of basic commands to get comfortable with Ruby &#x2014;Modern and nearly pure OOP!

◈ [Website](https://alhassy.github.io/RubyCheatSheet/) ◈

**The listing sheet, as PDF, can be found
 [here](CheatSheet.pdf)**,
 or as a [single column portrait](CheatSheet_Portrait.pdf),
 while below is an unruly html rendition.

This reference sheet is built from a
[CheatSheets with Org-mode](https://github.com/alhassy/CheatSheet)
system.


# Table of Contents

1.  [Administrivia](#org18e5a18)
2.  [Everything is an object!](#orgfc0fc27)
3.  [Functions &#x2013; Blocks](#orgb7b3bf5)
4.  [Methods as Values](#org8607a16)
5.  [Variables & Assignment](#org3c32da4)
6.  [Strings and `%`-Notation](#org55043f2)
7.  [Booleans](#org51533c5)
8.  [Arrays](#org576d3ef)
9.  [Symbols](#orgf5e7b35)
10. [Control Flow](#org4b3edcd)
11. [Hashes](#org13bdac7)
    1.  [Variadic keyword arguments](#org540c0ef)
    2.  [Rose Trees](#orgf48c78c)
12. [Classes](#orgf5d316e)
    1.  [Modifiers: `public, private, protected`](#org480bab2)
    2.  [Even classes are objects!](#orgac122ea)
    3.  [Example: Person Class](#orga31d8af)
    4.  [Classes are open!](#org379c54e)
13. [Modules & Mixins](#orgd14b381)
14. [Todo COMMENT more](#orgd9c230a)
    1.  [Printing and Comments](#org9a65832)
    2.  [“Ruby is Pure OO” &#x2013; 99% true!?](#org0e4d23a)
    3.  [η rule](#org8df41cb)
15. [Reads](#orga69a3f5)















<a id="org18e5a18"></a>

# Administrivia

⇒ Ruby has a interactive command line. In terminal, type `irb`.

⇒ To find your Ruby version, type `ruby --version`; or in a Ruby script:

    RUBY_VERSION # ⇒ 2.3.7

    # In general, use backtics `⋯` to call shell commands
    `ls -ll ~` # ⇒ My home directory's contents!

⇒ Single line comments marked by `#`.
 Multi-line comments enclosed by `=begin` and `=end`.

⇒ Newline or semicolon is used to separate expressions; other whitespace is irrelevant.

⇒ Variables don't have types, values do.

-   *The type of a variable is the class it belongs to.*
-   Variables do not need declarations.


<a id="orgfc0fc27"></a>

# Everything is an object!

Method calls are really message passing:
`x ⊕ y ≈ x.⊕(y) ≈ x.send "⊕" , y`

Methods are also objects:
`f x ≈ method(:f).call x`

**Remember**: Use `name.methods` to see the methods a name has access to.
Super helpful to discover features!

    "Hi".class                # ⇒ String
    "Hi".method(:class).class # ⇒ Method
    "Hi".methods              # ⇒ Displays all methods on a class ♥‿♥
    2.methods.include?(:/)    # ⇒ true, 2 has a division method

Everything has a value &#x2014;possibly `nil`.

-   There's no difference between an expression and a statement!


<a id="orgb7b3bf5"></a>

# Functions &#x2013; Blocks

Multiple ways to define anonymous functions; application can be a number of ways too.

Parenthesises are optional unless there's ambiguity.

-   The value of the last statement is the ‘return value’.
-   Function application is right-associative.
-   Arguments are passed in with commas.

<div class="parallel">
    fst = lambda { |x, y| x}
    fst.call(1, 2)   # ⇒ 1
    fst.(1, 2)       # ⇒ 1

    # Supply one argument at a time.
    always7 = fst.curry.(7)
    always7.(42)             # ⇒ 42

    # Expplicitly curried.
    fst = lambda {|x| lambda {|y| x}}
    fst = ->(x) {->(y) {x}}
    fst[10][20]  # ⇒ 10
    fst.(100).(200)  # ⇒ 100

    fst.methods # ⇒ arity, lambda?,
                #   parameters, curry

    def sum x, y = 666, with: 0
      x + y + with end

    sum (sum 1, 2) , 3 # ⇒ 6
    sum 1              # ⇒ 667
    sum 1, 2           # ⇒ 3
    sum 1, 22, with: 3  # ⇒ 6

</div>

Notice that the use of ‘=’ in an argument list to mark arguments as **optional** with default values.
We may use **keyword** arguments, by suffixing a colon with an optional default value
to mark the argument as optional; e.g., omitting the `0` after `with:` makes it a necessary (keyword) argument.
[Such](https://stackoverflow.com/questions/89650/how-do-you-pass-arguments-to-define-method/11098487#11098487) may happen in `|⋯|` for arguments to blocks.

Convention:
Predicate names end in a `?`; destructive function names end in `!`.
\newline
That is, methods ending in `!` change a variable's value.

**Higher-order**: We use `&` to indicate that an argument is a function.

    def apply(x, &do_it) if block_given? then do_it.call(x) else x end end
    apply (3) { |n| 2 * n }   # ⇒ 6, parens around ‘3’ are needed!
    apply 3 do |n| 20 * n end # ⇒ 6
    apply 3                   # ⇒ 3

In fact, all methods have an implicit, optional block parameter.
It can be called with the `yield` keyword.

    sum(1, 2) do |x| x * 0 end  # ⇒ 3, block is not used in “sum”

    def sum′ (x, y) if block_given? then yield(x) + yield(y) else x + y end end
    sum′(1, 2)                   # ⇒ 3
    sum′(1, 2) do |n| 2 * n end  # ⇒ 6
    sum′(1, 2) do end # ⇒ nil + nil, but no addition on nil: CRASHES!
    sum′(1, 2) { 7 }  # ⇒ 14; Constanly return 7, ignoring arguments; 7 + 7 ≈ 14

**Note**: A subtle difference between `do/end` and `{/}` is that the latter binds tightly to the closest method;
e.g., `puts x.y { z } ≈ puts (x.y do z end)`.

Variadic number of arguments:

    def sum″ (*lots_o_stuff) toto = 0; lots_o_stuff.each{ |e| toto += e}; toto end
    sum″ 2 , 4 , 6 , 7  #⇒ 19

    # Turn a list into an argument tuple using “splat”, ‘*’
    nums = [2, 4, 6, 7, 8, 9]
    # sum″ nums  #⇒ Error: Array can't be coerced into number
    sum″ *nums.first(4)  #⇒ 19

If a name is overloaded as a variable and as a function, then an empty parens must be used
when the function is to be invoked.

    w = "var"
    def w; "func" end
    "w: #{w}, but w(): #{w()}" # ⇒ w: var, but w(): func

How to furnish a single entity with features?
*“Singleton methods/classes”!* You can attach methods to existing names whenever you like.
(Instance vars are `nil` by default.)

    x = "ni"
    def x.upcase; "Knights who say #{self} × #{@count = (@count || 0) + 1}" end
    x.upcase # ⇒ Knights who say ni × 1
    x.upcase # ⇒ Knights who say ni × 2

    # Other items are unaffected.
    "ni".upcase  # ⇒ NI, the usual String capitalisation method

In general,
the syntax `class << x ⋯ end` will attach *all usual class contents* “⋯” *only* for the entity
`x`. ( Undefined instance variables are always `nil`. )

We can redfine any method; including the one that handles missing method issues.

    x.speak # ⇒ Error: No method ‘speak’
    # Do nothing, yielding ‘nil’, when a method is missing.
    def method_missing(id, *args) end
    x.speak # ⇒ nil

A “ghost method” is the name of the technique to dynamically a create a method
by overriding `method_missing`. E.g., [by forwarding](https://gist.github.com/Integralist/a29212a8eb10bc8154b7#file-04-dynamic-proxies-rb) ghosts `get_x` as calls `get(:x)`
*with* extra logic about them.

Operators are syntactic sugar and can be overrided.
This includes the arithmetical ones, and `[]`, `[]=`; and unary ± via `+@`, `-@`.

<div class="parallel">
    def x.-(other); "nice" end
    x - "two" # ⇒ "nice"

Forming aliases:


    alias summing sum″
    summing 1, 2, 3  # ⇒ 6

</div>


<a id="org8607a16"></a>

# Methods as Values

Method declarations are expressions:
A method definition returns the method's name as a symbol.

    def woah; "hello" end # ⇒ :woah

    woah′ = method(:woah) # ⇒ #<Method: Object#woah>

    woah′.call # ⇒ hello

    method(:woah).call # ⇒ hello

Notice that using the operation `method` we can obtain the method associated with a symbol.

Likewise, <a id="org45142d5">`define_method`</a> takes a name and a block, and ties those together to make a method.
It overrides any existing method having that name.

The following is known as “decoration” or “advice”!

Besides decorating a function call to print a trace like below,
it can be used to add extra behaviour such as [caching](https://dev.to/baweaver/decorating-ruby-part-1-symbol-method-decoration-4po2) expensive calls,
[mocking](https://relishapp.com/rspec/rspec-mocks/docs) entities for testing, or doing a form of [typing](https://alhassy.github.io/TypedLisp/#typing-via-macros)
( [Ruby is a Lisp](http://www.randomhacks.net/2005/12/03/why-ruby-is-an-acceptable-lisp/) ).

    define_method(:ni) {|x| x}

    def notify(method_name)
      orginal = method(method_name)
      define_method(method_name) { |*args, &blk|
        p "#{method_name} running ... got #{orginal.call(*args, &blk)}"} end

    notify def no_op (x) x end

    no_op 1 # ⇒ no_op running ... got 1

    # “x.singleton_class.include(M)” to wholesale attach module M's contents to x.

See [here](https://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Method_Calls) for a nifty article on methods in Ruby.


<a id="org3c32da4"></a>

# Variables & Assignment

Assignment ‘=’ is right-associative and returns the value of the RHS.

    # Flexible naming, but cannot use ‘-’ in a name.
    this_and_that = 1
    𝓊ℕ𝒾ℂ∅𝒟𝑬     = 31

    # Three variables x,y,z with value 2.
    x = y = z = 2

    # Since everything has a value, “y = 2” ⇒ 2
    x = 1, y = 2  # Whence, x gets “[1, 2]”!
    # Arrays are comma separated values; don't need [ and ]

    x = 1; y = 2  # This is sequential assignment.

    # If LHS as has many pieces as RHS, then we have simultenous assignment.
    x , y = y , x # E.g., this is swap

    # Destructuring with “splat” ‘*’
    a , b, *more = [1, 2, 3, 4, 5] # ⇒ a ≈ 1; b ≈ 2; c ≈ [3, 4, 5]
    first, *middle, last = [1, 2, 3, 4, 5] # ⇒ first ≈ 1; middle ≈ [2, 3, 4]; last = 5
    last

    # Without splat, you only get the head element!
    a , b, c = [1, 2, 3, 4, 5] # ⇒ a ≈ 1; b ≈ 2; c ≈ 3

“Assign if undefined”: `x ||= e` yields `x` if it's a defined name, and is `x = e` otherwise.
This is useful for having local variables, as in loops or terse function bodies.

    nope rescue "“nope” is not defined."
    # nope ||= 1 # ⇒ nope = 1
    # nope ||= 2 # ⇒ 1, since “nope” is defined

Notice: `B rescue R` ≈ Perform code `B`, if it crashes perform code `R`.


<a id="org55043f2"></a>

# Strings and `%`-Notation

Single quotes are for string literals,
    whereas double quotes are for string evaluation, [‘interpolation’](https://www.google.com/search?q=interpolation&oq=interpolation&aqs=chrome..69i57j0l5.724j0j7&sourceid=chrome&ie=UTF-8).
    Strings may span multiple lines.

<div class="parallel">
    you = 12
    # ⇒ 12

    "Me and \n #{you}"
    # ⇒ Me and ⟪newline here⟫ 12

    'Me and \n #{you}'
    # ⇒ Me and \n #{you}

    # “to string” and catenation
    "hello " + 23.to_s  # ⇒ hello 23

    # String powers
    "hello " * 3
    # ⇒ hello hello hello

    # Print with a newline
    puts "Bye #{you}"
    # ⇒ Bye 12 ⇒ nil

    # printf-style interpolation
    "%s or %s" % ["this" , "that"]
    it = %w(this that); "%s or %s" % it

</div>

Strings are essentially arrays of characters, and so array operations work as expected!

There is a Perl-inspired way to quote strings, by using % along with any
non-alpha-numeric character acting as the quotation delimiter.
Now only the new delimiter needs to be escaped; e.g., `"` doesn't need escape.

A type modifier can appear after the `%` :
  `q` for strings, `r` for regexp, `i` symbol array, `w` string array, `x` for shell command,
  and `s` symbol. Besides `x, s`, the rest can be capitalised to allow interpolation.

    %{ woah "there" #{1 + 2} }  # ⇒ "woah \"there\" 3"
    %w[ woah "there" #{1 + 2} ] # ⇒ ["woah", "\"there\"", "\#{1", "+", "2}"]
    %W[ woah "there" #{1 + 2} ] # ⇒ ["woah", "\"there\"", "3"]
    %i( woah "there" )          # ⇒ [ :woah, :"there"]

See [here](https://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Literals#The_%_Notation) for more on the %-notation.


<a id="org51533c5"></a>

# Booleans

`false, nil` are both considered *false*; all else is considered *true*.

-   Expected relations: `==, !=, !, &&, ||, <, >, <=, >=`
-   `x <=> y` returns 1 if `x` is larger, 0 if equal, and -1 otherwise.
-   “Safe navigation operator”: `x&.y ≈ (x && x.y)`.
-   `and, or` are the usual logical operators but with lower precedence.
-   They're used for control flow; e.g.,
    `s₀ and s₁ and ⋯ and sₙ` does each of the `sᵢ` until one of them is false.

Since [Ruby is a Lisp](http://www.randomhacks.net/2005/12/03/why-ruby-is-an-acceptable-lisp/), it comes with [many equality operations](http://rubylearning.com/blog/2010/11/17/does-ruby-have-too-many-equality-tests/); including `=~` for regexps.



<a id="org576d3ef"></a>

# Arrays

Arrays are heterogeneous, 0-indexed, and [ brackets ] are optional.

    array   = [1, "two", :three, [:a, "b", 12]]
    again   =  1, "two", :three, [:a, "b", 12]

Indexing: `x[±i]` ≈ “value if i < x.length else nil”
`x[i]` ⇒ The *i-th* element from the start; `x[-i]` ⇒ *i-th* element from the end.

    array[1]     # ⇒ "two"
    array[-1][0] # ⇒ :a

Segments and ranges:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">`x[m, k] ≈ [xₘ, xₘ₊₁, …, xₘ₊ₖ₋₁]`</td>
</tr>


<tr>
<td class="org-left">`x[m..n] ≈ [xₘ, xₘ₊₁, …, xₙ]` if \(m ≤ n\) and `[]` otherwise</td>
</tr>


<tr>
<td class="org-left">`x[m...n] ≈ x[m..n-1]` &#x2014;to exclude last value</td>
</tr>


<tr>
<td class="org-left">`a[i..j] = r` ⇒ `a ≈ a[0, i] + *r + a[j, a.length]`</td>
</tr>


<tr>
<td class="org-left">Syntactic sugar: `x[i] ≈ x.[] i`</td>
</tr>
</tbody>
</table>

Where `*r` is array coercion:
Besides splicing, <a id="org67bee57">splat</a> is also used to coerce values into arrays;
some objects, such as numbers, don't have a `to_a` method, so this makes up for it.

    a = *1      # ⇒ [1]
    a = *nil    # ⇒ []
    a = *"Hi"   # ⇒ ["Hi"]
    a = *(1..3) # ⇒ [1, 2, 3]
    a = *[1,2]  # ⇒ [1, 2]

    # Non-symmetric multiplication; x * y ≈ x.*(y)
    [1,2,3] * 2    # ⇒ [1,2,3,1,2,3]
    [1,2,3] * "; " # ⇒ "1; 2; 3"

As always, learn more with `array.methods` to see, for example,
`first, last, reverse, push and << are both “snoc”, include? “∋”, map`.
Functions `first` and `last` take an optional numeric argument \(n\)
to obtain the *first n* or the *last n* elements of a list.

Methods yield new arrays; updates are performed by methods ending in “!”.

    x = [1, 2, 3]  # A new array
    x.reverse      # A new array; x is unchanged
    x.reverse!     # x has changed!

    # Traverse an array using “each” and “each_with_index”.
    x.each do |e| puts e.to_s end

Catenation `+`, union `|`, difference `-`, intersection `&`.
\newline
[Here](https://itnext.io/a-ruby-cheatsheet-for-arrays-c8e5275155b5) is a cheatsheet of array operations in Ruby.

What Haskell calls `foldl`, Ruby calls `inject`; \newline e.g.,
`xs.inject(0) do |sofar, x| sofar + x end` yields the sum of `xs`.



<a id="orgf5e7b35"></a>

# Symbols

Symbols are immutable constants which act as *first-class variables.*

-   Symbols evaluate to themselves, like literals `12` and `"this"`.

<div class="parallel">
    :hello.class # ⇒ Symbol
    # :nice = 2 # ⇒ ERROR!

    # Conversion from strings
    "nice".to_sym == :nice  # ⇒ true

</div>

Strings occupy different locations in memory
even though they are observationally indistinguishable.
In contrast, all occurrences of a symbol refer to the same memory location.

    :nice.object_id == :nice.object_id   # ⇒ true
    "this".object_id == "this".object_id # ⇒ false


<a id="org4b3edcd"></a>

# Control Flow

We may omit `then` by using `;` or a newline, and
may contract `else if` into `elsif`.

    # Let 𝒞 ∈ {if, unless}
    𝒞 :test₁ then :this else :that end
    this 𝒞 test  ≈  𝒞 test then this else nil end

      (1..5).each do |e| puts e.to_s end
    ≈ 1 .upto 5 do |e| puts e end
    ≈ 5 .downto 1 do |e| puts 6 - e end
    ≈ for e in 1..5 do puts e.to_s end
    ≈ e = 1; while e <= 5 do puts e.to_s; e += 1 end
    ≈ e = 1; begin puts e.to_s; e += 1 end until e > 5
    ≈ e = 1; loop do puts e.to_s; e += 1; break if e > 5 end

Just as `break` exits a loop, `next` continues to the next iteration,
and `redo` restarts at the beginning of an iteration.

There's also times for repeating a block a number of times, and step for
traversing over every *n*-th element of a collection.

    n.times   S ≈ (1..n).each S
    c.step(n) S ≈ c.each_with_index {|val, indx| S.call(val) if indx % n == 0}

See [here](https://www.thegeekstuff.com/2018/05/ruby-loop-examples/) for a host of loop examples.



<a id="org13bdac7"></a>

# Hashes

Also known as finite functions, or ‘dictionaries’ of key-value pairs
&#x2014;a dictionary matches words with their definitions.

Collections are buckets for objects; hashes are labelled buckets:
  The label is the key and the value is the object.
Thus, hashes are like objects of classes, where the keys are slots that are tied to values.

    hash = { "jasim" => :farm, :qasim => "hockey", 12 => true}

    hash.keys     # ⇒ ["jasim", :qasim, 12]
    hash["jasim"] # ⇒ :farm
    hash[12]      # ⇒ true
    hash[:nope]   # ⇒ nil

Simpler syntax when all keys are symbols.

    oh = {this: 12, that: "nope", and: :yup}
    oh.keys  #⇒ [:this, :that, :and]
    oh[:and] # ⇒ :yup

    # Traverse an array using “each” and “each_with_index”.
    oh.each do |k, v| puts k.to_s end

As always, learn more with
`Hash.methods`  to get `keys, values, key?, value?, each, map, count, ...`
and even the “safe navigation operator” `dig`:
`h.dig(:x, :y, :z) ≈ h[:x] && h[:x][:y] && h[:x][:y][:z]`.


<a id="org540c0ef"></a>

## Variadic keyword arguments

We may pass in any number of keyword arguments using `**`.

    def woah (**z) z[:name] end

    woah name: "Jasim" , work: "Farm" #⇒ Jasim


<a id="orgf48c78c"></a>

## Rose Trees

Hashes can be used to model (rose) trees:

    family = {grandpa: {dad:  {child1: nil, child2: nil},
                       uncle: {child3: nil, child4: nil},
                       scar:  nil}}

    # Depths of deepest node.
    def height t
        if not t
        then 0
        else t.map{|k, v| height v}.map{|e| e + 1}.max
        end end

    height family # ⇒ 3


<a id="orgf5d316e"></a>

# Classes

*<a id="org59309de">Classes</a> are labelled product types: They denote values of tuples with named components.*
Classes are to objects as cookie cutters (templates) are to cookies.


<a id="org480bab2"></a>

## Modifiers: `public, private, protected`

Modifiers: `public, private, protected`

-   Everything is public by default.
-   One a modifier is declared, by itself on its own line, it remains in effect
    until another modifier is declared.
-   Public  ⇒ Inherited by children and can be used without any constraints.
-   Protected ⇒ Inherited by children, and may be occur freely *anywhere* in the class definition;
    such as being called on other instances of the same class.
-   Private ⇒ Can only occur stand-alone in the class definition.

These are forms of advice.


<a id="orgac122ea"></a>

## Even classes are objects!

`Class` is also an object in Ruby.

      class C ⟪contents⟫ end
    ≈
      C = Class.new do ⟪contents⟫ end


<a id="orga31d8af"></a>

## Example: Person Class

*Instance attributes* are variables such that each object has a different copy;
their names must start with `@` &#x2014;“at” for “at”tribute.

*Class attributes* are variables that are mutually shared by all objects;
their names must start with `@@` &#x2014;“at all” ≈ attribute for all.

`self` refers to the entity being defined as a whole; `name` refers to the entities string name.

    class Person

      @@world = 0 # How many persons are there?
      # Instance values: These give us a reader “x.field” to see a field
      # and a writer “x.field = …” to assign to it.
      attr_accessor :name
      attr_accessor :work

      # Optional; Constructor method via the special “initialize” method
      def initialize (name, work) @name = name; @work = work; @@world += 1 end

      # See the static value, world
      def world
        @@world
      end

      # Class methods use “self”;
      # they can only be called by the class, not by instances.
      def self.flood
        puts "A great flood has killed all of humanity"; @@world = 0 end

    end

    jasim = Person.new("Qasim", "Farmer")
    qasim = Person.new("", "")
    jasim.name = "Jasim"

    puts "#{jasim.name} is a #{jasim.work}"
    puts "There are #{qasim.world} people here!"
    Person.flood
    puts "There are #{qasim.world} people here!"

-   See here to learn more about the [new](https://blog.appsignal.com/2018/08/07/ruby-magic-changing-the-way-ruby-creates-objects.html) *method*.

Using `define_method` along with
  `instance_variable_set("@#namehere", value)` and `instance_variable_get("@#namehere")`,
  we can elegantly form a number of related methods from a list of names; e.g.,
  recall `attr_accessor`. Whence **design patterns become library methods!**


<a id="org379c54e"></a>

## Classes are open!

*In Ruby, just as methods can be overriden and advised, classes are open: They can be extended anytime.*
This is akin to C# extension methods or Haskell's typeclasses.

    # Open up existing class and add a method.
    class Fixnum
      def my_times; self.downto 1 do yield end end
    end

    3.my_times do puts "neato" end # ⇒ Prints “neato” thrice

-   We can freely add and alter class continents long after a class is defined.
-   We may even alter core classes.
-   Useful to extend classes with new functionality.


<a id="orgd14b381"></a>

# Modules & Mixins

Single parent inheritance: `class Child < Parent ⋯ end`,
for propagating behaviour to similar objects.

A `module` is a collection of functions and constants,
whose contents may become part of any class.
Implicitly, the module will depend on a number of class methods
&#x2014;c.f., Java interfaces&#x2014; which are used to implement the module's
contents. This way, we can *mix in* additional capabilities into objects
regardless of similarity.

Modules:

-   Inclusion binds module contents to the class instances.
-   Extension binds module contents to the class itself.

    # Implicitly depends on a function “did”
    module M; def go; "I #{did}!" end end

    # Each class here defines a method “did”; Action makes it static.
    # Both include the module; the first dynamically, the second statically.
    class Verb; include M;  def did; "jumped" end end
    class Action; extend M; def self.did; "sat"  end end

    puts "#{Verb.new.go} versus #{Action.go}"
    # ⇒ I jumped! versus I sat!

For example, a class wanting to be an `Enumerable` must implement `each`
and a class wanting to be `Comparable` must implement the ‘spaceship’
operator `<=>`. In turn, we may then use `sort, any?, max, member?, …`;
run `Enumerable.instance_methods` to list many useful methods.

Modules are also values and can be defined anywhere:

    mymod = Module.new do def talk; "Hi" end end


<a id="orgd9c230a"></a>

# Todo COMMENT more


<a id="org9a65832"></a>

## Printing and Comments

    # Print with p, puts, print
    p 1 , 2, :three # ⇒ 1, 2, :three

    # Like PHP and Perl, “heredoc” quotes long strings: Left quote is <<XYZ and right
    # quote is XYZ, where XYZ is any sequence of characters. Use <<'XYZ' for the text
    # to not be interpolated.
    b = <<XXX
    hello
    XXX
    c = <<'abc'
    ddd hello
    abc


<a id="org0e4d23a"></a>

## “Ruby is Pure OO” &#x2013; 99% true!?

In pure OO, such as Smalltalk, conditional constructs are not part of the language
but are instead merely defined behaviour for the Boolean class. That is, one sends
a message to a Boolean object on how to proceed, rather than taking action by inspecting it.

-   Smalltalk syntax: b ifTrue: [ ⋯ ] .
-   Ruby syntax: if b then ⋯ end

Looking at, for example, true.methods does not seem that a conditional operation
is defined for the Boolean class.

Likewise for loops, and chains of and's and or's.

How can control flow be construed as message passing in Ruby?
&#x2014;Without adding it ‘after the fact’ with something like this:

    class TrueClass
      def ifTrue; yield; end
    end

    class FalseClass
      def ifTrue; self; end
    end

    puts ((1 == 0 + 1).ifTrue do "hi" end) # ⇒ "hi". Need parens for some reason; why!?
    puts  (1 == 0).ifTrue do "hi" end      # ⇒ "false"

    hi
    false
    false

( Incidentally, how do I get at the Boolean expressions themselves?
  How can I obtain, say 1 `= 0, in the second example above and for example
  print it as “1 =` 0” rather than “false”. Moreover, “1 `= 0” is really “1.send(:`, 0)”,
  so how can I get access to the object 1, the method ==, and the other argument, 0?
)

I'm nearly a week new into Ruby; thanks for being patient.

<https://www.reddit.com/r/ruby/comments/cz2v9t/ruby_is_pure_oo_99_true/>


<a id="org8df41cb"></a>

## η rule

In mathematics, the “η-rule”, a form of extensionality, says
\[
   (λ x → f x)  ≈  f
\]
In almost this form, this rule holds for Haskell and Lisp. ****How does this rule hold for Ruby?****

With the help of some code, see below, I have arrived at this rule:

`h do |e| g e end ≈ h(&method(:g))`

Provided `h` takes an explicit block and `g` is defined using `def`.
If `g` is defined using `lambda`, then rhs is `h(&g)`.

Below is some code to back this up.
However, **can this rule be stated more tersely?** My observation does not
account for the case `h` takes an implicit block. How is that treated?

    def go; "Hello" end
    go′ = lambda { "Hola" }
    def go¹ (x) "Hey, #{x}" end
    go′¹ = lambda {|x| "Yo, #{x}"}

    def explicit (&blk) blk.call end
    explicit do go end     # ⇒ Hello
    explicit(&method(:go)) # ⇒ Hello
    explicit(&go′)         # ⇒ Hola′
    #
    # “&:” not uniform?
    explicit(&:go) rescue "crashes"
    explicit(&:go′) rescue "crashes"
    [1,2,3].map(&:to_s)    # ⇒ ["1", "2", "3"]

    def explicit¹ (&blk) blk.call(1) end
    explicit¹ do |x| x.to_s end # ⇒ "1"
    explicit¹(&:to_s)           # ⇒ "1"
    explicit¹(&method(:go¹))    # ⇒ "Hey, 1"
    explicit¹(&:go¹) rescue "crashes"
    explicit¹(&:go′¹) rescue "crashes"
    explicit¹(&go′¹) # ⇒ "Yo, 1"

    def implicit; yield end
    implicit do go end # ⇒ Hello
    # implicit (&method(:go)) ⇒ Syntax error!

    def implicit¹; yield(1) end
    implicit¹ do |x| go¹ x end   # ⇒ "Hey, 1"
    # implicit¹ (&method(:go¹))  # ⇒ Syntax error

I'm nearly a week new into Ruby; thanks for being patient.

<https://www.reddit.com/r/ruby/comments/cz2msl/etaconversion_in_ruby_what_do/>


<a id="orga69a3f5"></a>

# Reads

-   [Ruby Monk](https://rubymonk.com/) &#x2014; Interactive, in browser, tutorials
-   [Ruby Meta-tutorial &#x2014; ruby-lang.org](https://www.ruby-lang.org/en/documentation/)
-   [The Odin Project](https://www.theodinproject.com/courses/ruby-programming)
-   [Learn Ruby in ~30 minutes](https://learnxinyminutes.com/docs/ruby/) &#x2014; <https://learnxinyminutes.com/>
-   [contracts.ruby &#x2014; Making assertions about your code](http://egonschiele.github.io/contracts.ruby/)
-   [Algebraic Data Types for Ruby](https://github.com/txus/adts)
-   [Community-driven Ruby Coding Style Guide](https://github.com/rubocop-hq/ruby-style-guide)
-   [Programming Ruby: The Pragmatic Programmer's Guide](http://ruby-doc.com/docs/ProgrammingRuby/)
-   [Learn Ruby in One Video &#x2013; Derek Banas' Languages Series](https://www.youtube.com/watch?v=Dji9ALCgfpM)
-   [Learn Ruby Using Zen Koans](http://rubykoans.com/)
-   [Metaprogramming in Ruby](https://thecodeboss.dev/2015/09/metaprogramming-in-ruby-part-2/) &#x2014;also some useful [snippets](https://gist.github.com/Integralist/a29212a8eb10bc8154b7#file-0-ruby-meta-programming-spells-covered-md)
-   [Seven Languages in Seven Weeks](http://shop.oreilly.com/product/9781934356593.do)

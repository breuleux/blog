
template :: default

meta ::
  id = breuleux-blog-18
  title = O-expressions
  tagline = An alternative to s-expressions for extensible syntax
  author = Olivier Breuleux
  date = 2014/01/16
  language = English
  category = Programming
  tags =
    * O-Expressions
    * S-expressions
    * Programming Languages
  comments = true
  list = true

__[Why do people like Lisp?] I mean, it looks weird, doesn't it? Countless
backronyms were designed to mock its syntax: "Lost In a Sea of
Parentheses", "Lots of Irritating Superfluous Parentheses" and other
jabs at the very large amounts of brackets found in typical
programs. It is one of the rare languages where "\)\)\)\)\)" is a
commonplace sight and also one of the rare languages to eschew the
infix arithmetic we have known and loved since grade school.

And yet, it endures. Lisp and its variants have been around for many
decades and are still actively maintained and extended. Its syntax
(s-expressions) has even seen a renaissance of sorts recently, with
new languages such as Clojure.

What's great about Lisp isn't really the way it looks: aesthetically,
it looks terrible to almost everyone. It is also not the tersest of
languages. No, what's great about Lisp is that idea that "code is
data". I mean, it always is, really: nearly all programming languages
transform plain text into some kind of abstract syntax tree
(AST). However, if you want to _extend a language, if you want to
adapt it to your needs or try a new paradigm, you're going to give it
some kind of surface syntax, and you're going to need to manipulate
code as a data structure. And that's where Lisp shines.

Some people would say that a good programming language shouldn't _need
to be extended, but that's wishful thinking: no one can think of all
the things people might want to do, and there are no general
principles that can optimize all use cases. There are many reasons to
want to extend a language:

* Eliminate boilerplate.
* Specialize code to fit a particular application domain, e.g. string
  manipulation or state machines.
* If you find yourself missing features from other languages, you can
  add them.

If you were to design a language to make it as extensible as possible,
you would see that many factors constrain your design:

# __[Work with AST, not grammar]: if extending the parser is possible,
  sure, the programmer can do what they want, but they'll have to
  learn how to write grammar rules and deal with syntax, even though
  what they really care about are the semantics. So it is not ideal:
  it would be better if they could work from the AST directly.

# __Simplicity: if the data structures are too complex, they will have
  a hard time committing them to memory and they will be less
  motivated to write extensions. So the data structures should be as
  simple as possible.

# __Homoiconicity: if the connection between surface syntax and the
  data structures is not clear, then they will struggle to figure out
  where their extension is going to fit.

# __Genericity: finally, if extensions stand out from the rest of the
  language like a sore thumb, people are unlikely to use them. It's
  just a matter of visual coherency: the language's own structures are
  first class and unless extensions can be made to look just like
  them, they will _feel second class.

Lisp does not promote the use of parser extensions: you work on the
AST. ASTs are nested lists -- you couldn't do simpler if you
tried. The translation from source code to AST is completely obvious:
`(x y z) is a list with the three elements `x, `y and `z. All of the
language's constructs are defined by the first atom of a list, and so
are all extensions. Nothing stands out. Lisp follows these
instructions to a tee. The only cost to pay is lots of parentheses.

Plenty of people are comfortable with paying that price. Nonetheless,
even more are put off by it -- it is arguably the main reason why use
of these languages is not more widespread. Besides subjective
aesthetic preference, there are a few issues with s-expressions -- the
kind of issues that aficionados will gloss over because they are
somewhat minor, but...

* The syntax might be a little _too simple. This leads to some
  semantic conflation, for instance in cases like
  `(lambda (f g) (f g)): the same subexpression `(f g) is
  found twice, but with starkly different semantics each time.

  Languages based on s-expressions tend to erase the distinction
  between function/macro calls (where the first element of the list is
  special) and actual lists of things (where it isn't).

* There are incentives to save punctuation by collapsing
  nesting. Clojure does this: in order to bind two variables `x and
  `y, one would write something like `(let [x 0 y 1] ...). The
  structure is implicit: the variable names are at odd positions and
  their values at even positions. Keyword arguments in most Lisp
  dialects are also implicitly structured. This is cheating: there may
  too many parentheses to bear... but that's not an excuse to wipe out
  _structure.

This suggests that s-expressions might not be the end-all of
extensibility: there is a lot of opportunity in designing extensible
syntax that "looks" better and could gain wider adoption as a result.



= Difficulties

Of course, if improving on s-expressions was easy, it would have been
done already. The issue is that it is very difficult to improve on
Lisp's syntax without increasing the complexity of extending the
language or crippling the kind of extensions that are possible to
do. Of course, I don't think it is _impossible. But it is very hard
and it is very easy for language designers to fall into all sorts of
traps: they know every detail of the language they made, so they are
going to underestimate its complexity (me included, probably).

To expound on the difficulty, let's list things that __won't fly:

* __[Template-based macros]: they are certainly better than no macros,
  but they are not very flexible. If I want to dive in there and
  shuffle the structure of the code, I won't know how to do it, if
  it's even possible.

* __[Hard-coded syntax]: sure, `if is ubiquitous, and `for loops are
  great, but as soon as you introduce keywords, you create first class
  structures that all extensions have to compete with or work
  around. You can't provide them "for convenience's sake": if the
  general syntax isn't appropriate for these basic features, how
  should you expect it to suffice for extensions?

* __[Context-sensitive syntax]: notice how the proper parenthesization
  of Python code changes depending on context:

  &
    
      x, y = z          ==>  (x, y) = z           (tuple assignment)
    f(x, y = z)         ==> f(x, (y = z))         (function call)

  &
    
        x, y in z       ==>      x, (y in z)      (tuple)
    for x, y in z: ...  ==> for (x, y) in z: ...  (for loop)

  See what I mean? The priority of the comma relative to the equal
  sign or the `in operator varies depending on the context. While I
  won't dispute that it is nice sugar, it's not possible to translate
  this to a _simple AST. Every control structure is going to work by
  different rules and it's going to be a huge mess.

Conversely, here are the language properties the language __should
have:

# __[Uniform behavior]: all tokens should behave the same
  syntactically in all situations. If you have, say, `{x} over here
  and `{x} over there, they should produce the same AST at both
  places. If you have `[a, b in c], I don't care what the context is:
  same AST. That way you have to think about syntax a lot less.

# __[Rule ubiquity]: if I was to pick some moderately sized source
  file at random \-\- big enough not to be trivial, but small enough
  that I can go through it in 15 minutes or so \-\- it should exhibit
  _all the syntax rules I need to know. If I know the AST of some
  random source file, I should be able to work out the AST of every
  source file. [br %]
  In short, it should be virtually impossible to write any code base
  of significant size without using all the syntax available. This
  rule ensures that the syntax will be learned _quickly and
  _completely by all users of the language.

Lisp obviously satifies both criteria, but you will note that it does
in the strictest way imaginable and that there is some exploitable
leeway. Rule 2 has the most restrictive implications:

* You can't have syntax catered to use cases that are too
  specific. For instance, special syntax that makes shell scripting
  easier means people won't fully know the language until they look at
  some shell scripts.

* If there is syntactic sugar at all, it should be indispensable. For
  instance, if we had a rule that saved us from typing a single
  character in some situations, a lot of people would make it a habit
  to type it anyway (it's just one character, after all). If we read
  their code, we wouldn't know about the rule. And that's why we can't
  have it.

* Provided that people may replace existing built-ins by their own
  versions, or use abstractions that are equivalent to the built-ins,
  all language constructs should be based off the same core syntax.

All we need to do now is figure out just how far we can go before
these rules are bent or broken.



= Infix operators

Let's start with something that is sorely missing in Lisp: infix
operators. People like them, and we aim to please. We have to be
parsimonious in what we add, though, so the first question we should
ask ourselves is are they common _enough?

Personally, I would think so. First, pretty much everyone knows what
operators are, so familiarity is the norm. Sure, some may be confused
about BEDMAS, but everybody knows what `[2 + 2] is supposed to
mean. Second, there are many common use cases outside of standard
arithmetic: declaration, assignment, anonymous functions, key/value
mappings, typing, concatenation, etc. We can reasonably assume that
everybody who learns the language will run across infix syntax
eventually.

As for what constitutes an operator and what doesn't, we can devise
simple enough rules. For instance, perhaps we can have a set of
"operator characters", any sequence of which defines an operator. This
creates an unbounded number of operators for extension purposes.

So we have some tokens that are identifiers and some other tokens that
are operators. That's a good start, but what happens when we combine
them?


== Iteration 1

Let's start with a few very simple rules loosely inspired from
s-expressions (but not necessarily _based on s-expressions).

# Juxtaposition using whitespace is application of a function to
  arguments. `[f x y] applies `f to `x and `y. `f may be a function or
  a macro.
  * As a special case, `[f.] applies `f to no arguments.

# `[a <op> b <op> c] applies `[<op>] to `a, `b and `c. It is like
  `[(<op>) a b c].

# Juxtaposition has higher priority than any operator.

# `(...) groups things together. It has _[no presence] in the syntax
  tree, so extra pairs of parentheses will not change the AST.

# Mixing different operators together is not allowed.

This is not too bad; if we were to give to the `[=] operator the
semantics of `define and the semantics of `lambda to the `[->]
operator, you'd end up with code like this:

&
  diag = (x y -> (((x * x) + (y * y)) ^ 0.5))
  if (diag 3 4 == 5) (print "hello") (print "world")

Still looks a lot like s-expressions, though. Very parenthesey.


== Iteration 2

One way to make the code terser would be to add some priority
relationships. You'd be removing some punctuation without adding any
back; but you have to be careful, because a priority graph is one more
thing for users to learn. The ubiquity rule is a good guide here: the
priority graph can only involve commonplace operators.

Of course, this would create a "first class" of operators: the ones in
the graph. All the others would be "second class" and that is less
than ideal. This being said, operators are a lot more versatile than,
say, control structures. Furthermore, allowing users to define
priority for custom operators is a lot easier and much less disruptive
than letting them add general parsing rules.

For the default priority graph, it would be reasonable to have the
usual order of operations for arithmetic because it is common
knowledge. Declarations and anonymous functions can be low priority
right-associative operators, because that makes sense. We just need to
make sure only to define the bare minimum that lets us remove 90% of
parentheses.

&
  diag = x y -> (x * x + y * y) ^ 0.5
  if (diag 3 4 == 5) (print "hello") (print "world")

Figuring out the structure is harder than for s-expressions but it is
not a _lot harder: once you wrap your mind around the (hopefully very
simple) priority graph and understand that the context is always
irrelevant, you can work out the AST of any expression or
sub-expression.


== Iteration 3

There is still the question of what to do with newlines: if they were
equivalent to spaces, we'd have to parenthesize pretty much every
line. That's not what we signed up for. But if each line was
automatically wrapped in `()s, we'd have another problem: breaking up
`[if test a b] on more than one line in a _natural way would be
impossible unless you parenthesized the whole thing. Significant
indent is an attractive solution, but we don't really want to make
that a cornerstone of the syntax.

However, `[if test a b] could be _structured differently. For
instance, it could be `[if test (a b)] and then we could write this:

&
  if test (
    a
    b
  )

Unfortunately there is no difference between `[if test (a b)] and `[if
test ((a b))], so how exactly do we tell apart the use case where we
want to execute the single statement `(a b) from the one where we want
to execute `a, and then `b?

It is at this point that we might want to enforce the syntactic
distinction I mentioned earlier, which languages based on
s-expressions erase: the distinction between applications and lists of
things. It's a pretty ubiquitous distinction: virtually all programs
contain some function applications and some lists of things or
statements.

ol %
  start = 6
  li %
    `(a, b, ...) defines a sequence; in normal situations, it returns
    the value of the last expression. The comma has lowest priority.

&
  if test (
    a,
    b
  )

This is unambiguous, and since the comma now acts as a statement
separator, line breaks can be normal whitespace. Alternatively, you
could define line breaks to be equivalent to commas and indented
blocks to be equivalent to parenthesized blocks.

&
  diag = x y -> (x * x + y * y) ^ 0.5
  if (diag 3 4 == 5) (print "hello", print "world")

We've reached a point where the syntax is definitely viable. The only
real wart is nullary application (`[x.] to apply `x to no
arguments). Depending on your semantics that may not be a big deal: in
a pure language like Haskell, for instance, there is no such thing as
nullary application.


== Iteration 4

There is one way to eliminate the "wart" and make the syntax
conceptually cleaner: reinterpret juxtaposition to be _currying and
add syntax for actual lists (that returns the list rather than the
last element).

# (Amended) juxtaposition using whitespace is a
  _[left-associative operator]: `[f x y]
  applies `f to `x, then applies the result to `y.

div % ol %
  start = 7
  li % `[[a, b, ...]] defines a list.

Then we can make the definition of `diag currying:

&
  diag = x -> y -> (x * x + y * y) ^ 0.5
  if (diag 3 4 == 5) (print "hello", print "world")

Or we can define it on a list of two arguments:

&
  diag = [x, y] -> (x * x + y * y) ^ 0.5
  if (diag[3, 4] == 5) (print "hello", print "world")

See how that works? In a similar vein, a function that takes no
arguments would be called like `[f[]].

At a glance it feels like we may have reinvented M-expressions, but we
did not: a function taking a single argument would correspond to the
M-expression `f[x], but with our solution so far, it could be `f[x],
or it could also be `[f x]. A function taking two arguments would be
the M-expression `f[x; y], but here we can have `f[x, y] or `[f x
y]. Basically, there is no requirement for functions to take _lists of
arguments. This is why unlike m-expressions, this syntax can't be
directly translated to s-expressions. For instance, what's the
s-expression for [`f[x, y]]? [`(f x y)]? But then what's the
s-expression for [`f(x[y])]? [`(f x y)] again?

That's also why I did not bother changing `if: I mean, sure, we could
define it like `[if[test, body, ...]], but that would look terrible,
and we don't _have to do it. We can just think of it as a kind of
currying macro where `[if test] returns a macro that processes a
body. Why not? (Okay, there is a good reason why not; I'll explain
later).


== Draft

Ideally, operators should be translated in terms of juxtaposition,
since they are function or macro calls. `[a <op> b] could either be
`[(<op>) a b] or `[(<op>)[a, b]]. The former is handy for things like
partial application, whereas the latter is more consistent with the
idea that operators may take a variable number number of arguments. It
depends on the semantics you are shooting for.

Either way we can write a generic draft for our syntax:

# __Classification: given a set of "operator characters", tokens made
  from characters of that set are operators and others are identifiers
  or literals.

# __Juxtaposition: left-associative operator. `[f x] applies the
  function `f to the value `x. It produces the AST node `[Apply[f,
  x]].

# __Operators: `[a <op> b] is sugar for `[(<op>) a b], or `[(<op>)[a, b]].

# __Lists: `[[a, b, ...]] creates the AST node `[List[a, b, ...]].

# __Sequencing: `[a, b, ...] creates the AST node `[Seq[a, b, ...]].

# __Grouping: `(...) ensures that the enclosed expression corresponds
  to a single node in the AST. However, it does not show up in the
  AST.

# __Priority: from higher to lower priority, we have
  `[juxt -> op -> comma -> brackets]. For priority relations between
  operators, a priority graph is provided (or not).

I dub these expressions __o-expressions (operator expressions).

With only three internal node types, the AST is rather simple. We
could actually make it even simpler by removing `Seq nodes and using
`List nodes instead (I think `Seq is worth it, though: `[Seq[expr]]
being semantically equivalent to `expr in all situations makes it a
better candidate for the body of a function or control structure,
whereas using `List would make it awkward to return lists).

Is this AST more complex than s-expressions? I'm not sure. `Apply[f,
List[x, y]] is the equivalent of the s-expression `(f x y), but
s-expressions are rigged in such a way that every `List node is always
the second argument of some `Apply node. If that's the case, then you
can just reduce both to a single datatype, but it's a bit disingenuous
to claim that this makes things simpler: the point of having two types
of nodes is that you can decouple them.

For instance, decoupling means that you don't need an `apply function
any more. `Apply[f, Apply[g, List[x]]] has no equivalent s-expression
because erasing node type means that you cannot hope to distinguish it
from `Apply[f, List[g, x]]. To get the same semantics you must write
`(apply f (g x)). That's not very elegant.



= Solving technical issues

There is still one outstanding issue: AST manipulation.

& while (x < 0) (x += 1)

That looks nice enough and it will work. Unfortunately, juxtaposition
_is left-associative, which means we get the following AST:

& Apply[Apply[while, (x < 0)], (x += 1)]

Surely you can see the problem: the "important token", `while, is not
accessible. You have to _dig for it. The idea of currying macros might
not be entirely devoid of sense, but as far as AST manipulation goes,
this is a big no-no.

Unfortunately, `while[test, x < 0, x += 1] looks terrible. So what do
we do?

One option would be to use an operator as syntactic sugar. For
instance:

& while (x < 0): (x += 1)  ==>  while[x < 0, x += 1]

Every bit of sugar we add is a disadvantage versus s-expressions, so
this is not thrilling, but nothing's perfect.


== Aggregative operators

Here's another idea, though.

Imagine that instead of figuring out operator priority between random
operators, we simply "aggregated" them together, concatenating all
their names:

& x <op1> y <op2> z    ==>    (<op1>_<op2>)[x, y, z]

Not only is this conceptually simple, it opens up a massive range of
ternary, quaternary and what-have-you operators. Suppose that we
define a set of operator tokens that contain identifiers, so that they
don't look like confusing garbage characters. For instance, perhaps we
could interpret `[@word] as an operator. If we do this we can get
interesting mileage out of _existing rules:

&
  @while (x < 0): (x += 1)        ==> (@while_:)[x < 0, x += 1]

The potential for extensibility is massive.

&
  @if (x < 0) @then "-" @else "+" ==> (@if_@then_@else)[x < 0, "-", "+"]
  @for x <- xs: print[x]          ==> (@for_<-_:)[x, xs, print[x]]

The method has several advantages:

* Readable, thanks to the operators visually splitting the parts.
* Easy to define: every combination has a name.
* Puts macros in their own kind of "namespace", freeing up a lot of
  names for casual use.
* Syntax highlighting is trivial.
* No new sugar.

It might not be a good idea to aggregate _all operators, since this
would lead to loads of spurious definitions for all sorts of common
combinations. For instance, I probably wouldn't actually aggregate
`[@for] and `[<-] in the previous example. Once these kinks are worked
out, though, I think the idea has a lot of potential.


= Conclusion

I haven't finalized a syntax in this essay but I think I've expounded
the aspects and properties that it must have in order to be truly
extensible. To summarize:

* Context invariance: all tokens must have the same syntactic role
  everywhere.

* Ubiquity: as much as possible, all syntactic concepts must be
  present in all source files.

* Genericity: standard constructs and user-defined constructs should
  be indistinguishable.

* AST simplicity and manipulability: the AST has to be very simple and
  easy to manipulate programmatically.

As I mentioned, it's not really possible to do better than
s-expressions on any of these points. Only data formats like XML or
JSON could be said to have similar homoiconic properties, but they are
completely unusable to define programs. Much like Lisp requires a
sacrifice in the form of parentheses, its alternatives require a
sacrifice in how directly the structure of source code can be
visualized.

O-expressions attempt to reduce the amount of punctuation by
leveraging operators and introducing a distinction between application
nodes and list nodes. This adds what I consider to be a small amount
of complexity. Which tradeoff is "better" is a subjective matter, but
I believe that most people would prefer working with o-expressions.

There are a few advantages of o-expressions that I think are difficult
to argue:

* O-expressions encode `apply directly. They are based on
  it. S-expressions cannot do this.

* In the same vein, by design, s-expressions force all functions to
  apply on lists. O-expressions do not have that restriction.

* O-expressions provide less incentives to collapse nesting. For
  instance, `let syntax could easily be:

  & @let (x = 1, y = 2): x + y

  The resulting structure is very similar to standard `let syntax, but
  it looks good and doesn't suffer from the same parenthesis overload,
  so you won't be tempted to take shortcuts.

I have written an implementation of o-expressions for Racket. That
implementation translates o-expressions into s-expressions in such a
way to keep maximal compatibility. The resulting syntax is a bit more
complex than pure o-expressions would be if they were the basis of a
new language, but that's always to be expected when shoehorning a
system into another. You can read about it here@@@liso.html.


store nav ::
  div.seealso %
    * [Liso @@@ liso.html], an alternative syntax
      for Racket based on oexprs.
    * [Earl Grey @@ http://breuleux.github.io/earl-grey/],
      a compile-to-JS language based on oexprs.


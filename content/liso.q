
meta ::
  template = default
  id = 19
  title = LISO
  tagline = An operator-based syntax for Racket programs
  author = Olivier Breuleux
  date = 2014/01/25
  language = English
  category = Programming
  tags = {O-Expressions, S-expressions, Liso, Programming Languages}
  comments = true
  list = true
  include =
    /lib/jspm_packages/system.js
    /lib/config.js


css ::
  .prio img {
    width: 700px;
    padding: 10px;
    border: 1px solid #aaa;
  }


= O-expressions

I have been working on a particular kind of syntax that I call
o-expressions. They are nearly as regular as s-expressions while
looking much more similar to popular languages. The source is
here@@{source}.

* All tokens are split into two categories: "operator" and "not an
  operator". This depends only on the token and not on context.

* All tokens have the same syntactic properties regardless of where
  they are located.

* Juxtaposition is a left associative operator that means `apply
  (works like in Haskell, basically).

* It is an operator precedence syntax. All you need to parse it is a
  precedence table.
  * The operator precedence graph is static and cannot be customized:
    custom operators are allowed, but they all behave the same.

Now, the idea is this: by picking the set of special operators
carefully enough, you can create syntax which is almost as generic as
s-expressions, while requiring significantly less parentheses and
containing a lot more visual hints.

As general guidelines, the priority graph should be:

# __Simple: there shouldn't be so many operators that it's impossible
  to memorize all of them.

# __Parsimonious: if it's not intuitively clear what the mutual
  priority of two operators should be, then it should be a syntax
  error to mix them.

# __Ubiquitous: every code base of a reasonable size should be
  expected to contain all the operators in the graph at least once.

These guidelines do not forbid custom operators. What they _do say is
that all custom operators should behave the same, that you shouldn't
mix them together (because it's not clear what that means), and that
the _[sine qua non] condition to place an operator outside the "Other"
category is that it should be so common that you can't ignore its
existence.


= Adapting to s-expressions

Liso is an implementation of O-expressions (written in Racket) that
compiles to s-expressions.

It looks like that:

div.sidebyside %
  liso &
    @varsrec
          odd?[n] =
             @if n == 0:
                #f
                even?[n - 1]
          even?[n] =
             @if n == 0:
                #t
                odd?[n - 1]:
       even?[30]
  scheme &
    (varsrec
        (begin (= (odd? n)
                  (if (== n 0)
                      #f
                      (even? (- n 1))))
               (= (even? n)
                  (if (== n 0)
                      #t
                      (odd? (- n 1)))))
      (even? 30))

Liso on the left, equivalent s-expression on the right.


== Translation rules

div.cmptable0 %
  + Rule + O-expression + S-expression
  | __Operator | `[x <operator> y] | `(<operator> x y)
  | | `[x <op> y <op> z] | `(<op> x y z)
  | | `[x <op1> y <op2> z] | `(<op1>_<op2> x y z) (op1 != op2)
  | | `[x `op` y] | `(op x y)
  | __Apply | `[x y] | `(apply x y)
  | | `[x y z] | `(apply (apply x y) z)
  | __List | `[[]] | `(list)
  | | `[[x]] | `(list x)
  | | `[[x, ...]] | `(list x ...)
  | __Apply+List | `x[y, ...] | `(x y ...)
  | __Group | `{} | `(begin)
  | | `{x} | `x
  | | `{x, y, ...} | `(begin x y ...)
  | __Arrow | `[x => y] | `(x y)
  | __Control | `[@K : x] | `(K x)
  | | `[@K x : y] | `(K x y)
  | | `[@K x, y : {z, w}] | `(K (begin x y) z w)
  | __Sexp | `(...) | `(...)

In addition to these, the indent and line break rules are:

# __Indent: Every single indented block is equivalent to wrapping it
  in [`{}]s. That is to say, `[INDENT == \{] and `[DEDENT == \}].

# __[Line break]: There is an implicit comma after every single
  line. That is to say, `[NEWLINE == ,]

That's it. Note the following:

* S-expressions are still valid: round parentheses enter and exit
  s-expression processing mode. Inside s-expressions, you can use
  `{...} to switch back to infix syntax (`[[...]] won't work).

* At least one kind of expression, `(apply f args), is made
  _significantly shorter, since it can now be written `[f args] or
  `f{args}.

* The Apply+List rule is partly redundant: without that rule, `x[y]
  would reduce to `(apply x (list y)) which you will note is
  semantically equivalent to `(x y) most of the time. It is not
  syntactically equivalent, however, hence the need for a rule.

* The role of priority disambiguation is given to curly braces. Thus
  the s-expression `(* (+ a b) c) would have to be written
  `[{a + b} * c]~.


The rule __Arrow is a convenience rule that builds a pairing of the
form `(x y). Such pairings are ubiquitous in `let forms, but also in
`cond, `case, `match, etc. The rule saves us from redefining most of
these control structures.


= Definition of operator

One very simple rule: if a token starts and ends with an operator
character, it is an operator. Otherwise, it is an identifier (or a
literal):

* __Literal: `[1 1.4 4/3 "string" 'character']
* __Identifiers: `[x abc z123 call/cc let* 1+ ^xyz]
* __Operators
  * __Infix: `[+ - **% ^xyz^ /potato/ <yay> *a/b&c% NEWLINE]
  * __Prefix: `[. ^ ( \[ { INDENT @keyword]
  * __Suffix: `[) \] \} DEDENT]

There are a few special cases: `[.] and `[^] correspond to `quasiquote
and `unquote, so they are prefix, and I will explain `[@keyword]
later.


= Priority graph

div.prio %
  @@@ image:liso_priority

(`I and `D mean indent and dedent respectively, i.e. the start and end
of an indented block)

If you can follow the arrows from an operator to another, it means the
first has priority over the second. If there is no path from either to
the other, then they can't be mixed. For instance:

liso &
  a b c d       ==> (juxt (juxt (juxt a b) c) d)
  a + b * c     ==> (+ a (* b c))
  a b + c       ==> (+ (juxt a b) c)
  a +++ b = c   ==> (= (+++ a b) c)
  a +++ b + c   ==> error

"Aggregative" operators are merged into a single expression:

liso &
  a && b && c       ==> ((&& &&) a b c)
  a > b >= c == d   ==> ((> >= ==) a b c d)
  a `b` c `d` e     ==> ((b d) a c e)
  @while x: y       ==> ((while :) x y)


= Control structures

The rule __Control caters to the following general use case: "you have
a control structure, the first argument is special, sets things up,
etc.  and then you have a body or some arbitrary number of
clauses". Virtually all common control structures in Racket fall in
that category: `let, `lambda, `when, `for, `match, `define,
etc. Others, like `cond, `case, `require, `provide have no special
argument, but that's even easier to deal with.

Long story short, if we can devise a nice syntax that takes care of
this _[in general], we're not really going to need anything
else. Furthermore, the syntax can serve as a formatting hint to
editors, sparing us the trouble of configuring the layout of special
macros.

I'm still not _entirely sure what syntax to use here, but just now
I've converged to this one:

div.sidebyside %
  liso &
    @name foo, bar, ...:
       humpty
       dumpty
       ...
  scheme &
    (name (begin foo bar) humpty dumpty)

It looks fairly good in general:

liso &
  @define pr[x]:
     display[x]
     newline[]

  @when x > 0:
     pr["positive"]

  @let x = 1, y = 2: x + y

  @let* x = 1
        y = x:
     x + y

  @match [1, 2, 3]:
     [a] => 1
     [a, b] => 2
     [a, b, c] => 3
     [a, b, c, d] => 4

  @provide:
     myfunc
     @except-out all-from-out[racket]:
        let, let*, letrec, lambda
     @rename-out:
        mylet => let
        mylet* => let*
        myletrec => letrec
        mylambda => lambda


I've considered a few other options. Keep in mind, though, that I am
aiming for a _general syntax: `when is _not a keyword. This limits
options.

Another limitation is that the syntactic role of a token cannot vary
from a context to another. For instance, in Python, the relative
priority of the comma and the `[=] operator varies: `[a, b = c]
(assignment to tuple) versus `f(a, b = c) (function arguments). Its
priority relative to `in also changes depending on whether we're in
list comprehension context or not. These variations are not acceptable
here.


== Variant

Alternatively control structures could be made to look like this:

earlgrey &
  define pr[x]:
     display[x]
     newline[]

  when {x > 0}:
     pr["positive"]

  let {x = 1, y = 2}: x + y

  provide:
     myfunc

(That was actually my original solution)

The downside is that any expression involving operators needs to be
wrapped in brackets. It may also be a bit easier to mess up, since
with `[@name ... :], omitting one of the parts is equivalent to a
bracket mismatch.


= Changes from Scheme

There are some problems with the translation a few existing control
structures. Let's take `lambda for instance. In a nutshell, there are
two ways to write it in Liso:

div.sidebyside %
  liso &
    ;; Using the syntax for (x y z)
    @lambda x[y, z]:
       ...

    ;; Using s-expressions directly
    @lambda (x y z):
       ...
  scheme &
    ;; Original
    (lambda (x y z)
      ...)

The first way is a bit _odd, because `x stands out from the other
arguments. The second way falls back to s-expressions, which we'd
rather not do. We'd prefer to have something like this:

liso &
  @lambda x, y, z:
     ...

  ;; or this
  @lambda [x, y, z]:
     ...

Now, we could easily redefine `lambda to work like that. The only
issue is that it won't be the original `lambda any more.

At the core of the problem is the fact that the first element of an
s-expression can be special (a function, a keyword, etc.) or not
special (just the first element of some list). However, languages
based on s-expressions offer absolutely no syntactic clue as to which
one may be the case. That's why you can have code like
`(lambda (f g) (f g)), where the same subexpression `(f g) is found
twice, but with starkly different semantics each time.

O-expressions, on the other hand, correspond to s-expressions where
the first element is always special: it's a function, or an operator,
or some keyword like `begin or `list. All things considered, I would
say that it is a saner policy than s-expressions, but when translating
to the latter, it causes some friction.

I redefined a few existing macros under new names. I also took the
opportunity to alias a few others to operators.

.cmptable0 %
  + Liso + Scheme
  | liso`[@vars a = 1, b = 2: ...] | scheme`(let ((a 1) (b 2)) ...)
  | liso`[@vars* a = 1, b = 2: ...] | scheme`(let* ((a 1) (b 2)) ...)
  | liso`[@varsrec a = 1, b = 2: ...] | scheme`(letrec ((a 1) (b 2)) ...)
  | liso`[[x, y, z] -> ...] | scheme`(lambda (x y z) ...)
  | liso`[f[x] = ...] | scheme`(define (f x) ...)
  | liso`[x := v] | scheme`(set! x v)
  | liso`[x :: xs] | scheme`(cons x xs)
  | liso`[x ++ y] | scheme`(string-append x y)
  | liso`[x ** y] | scheme`(expt x y)
  | liso`[x || y] | scheme`(or x y)
  | liso`[x && y] | scheme`(and x y)
  | liso`[! x] | scheme`(not x)



= Examples

Each example shows side by side the Liso code and the Scheme code that
it is directly translated to. This is sometimes slightly unfair, since
the translation can be longer than idiomatic Scheme code would
otherwise be. You can judge for yourself.

First we have the canonically terrible recursive implementation of
fibonacci numbers:

div.sidebyside %
  liso &
    fib[n] =
       @if n <= 1:
          n
          fib[n - 1] + fib[n - 2]

    fib[30]
  scheme &
    (= (fib n)
       (if (<= n 1)
           n
           (+ (fib (- n 1))
              (fib (- n 2)))))

    (fib 30)

In the second example I implement a function that filters all the
elements of a list that match some predicate. Then I get the minimum
positive element of a list by exploiting the fact that juxtaposition
is `apply. The `match construct used here is the one that comes
standard with Racket. It is unmodified.

;;
 div.sidebyside %
  liso &
    filt[?, xs] =
      @if null?[xs]:
        []
        @vars x = car[xs]
              rest = filt[?, cdr[xs]]:
          @if ? x:
            x :: rest
            rest

    results = filt[[x] -> x > 0
                   [0, 1, -2, -3, 4]]
    min results
  scheme &
    (= (filt ? xs)
       (if (null? xs)
         (list)
         (vars
            (begin
             (= x (car xs))
             (= rest (filt ? (cdr xs))))
           (if (? x)
               (:: x rest)
               rest))))

     (= results
        (filt (-> (list x) (> x 0))
              (list 0 1 -2 -3 4)))
     (apply min results)


div.sidebyside %
  liso &
    filt[?, xs] =
       @match xs:
          [] => []
          [x, rest, ...] =>
             tail = filt[?, rest]
             @if ? x:
                x :: tail
                tail

    results = filt[[x] -> x > 0
                   [0, 1, -2, -3, 4]]
    min results
  scheme &
    (= (filt ? xs)
       (match xs
         ((list) (list))
         ((list x rest ...)
          (begin
            (= tail (filt ? rest))
            (if (? x)
                (:: x tail)
                tail)))))

     (= results
        (filt (-> (list x) (> x 0))
              (list 0 1 -2 -3 4)))
     (apply min results)


Now for something a bit more interesting, I define a new
operator. There is no need to give it a priority or associativity,
because all priorities are set in stone at the beginning.

div.sidebyside %
  liso &
    >>> x =
       display[x]
       newline[]
    
    >>> "hello!"
  scheme &
    (= (>>> x)
       (begin
         (display x)
         (newline)))

    (>>> "hello!")

Exploiting operator aggregation:

liso &
  culprit <in> room <with> weapon =
     format[msg, culprit, room, weapon] $
        msg = "Mr. Boddy was killed by ~a in the ~a with the ~a"

  "Colonel Mustard" <in> "ball room" <with> "candlestick"
scheme &
  (= (<in>_<with> culprit room weapon)
     ($ (format msg culprit room weapon)
        (= msg "Mr. Boddy was killed by ~a in the ~a with the ~a")))

  (<in>_<with> "Colonel Mustard" "ball room" "candlestick"))

Cool, isn't it? But the coolest part of Scheme is the macros, so let's
see how well we fare there. What follows is a definition of a _swap
operator. It uses Racket's `define-syntax-rule unchanged.

div.sidebyside %
  liso &
    @define-syntax-rule x <=> y:
       @vars temp = x:
          x := y
          y := temp

    @vars a = 1, b = 2:
       a <=> b
  scheme &
    (define-syntax-rule (<=> x y)
      (vars (= temp x)
        (:= x y)
        (:= y temp)))

    (vars (begin (= a 1) (= b 2))
      (<=> a b))

Now for a more complex example, a `for control structure that loops
through ranges.

liso &
  @define-syntax for:
     @syntax-rules [list, begin]:

        for[{}, body, ...] =>
           {body, ...}

        for[{spec, rest, ...}, body, ...] =>
           for[spec, for[{rest, ...}, body, ...]]

        for[var = start <to> end <by> increment, body, ...] =>
           @vars loop[var = start]:
              @when var <= end:
                 body
                 ...
                 loop[var + increment]

        for[var = start <to> end, body, ...] =>
           for[var = start <to> end <by> 1, body, ...]
      
  @for x = 1 <to> 3
       y = 10 <to> 30 <by> 10:
     display[[x, y]]

scheme &
  (define-syntax for
    (syntax-rules (list list begin)

      ((for (begin) body ...)
       (begin body ...))

      ((for (begin spec rest ...) body ...)
       (for spec (for (begin rest ...) body ...)))

      ((for (= var (<to>_<by> start end increment)) body ...)
       (vars (loop (= var start))
        (when (<= var end)
              body
              ...
              (loop (+ var increment))))))

      ((for (= var (<to> start end)) body ...)
       (for (= var (<to>_<by> start end 1)) body ...))))

  (for (begin (= x (<to> 1 3))
              (= y (<to>_<by> 10 30 10)))
   (display (list x y)))


= Advantages

__ Versus Java and its ilk

Unlike Algol-type syntax, it adequately mirrors the strong points of
s-expressions:

  * The syntax is very general and can be adapted to a very wide
    variety of semantics.

  * It is regular: every token has the same syntactic properties
    regardless of where it is located.

  * It is homoiconic: from any expression, it is straightforward to
    figure out what the resulting AST is.

  * Writing macros and new constructs is easy: it requires neither
    parsing knowledge nor even pattern matching (though the latter is
    always nice to have).

  * New constructs integrate themselves seamlessly into the language.

__ Versus s-expressions

Unlike s-expressions, it adequately mirrors the strong points of
Algol-type syntax:

  * Visually, it is very similar to widely popular languages such as
    Python. This makes it more accessible.

  * There are less incentives to collapse nesting, because a wisely
    picked set of core operators can encode the necessary structure
    without "looking bad".

There is also an opportunity to "fit" extra semantics into `apply.
see here@@{point} for instance.


__ Other features

Liso also mirrors a few strong points of Haskell's syntax:

  * There is no need to provide an `apply function, because
    juxtaposition _is `apply. O-expressions naturally lend themselves
    to currying, though this might or might not be apparent depending
    on whether functions curry their arguments or take a tuple of
    them.

  * The syntax is more "referentially transparent" than most, since
    expressions in the vein of `[x = [1, 2], f x] will generally
    work. That isn't true in C, Java or Python.

  * It is possible to define arbitrary operators and to use functions
    as operators. In order to aid readability, however, their priority
    cannot be customized.


;; [

= Why not do it like <x>? And other questions.


* __[Why not use `()s instead of `[]s for function arguments?]
  
  I had it like that before, but then I switched back so that `()
  defines s-expressions. For consistency's sake, it must be the case
  that the same brackets are used to define lists and arguments.
  
  [Sweet expressions]@@{sweet} define `f(x) as a shortcut for `(f x), but
  I find that less elegant than what I'm doing, especially since adding
  a space to make it `[f (x)] transforms the expression into `(f (x)). I
  don't like that.
  

* __[Why not `[[a b c]] instead of [`[[a, b, c]]]?]
  
  Because `[f x] means `(apply f x), e.g. `[min xs], `[{+} xs],
  `[string-append strings], etc.


* __[Why does indent create `begin blocks?]

  Well, the alternative would be to create a list, in which case you
  could write out the arguments of a function on separate lines. The
  problem is that this does not work well for operators. I want an
  indented line after `[=], `[->] and `[:] to be equivalent to not
  having an indented block. At the same time, I don't want indented
  blocks to have a different meaning depending on what comes before
  them. `begin just does what I want.

  
* __[There is nothing wrong with s-expressions!]
  
  Fair enough, but then I'm not sure why you're reading this. People who
  are used to a particular syntax are unlikely to want to switch,
  regardless of what it looks like. Liso is more geared towards the
  people who don't like s-expressions, but would like a language regular
  enough to write macros in.
  
  
* __[It will never succeed!]
  
  Probably not as an alternative syntax to s-expressions for existing
  languages, no. Part of the problem is inertia. Existing users are
  unlikely to switch: Lispers and Schemers often come to love
  s-expressions (and paredit) and Liso does not offer real gains to
  those people. New users, when looking for help, will see
  s-expressions, so they will have to get familiar with them anyway.
  
  I think it might be interesting as a syntax for a new language,
  though, or as an alternative syntax to languages like JavaScript. The
  syntax is close enough to popular languages like Python to have wide
  appeal, but at the same time it is very regular, very macro friendly
  and thus very extensible.

]


= Concluding remarks

In my opinion, the syntax I've cooked up is a competent alternative to
s-expressions. I also prefer it to [sweet expressions]@@{sweet}, which is the
best attempt at an alternative syntax for Scheme that I've seen so
far.

It is a more complex syntax than Scheme, but for me it hits a sweet
spot. It enforces a syntactic distinction between function/macro calls
(where `car is special) and lists of things (where `car is not
special), but in practice languages based on s-expressions tend to
erase it. This makes the translation occasionally awkward, though I
think it is more a problem with s-expressions: it makes sense to
distinguish lists of things from actual calls syntactically.

I plan on porting the syntax to JavaScript and Python, which would
give both languages macros and the upsides of s-expressions without
the downsides.

The source code is available here@@{source}. The repository contains
more examples and some instructions on how to try it. At the time of
this writing, the Planet version of Liso (1.1) is out of date, I'll
update when I make up my mind on a few things.

store nav ::
  toc::
  div.seealso %
    * O-expressions @@@ oexprs
    * Liso source @@ https://github.com/breuleux/liso
    * [Earl Grey @@ http://breuleux.github.io/earl-grey/],
      designed later from the same principles.

js ::
  System.import("/blog/lib/toc.js");

point => https://github.com/breuleux/liso/blob/master/liso/examples/point.liso
source => https://github.com/breuleux/liso
sweet => http://srfi.schemers.org/srfi-110/srfi-110.html


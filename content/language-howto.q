
template :: default

meta ::
  id = 2d68aba0-f140-11e5-a13a-9bad23a1302c
  title => <Insert Language Name Here>
  tagline = How to make interesting little languages.
  author = Olivier Breuleux
  date = 2016/07/04
  language = English
  category = Programming
  tags =
    * Programming Languages
  comments = true
  list = true

store nav ::
  toc::

resources ::
  teacup-mode.js

sass ::
  .no-aside.repple-editor-container
    width: 750px
    .repple-editor
      width: 750px
    .repple-aside
      display: none
  .repple-container
    border: 3px solid #ccc
    font-size: 16px
    width: 1050px
  .repple-editor-container
    /* flex-direction: column
    .repple-editor
      width: 650px
    .repple-repl
      width: 400px
    .repple-aside
      width: 400px
      border-left: 2px solid #ccc
      padding-left: 5px
  @media screen and (min-width: 1100px)
    .repple-container
      margin-left: -150px
  @media screen and (max-width: 1100px)
    .repple-aside
      display: none
    .repple-container
      width: auto
      max-width: 700px
    .repple-editor-container .repple-editor
      width: auto
      max-width: 700px

;;  @media screen and (max-width: 500px)
    .repple-editor-container .repple-editor
      font-size: 10px

;;
      .str:before, .str:after
        color: #888
      .str:before
        content: "‘"
      .str:after
        content: "’"
      .assoc :first-child
        .str:before, .str:after
          content: ""

langname => Teacup
[langspan ::] => [span.langname % {langname}]

css ::
  #langname {
    text-align: center;
    border: none;
    border-bottom: 2px solid #888;
    padding: 5px;
    padding-right: 5px;
    padding-left: 5px;
    background: #f8f8f8;
    width: 100%;
    outline: none;
    font-size: 20px;
  }
  #langname:focus {
    outline: none;
    border-bottom: 2px solid black;
  }
  .repple-editor-container .repple-editor, .repple-editor-container .repple-aside {
    height: auto;
  }
  .note:before {
    content: "Note: ";
    font-weight: bold;
  }
  .note {
    background-color: #ddf;
    padding: 10px;
  }

js ::
  function loggable(cls) {
    cls["::egclass"] = true;
    cls["::name"] = cls.name;
  }


$$$A bit over a year ago I posted __[this little gem]@@http://jsfiddle.net/osfnzyfd/
on Hacker News, where I define a simple programming language in 450 lines
of JavaScript or so (that includes comments). I made a mental note
at that moment to make a more detailed post explaining how it worked, but I never
got around to it. So I'm going to go ahead and do it now.

That language was a nameless throwaway experiment, but for the
purposes of this post I should probably give it a name. I'm going to
go with "Teacup", an unassuming, adorable name, fit for the small and
unassuming language we're going to make.

If you don't like it and would rather give it a mightier name like, I
don't know, _TeaRex or _MegaLang3000, you can edit it below:

input#langname %
  value = {langname}

So without further ado, dear readers, let us write the langspan::
programming language.

js ::
  var langname = document.getElementById("langname");
  function updateLang(name) {
    var spans = document.querySelectorAll(".langname");
    for (var i = 0; i < spans.length; i++) {
      spans[i].innerHTML = langname.value;
    }
  }
  langname.onkeyup = function () { updateLang(name); }


.note %
  The tutorial is interactive, which means that besides changing the
  language's name to something that will make you giggle like a
  schoolgirl, you can edit the code in each box and run it with
  Ctrl+Enter. You can use the `log function to pretty-print objects in
  the area to the right of the text editor. However, this is only
  going to be practical on a desktop.


== Overview

We will construct langspan:: as a series of transformations, going
from the initial source code (a string) to the result of the
computation. We will use JavaScript for the implementation, because it
is widely known and runs in browsers, but it should be straightforward
to translate to your favorite language.

The steps will be as follows:

* We start with the source code, a string.
* The __lexer@@[#lexer] transforms a string into a list of tokens.
* The __parser@@[#parser] transforms a list of tokens into an abstract syntax tree.
* The __interpreter@@[#interpreter] transforms an abstract syntax tree into a result.

Here we define a `Pipeline class that will make our work easier by
composing a series of transformations, passed as a parameter:

inherit %
  style = height:400px
  repple editor ::
    language = javascript
    indent = 4
    theme = eclipse
    code =>
      function Pipeline(...steps) {
          this.steps = steps;
      }
      Pipeline.prototype.process = function (x) {
          for (var step of this.steps) {
              if (typeof(step) === "function")
                  x = step(x);
              else
                  x = step.process(x);
          }
          return x;
      }
      var p = new Pipeline({process: x => x + 1},
                           {process: x => x / 2},
                           {process: x => x + " little piggies."});
      log(p.process(9));

== Lexer

The job of a lexer is to split the input text into a list of discrete
_tokens (atomic parts like numbers, strings, an opening parenthesis,
and so on). Not all parsing methodologies have this step, but for the
method we are going to use, it simplifies things.

First we will define a regular expression for each of our token types:
we'll have numbers, words (variables), operators, strings (with double
quotes) and comments (starting with `[#] and up to the end of the
line):

;; inherit %
  style = height:370px
  repple editor ::
    language = javascript
    indent = 4
    theme = eclipse
    code =>
      // You can edit this and execute the code with Ctrl+Enter
      // However, note that the other code boxes will use these
      // definitions, so if you break this, you will break the rest
      // of the tutorial.
      tokenDefinitions = {
          number: "\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?",
          open: "[\\(\\[\\{]|\\b(?:let|for|if|begin)\\b",
          middle: "\\b(?:then|elif|else|in|do|when)\\b",
          close: "[\\)\\]\\}]|\\bend\\b",
          infix: "[,;\n]|[!@$%^&*|/?.:~+=<>-]+|\\b(?:and|or|not)\\b",
          word: "\\w+",
          string: "\"(?:[^\"]|\\\\.)*\"",
          comment: "#[^\n]*(?=\n|$)"
      };
      log(tokenDefinitions);

inherit %
  style = height:370px
  repple editor ::
    language = javascript
    indent = 4
    theme = eclipse
    code =>
      // You can edit this and execute the code with Ctrl+Enter
      // However, note that the other code boxes will use these
      // definitions, so if you break this, you will break the rest
      // of the tutorial.
      tokenDefinitions = [
        ["number", "\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?"],
        ["open", "[\\(\\[\\{]|\\b(?:let|for|if|begin)\\b"],
        ["middle", "\\b(?:then|elif|else|in|do|when)\\b"],
        ["close", "[\\)\\]\\}]|\\bend\\b"],
        ["infix", "[,;\n]|[!@$%^&*|/?.:~+=<>-]+|\\b(?:and|or|not)\\b"],
        ["word", "\\w+"],
        ["string", "\"(?:[^\"]|\\\\.)*\""],
        ["comment", "#[^\n]*(?=\n|$)"]
      ];
      log(tokenDefinitions);

The order is important: the regular expression for `word is a superset
of the expression for `number, for example, which is why `number is
before `word. Whatever is not covered by these regular expressions,
whitespace for instance, will be ignored by the parser.

Also, the reason why I define them as strings rather than regular
expressions is that I'm going to concatenate them and I don't know how
to do this if they are not strings.

Here's the code for transforming a string into a joyous list of
tokens:

inherit %
  style = height:720px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      function Lexer(tokenDefinitions) {
          // Build a big ass regular expression
          var keys = tokenDefinitions.map(k => k[0]);
          var regexps = tokenDefinitions.map(k => k[1]);
          this.re = new RegExp("(" + regexps.join(")|(") + ")");
          // this.types associates each group in the regular expression
          // to a token type (group 0 => not matched => null)
          this.types = [null].concat(keys);
      }
      Lexer.prototype.process = function(text) {
          var pos = 0;
          // Splitting with a regular expression inserts the matching
          // groups between the splits.
          return text.split(this.re)
              .map((token, i) => ({
                  type: this.types[i % this.types.length], // magic!
                  text: token,
                  start: pos,
                  end: pos += (token || "").length
              }))
              // remove empty tokens
              .filter(t => t.type && t.type !== "comment" && t.text)
      }
      loggable(Lexer);
      var lexer = new Lexer(tokenDefinitions);
      // log(lexer)
      var testCode = 'one + "two" == 3' // change me!
      log(testCode);
      lexer.process(testCode).forEach(x => log(x));

You can change `testCode to something else you want to test (hit
Ctrl+Enter to run).

Essentially, we build a __[large regular expression] with one
__[matching group] for each token type, then we use `String.split to
get our list of tokens, which is a mix of matching strings and the
value `undefined (when there is no match). The type of each token can
be figured out from its __position in the list. Then we filter out the
spurious tokens, those that are comments, have a `null type, or have
`undefined in the text field.

We also store __start and __end positions for each token. It is very
important to keep track of these numbers so that when things go wrong,
we know _where they went wrong.


== Parser

Alright, so we have a list of tokens. Now we need to organize them
into a structure that resembles some kind of program. For langspan::
we are going to use a very simple, but elegant system: an __[operator
precedence grammar].

OPGs are more limited than the LL or LR grammars that are used for
most languages, but I think these are overkill anyway. OPGs have some
interesting properties that in my view make up for the
limitations. For instance, the parsing rules are highly __local, which
means they are, in principle, amenable to parallel parsing.

Also, nobody ever talks about them, so I can differentiate my offering
in the unending flood of terrible tutorials that plague the Internet.

Now, the common understanding of operator precedence is that each
operator has a precedence number and is either left-associative or
right-associative. But forget about this system. It's rubbish. Let me
show you a better one:


=== Operator precedence grammars

Instead, imagine that you have a __[precedence matrix], with a cell
for each (ordered) pair of operators. So if you have the expression
`(a + b * c), instead of going: "Okay, so `[+] has priority 10, and
`[*] has priority 20, so `[*] has higher priority and we must
parenthesize it like this: `(a + (b * c))", you look up the matrix
entry `M(+, *). There are three possibilities:

* `[M(+, *) = -1]: the operator on the __left (`[+]) has precedence,
  so the expression should be parenthesized as `((a + b) * c).
* `[M(+, *) = 1]: the operator on the __right (`[*]) has precedence,
  so the expression should be parenthesized as `(a + (b * c)).
* `[M(+, *) = 0]: both operators are __equal, so `b "belongs" to both of
  them. If you want a better intuition as to what this means, it means
  you are making the __ternary operator `[+*] and `b is its middle operand.

If the expression, instead, was `(a * b + c), then we would consult
`M(*, +), which may or may not be the opposite of `M(+, *). In fact:

* `[M(+, +) = -1] means that `[+] is __left-associative.
* `[M(^, ^) = 1] means that `[^] is __right-associative.
* For a __ternary operator, for example `(a ? b : c), then `[M(?, :) = 0].
* The same idea works for __brackets: `[M([, ]) = 0].

So you can see this is pretty powerful. You get associativity, you get
ternary operators, brackets, and so on, for free. You could also
define a complex operator like `[if a then b elseif c ... else d end]
if you wanted to (and we _will want to do this).


=== Precedence definitions

Granted, defining a precedence matrix sounds like _work. If you have
ten operators, the matrix is five by ten, which means a hundred
entries. If you have twenty, well... yeah. We don't want to fill that
manually.

There are many solutions to this problem, but a tutorial can only
afford so much sophistication, so what we're going to do is this: for
each operator `op, we will have _two numeric priorities: a
__left-priority `L(op) for when the operator is on the left and a
__right-priority `R(op) for when it is on the right. And then we will
define `M(op1, op2) using `L and `R as follows:

` M(op1, op2) = sign(R(op2) - L(op1))

Under this scheme, an operator is left-associative if `[L(op) > R(op)]
and right-associative if `[R(op) > L(op)]. Unlike the one-priority
scheme, this preserves our ability to define ternary operators. What
follows are the priorities for [langspan::]. Some of them will seem
strange at first glance, but I will explain everything.

inherit %
  style = height:500px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      function lassoc(n) { return {left: n, right: n - 1}; }
      function rassoc(n) { return {left: n, right: n + 1}; }
      function xassoc(n) { return {left: n, right: n}; }
      function prefix(n) { return {left: n, right: 10004}; }
      function suffix(n) { return {left: 10005, right: n}; }
      
      priorities = {
      
          // Brackets and control structures
          "type:open":     prefix(5),
          "type:middle":   xassoc(5),
          "type:close":    suffix(5),
      
          // Lists
          "\n":            xassoc(15),
          ";":             xassoc(15),
          ",":             xassoc(25),
      
          // Assignment
          "=":             rassoc(35),
      
          // Lambda
          "->":            rassoc(35),
      
          // Comparison and logic
          "not":           prefix(105),
          "or":            lassoc(115),
          "and":           lassoc(125),
          ">":             xassoc(205),
          "<":             xassoc(205),
          ">=":            xassoc(205),
          "<=":            xassoc(205),
          "==":            xassoc(205),
      
          // Range
          "..":            xassoc(305),
      
          // Basic arithmetic
          "+":             lassoc(505),
          "-":             lassoc(505),
          "prefix:-":      prefix(605),
          "*":             lassoc(605),
          "/":             lassoc(605),
          "%":             lassoc(605),
          "^":             rassoc(705),
      
          // Other operators
          "type:infix":    xassoc(905),
          "type:prefix":   prefix(905),
      
          // Field access
          ".":             {left: 15005, right: 1004},
      
          // atoms
          "type:word":     xassoc(20005),
          "type:number":   xassoc(20005),
          "type:string":   xassoc(20005),
      };
      log(priorities);

Some clarifications:

`lassoc defines a left-associative operator, which means its
left-priority is slightly greater than its right-priority. `rassoc
defines a right-associative operator (higher right-priority). `xassoc
defines equal left and right-priorities.

A `prefix operator is just an operator with very high
right-priority. Imagine for example that the expression `(a + * b) is
in fact `(a + null * b), with an implicit "null" token between the two
operators. A prefix operator will have a null left operand, whereas a
suffix operator will have a null right operand.

Since we compare `L(+) to `R(*), if `R(*) is very high, it's always
going to "win" the comparison. It will always take the `null, so it
will always be prefix. Likewise, a suffix operator would have very
high left-priority.

So:

* Opening brackets and keywords like `if (which begin special forms)
  are defined as `prefix operators with very low priority.

* Closing brackets the `end keyword are defined as `suffix operators
  with a very low priority that matches the opening bracket/keyword.

* Keywords that are part of a special form, like `else, have a very
  low priority that matches the opening and closing forms.

What about the entries for `word, `number and `string? These are not
operators, right? Well, to simplify the code, we will assume that they
_are operators, but these operators are __nullary (they are both
prefix and suffix).

Note that despite being prefix, `[\(] can take an operand on its left,
for instance if one writes `f(x), because `R(\() is not quite as high
as `L(f).

What follows is the code to get a token's priority and the `order
method, which calculates the matrix entry corresponding to two tokens:

inherit %
  style = height:575px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      function Parser(prio, finalize) {
          // It is important to give a null prototype to priorities
          // otherwise we'll get accidental "operators" like toString
          this.priorities = Object.assign(Object.create(null), prio);
          // I'll explain this later
          this.finalize = finalize;
      }
      Parser.prototype.getPrio = function (t) {
          var x = this.priorities[t.type + ":" + t.text]
               || this.priorities[t.text]
               || this.priorities["type:" + t.type]
          if (x) return x;
          else throw SyntaxError("Unknown operator: " + t.text);
      }
      Parser.prototype.order = function (a, b) {
          if (!a && !b) return "done";
          if (!a) return 1;
          if (!b) return -1;
          var pa = this.getPrio(a).left;
          var pb = this.getPrio(b).right;
          return Math.sign(pb - pa);
      }
      var parserIdentity = new Parser(priorities, node => node);


=== Algorithm

Now that we have a priority system for our operators here is the meat:
the __[operator precedence parser]. It is not a long algorithm, nor is
it very complex. The most difficult is to properly visualize its
operation, but you can uncomment the `log line in the code to get a
useful trace of what the algorithm is doing!

inherit %
  style = height:1250px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      Parser.prototype.process = function (tokens) {
          tokens = tokens.slice();
          var next = tokens.shift.bind(tokens);
          var stack = [];
          // middle points to the handle between the two
          // operators we are currently comparing
          // (null if the two tokens are consecutive)
          var middle = null;
          var left = undefined;
          var right = next();
          var current = [null, left];
          while (true) {
              // log((left&&left.text) + " vs " + (right&&right.text) + " ==> " + this.order(left, right));
              switch (this.order(left, right)) {
              case "done":
                  // Returned when left and right are both
                  // undefined (out of bounds)
                  return middle;
              case 1:
                  // Open new handle; it's like inserting
                  // "(" between left and middle
                  stack.push(current);
                  current = [middle, right];
                  middle = null;
                  left = right;
                  right = next();
                  break;
              case -1:
                  // Close current handle; it's like inserting
                  // ")" between middle and right and then
                  // the newly closed block becomes the new middle
                  current.push(middle);
                  middle = this.finalize(current);
                  current = stack.pop();
                  left = current[current.length - 1];
                  break;
              case 0:
                  // Merge to current handle and keep going
                  current.push(middle, right);
                  middle = null;
                  left = right;
                  right = next();
                  break;
              }
          }
      }
      testCode = "a + b * c";
      log(testCode);
      p = new Pipeline(lexer, parserIdentity);
      log(p.process(testCode, node => node));

In the right pane, you can see the output of the raw algorithm, which
is a deeply nested list. It may seem oddly organized at first glance,
but it is actually very neat: notice that in each list (0-based),
which we will also call a "handle", the __odd indexes are the operator
tokens, and the __even indexes are the operands. For instance:

* The atom `a
  (which as I explained before is parsed as a nullary
  operator) corresponds to the list `[[null, a, null]]. The operator is
  `a (in position 1), and it has two `null operands (in position 0 and 2).
* `[a + b] corresponds to the list `[[a, +, b]]: operator `[+] in
  position 1, operands `a and `b in position 0 and 2.
* If you try the code `(a) it will produce the list `[[null, (, a, ), null]]~.
  Operators in positions 1 and 3, operands in 0, 2 and 4.

Another neat property of this output is that it is order preserving:
if you flatten it, you end up with the original list of tokens, with a
`null between each token pair.

You have certainly noticed that `parse takes an additional argument, a
function called `finalize (we use the identity function in the example
above). That is the subject of the next section:


=== Finalizing the parse

Although neat, the raw output of `parse is not necessarily the one we
want. The __[`finalize] function is given a handle after it is completed
and must return the "value" associated to that handle. If you are
writing a simple calculator, that can be an evaluation function; if
you are writing a compiler or a more elaborate interpreter, it can be
a node of your abstract syntax tree (or AST).

Here we will define a `finalize function that transforms our infix AST
nodes into prefix ones and computes location information. We will do
this somewhat cleverly, for reasons that will become apparent later
(note that in what follows, `"a" is shorthand for the token object for
`a):

__ Our transformation rules:

* `[[null, "a", null]         ==> "a"]
* `[[a, "+", b]               ==> ["E + E", a, b]]
* `[[null, "+", b]            ==> ["_ + E", b]]
* `[[null, "(", a, ")", null] ==> ["_ ( E ) _", a]]

In other words, we will _eliminate nullary operators, and __aggregate
the operators that we find in odd positions into an expression that
describes which of the operands are not null.

(Also we are not really going to return an expression in prefix
notation, instead we will put the function's "signature" in the `type
field and the arguments in the `args field. That simplifies things a
little: our AST will have our old token nodes as leaves, with types
`word, `number, `string. And now we're going to add inner nodes with
type `[E + E] and the like, so that later on we can simply dispatch on
`type.)

inherit %
  style = height:500px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      function finalize(node) {
          var l = node.length;
          if (l === 3 && !node[0] && !node[2])
              return node[1];
          return {type: node.map((x, i) => {
                      if (i % 2 == 0)
                          return x === null ? "_" : "E"
                      else 
                          return x.text
                  }).join(" "),
                  args: node.filter((x, i) => x && i % 2 == 0),
                  ops: node.filter((x, i) => i % 2 == 1),
                  start: node[0] ? node[0].start : node[1].start,
                  end: node[l-1] ? node[l-1].end : node[l-2].end};
      }
      var parser = new Parser(priorities, finalize);
      testCode = "a + b * c";
      log(testCode);
      p = new Pipeline(lexer, parser);
      log(p.process(testCode));


== Interpreter

Now that we have our AST, there are a few things we could do. We could
write a compiler for [langspan::], either to JavaScript, or to a
different language, or machine code. Or we could write __[a simple
interpreter]. We are going to do the latter, because it is a bit more
interesting than compiling to JavaScript (and not a pain in the ass
like compiling to machine code).

=== Environment

In our interpreter we will implement __variables and __[lexical
scoping]. This means we need some kind of structure to map variable
names to values: an __environment. For this purpose we will use a
simple JavaScript object with a `null prototype (which means it has no
built-in fields like `toString that could interfere with symbol
resolution). Then, to implement nested scopes, all we need to do is to
call `Object.create on the parent environment. JS's prototype
inheritance will do the rest for us.

So we define the `makeEnvironment function that takes an optional
`bindings argument (for initial bindings). It will also populate the
environment with basic functionality that we want to have in
langspan::~, like truth, falsehood, arithmetic... that kind of
nonsense.

inherit %
  style = height:750px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      function lazy(fn) { fn.lazy = true; return fn; }
      function makeEnvironment(...bindingGroups) {
          var base = Object.create(null);
          for (var bindings of bindingGroups)
              Object.assign(base, bindings);
          return base;
      }
      var rootEnv = makeEnvironment({
          true: true,
          false: false,
          null: null,
          "+": (a, b) => a + b,
          "-": (a, b) => a - b,
          "prefix:-": a => -a,
          "*": (a, b) => a * b,
          "/": (a, b) => a / b,
          "%": (a, b) => a % b,
          "^": Math.pow,
          "<": (a, b) => a < b,
          ">": (a, b) => a > b,
          "<=": (a, b) => a <= b,
          ">=": (a, b) => a >= b,
          "==": (a, b) => a == b,
          "..": (start, end) =>
              Array.apply(null,Array(end-start)).map((_,i)=>i+start),
          "prefix:not": a => !a,
          "and": lazy((a, b) => a() && b()),
          "or": lazy((a, b) => a() || b()),
          Math: Math
      });
      log(rootEnv);

Notice that we populate the environment with some symbolic names like
`["+"]. We will make it so that operator applications like `(a + b)
will use these bindings.

The `and and `or functions are _lazy: instead of receiving their
arguments directly, these functions will receive functions that
evaluate to the arguments, so they may choose to evaluate only a
subset. The `lazy wrapper we define here just sets the `lazy property
to true, we will deal with it explicitly later (see the `runCall
function).


=== Utilities

Before going any further we will write some utilities to manipulate
the AST a bit more easily (their functionality and purpose should be
clear enough from the comments):

inherit %
  style = height:500px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      function extractArgs(guard, node, strict) {
          // extractArgs("E = E", `a = b`)        ==> [a, b]
          // extractArgs("E = E", `a + b`)        ==> null
          // extractArgs("E = E", `a + b`, true)  ==> ERROR
          // extractArgs(/^E [/]+ E$/, `a /// b`) ==> [a, b]
          if (guard === node.type
              || guard instanceof RegExp && node.type.match(guard))
              return node.args || [];
          if (strict)
              throw Error("Expected '"+guard+"', got '"+node.type+"'");
          return null;
      }

      function unparenthesize(node) {
          var res = extractArgs("_ ( E ) _", node);
          return res ? res[0] : node;
      }

      function getList(node) {
          // getList(`a, b, c`) ==> [a, b, c]
          // getList(`a`)       ==> [a]
          return extractArgs(/^[E_]( [;,\n] [E_])+$/, node)
              || (node ? [node] : []);
      }

      function normalizeCall(node) {
          // normalizeCall(`a + b`)   ==> [+, [a, b]]
          // normalizeCall(`f(a, b)`) ==> [f, [a, b]]
          var args = extractArgs(/^[E_] [^ ]+ [E_]$/, node);
          if (args)
              return [node.ops[0], args];
          else if (args = extractArgs(/^E \( [E_] \) _$/, node))
              return [args[0], getList(args[1])];
          return null;
      }

      function normalizeAssignment(node) {
          // normalizeAssignment(`a = b`)    ==> [a, null, b]
          // normalizeAssignment(`f(a) = b`) ==> [f, [a], b]
          var lr = extractArgs("E = E", node, true);
          var fargs = normalizeCall(lr[0]);
          if (fargs)
              return [fargs[0], fargs[1], lr[1]];
          else
              return [lr[0], null, lr[1]];
      }


=== Algorithm

Now comes the time to write our __interpreter for [langspan::], which
will evaluate a source string into a value. It will have two
parameters:

* A __[`parser] to produce the AST.
* A mapping from node "type" (word, number, E + E, etc.) to a function
  that handles that kind of node (__[`handlers]).

One caveat for the mapping is that we will also map __[regular
expressions] to handlers. For instance, we may have a node of "type"
`[_ if X elseif X elseif X else X end _]. We will therefore want to be
able to match an arbitrary number of `elseif. A regular expression
will do just fine.

We will define an `eval method on the interpreter which will take two
arguments: a source code string or an AST node, and the __environment
we defined previously.

inherit %
  style = height:500px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      function Interpreter(handlers, env) {
          // We reverse the handlers so that the most recent
          // have precedence over the rest.
          this.handlers = handlers.slice().reverse();
          this.env = env;
      }
      Interpreter.prototype.eval = function (node, env) {
          for (var h of this.handlers) {
              var args = extractArgs(h.key, node, false);
              if (args)
                  return h.func.apply(this, [node, env].concat(args));
          }
          throw SyntaxError("Unknown node type: " + node.type);
      }
      Interpreter.prototype.process = function (node) {
          return this.eval(node, this.env);
      }
      var handlers = [];


That's it, really. All we are missing are the handlers, which are
admittedly the most important part, because at the moment our
interpret literally can't interpret anything.

As we define them, we will push the handlers into the `handlers
variable.


=== Basic handlers

sass ::
  .small
    font-size: 11pt

The basic handlers we need are as follows:

+ Type + Example + Description
| `word | `xyz | Variable lookup
| `number | `123 | Numbers
| `string | `"hohoho" | Strings
| `[_ ( E ) _] | `(x) | Grouping
| `[E ( E ) _] | `f(x) | Function calls
| `[_ [ E ] _] | `[[x, y, z]] | List building
| `[E [ E ] _] | `x[y] | Indexing
| `[E . E] | `x.y | Dot notation for indexing
| `[E + E] | `[x + y] | Operator application
| `[E * E] | `[x * y] | "
| etc. | etc. | "
| [.small % `[_ if E then E else E end _]] | [.small % `[if x then y else z end]] | Conditional statement


inherit %
  style = height:1000px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      // Helper functions (used by more than one handler)
      function resolve(env, text) {
          if (text in env)
              return env[text];
          else
              throw ReferenceError("Undefined variable: '"+text+"'.");
      }
      function getField(obj, field) {
          var res = obj[field];
          if (typeof(res) === "function")
              // This is necessary for method calls to work.
              return res.bind(obj);
          return res;
      }
      function runCall(interpreter, node, env) {
          var res = normalizeCall(node);
          var fn = interpreter.eval(res[0], env);
          var args = res[1].map(x => () => interpreter.eval(x, env))
          if (fn.lazy)
              return fn.apply(interpreter, args);
          else
              return fn.apply(interpreter, args.map(t => t()));
      }
      
      // Variables
      handlers.push({
          key: /^(word|infix)$/,
          func: (node, env) => resolve(env, node.text)
      });

      // Prefix operators
      handlers.push({
          key: "prefix",
          func: (node, env) => resolve(env, "prefix:" + node.text)
      });

      // Numbers
      handlers.push({
          key: "number",
          func: (node, env) => parseFloat(node.text)
      });

      // Strings
      handlers.push({
          key: "string",
          func: (node, env) => node.text.slice(1, -1)
      });

      // Simple operators
      handlers.push({
          key: /^[E_] ([!@#$%^&*+\/?<>=.-]+|and|or|not) E$/,
          func: function (node, env) {
              return runCall(this, node, env);
          }
      });

      // Parentheses evaluate what's between them
      handlers.push({
          key: "_ ( E ) _",
          func: function (node, env, x) {
              return this.eval(x, env);
          }
      });

      // Ditto for begin/end
      handlers.push({
          key: "_ begin E end _",
          func: function (node, env, x) {
              return this.eval(x, env);
          }
      });

      // Function calls
      handlers.push({
          key: "E ( E ) _",
          func: function (node, env) {
              return runCall(this, node, env);
          }
      });

      // Function call (no arguments)
      handlers.push({
          key: "E ( _ ) _",
          func: function (node, env, f) {
              return this.eval(f, env).call(this)
          }
      });

      // List notation [a, b, c, ...]
      handlers.push({
          key: "_ [ E ] _",
          func: function (node, env, x) {
              return getList(x).map(arg => this.eval(arg, env));
          }
      });

      // Empty list
      handlers.push({
          key: "_ [ _ ] _",
          func: (node, env) => []
      });

      // Indexing; we make it so that x[1, 2] <=> x[1][2]
      handlers.push({
          key: "E [ E ] _",
          func: function (node, env, obj, index) {
              return getList(index).reduce(
                  (res, x) => getField(res, this.eval(x, env)),
                  this.eval(obj));
          }
      });

      // Dot notation
      handlers.push({
          key: "E . E",
          func: function (node, env, obj, field) {
              var x = this.eval(obj, env);
              var f = field.type === "word" ?
                  field.text :
                  this.eval(field, env);
              return getField(x, f);
          }
      });

      // if x then y else z end
      handlers.push({
          key: /^_ if E then E( elif E then E)*( else E)? end _$/,
          func: function (node, env) {
              var exprs = [].slice.call(arguments, 2);
              while (exprs.length > 0) {
                  if (exprs.length === 1)
                      return this.eval(exprs[0], env);
                  if (this.eval(exprs.shift(), env))
                      return this.eval(exprs.shift(), env);
                  else
                      exprs.shift();
              }
          }
      });

      // sequences; of; statements
      handlers.push({
          key: /[,;\n]/,
          func: function (node, env) {
              var last = undefined;
              for (stmt of [].slice.call(arguments, 2)) {
                  last = this.eval(stmt, env);
              }
              return last;
          }
      });

      var env = makeEnvironment(rootEnv, {a: 10, b: 20});
      var interpreter = new Interpreter(handlers, env);
      var tests = [
         'a + 2 * b',
         '(a + 2) * b',
         'a > 10 and b > 2',
         '[1, 2, 3].length',
         '[1, 2, 3].length.toString()'
      ]
      p = new Pipeline(lexer, parser, interpreter);
      for (var test of tests)
         log(test, p.process(test));


=== Variables and functions

Now that the basics are there, we will add the capability to __define
__variables and __functions, as well as simple __[list comprehension]
syntax:

+ Type + Example + Description
| `[E -> E] | `[x -> x + 1] | Anonymous function
| [.small % `[_ let E in E end _]] | [.small % `[let x = 1 in x * x end]] | Variable binding
| [.small % `[_ for E in E do E end _]] | [.small % `[for x in list do x * x end]] | List comprehension

inherit %
  style = height:500px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      // Helper functions
      function variableBinder(expr, env) {
          if (!expr.type.match(/word|infix|prefix/))
              throw SyntaxError("Invalid variable declaration.");
          var pfx = expr.type === "prefix" ? "prefix:" : ""
          return function (value) {
              env[pfx + expr.text] = value;
          }
      }
      function buildFunction(self, decls, body, env) {
          return function () {
              var arguments = [].slice.call(arguments);
              var newEnv = Object.create(env);
              for (var decl of decls) {
                  variableBinder(decl, newEnv)(arguments.shift());
              }
              return self.eval(body, newEnv);
          }
      }

      // Anonymous functions: args -> body
      handlers.push({
          key: "E -> E",
          func: function (node, env, decl, body) {
              var args = getList(unparenthesize(decl));
              return buildFunction(this, args, body, env);
          }
      });

      // let x = y in z end
      handlers.push({
          key: "_ let E in E end _",
          func: function (node, env, rawDecls, body) {
              var decls = getList(rawDecls)
                  .map(d => normalizeAssignment(d));
              var newEnv = Object.create(env);
              for (var decl of decls) {
                  var value =
                      decl[1]
                      ? buildFunction(this, decl[1], decl[2], newEnv)
                      : this.eval(decl[2], env);
                  variableBinder(decl[0], newEnv)(value);
              }
              return this.eval(body, newEnv);
          }
      });

      function forHandler(v, list, cond, body, env) {
          var results = [];
          for (var x of this.eval(list, env)) {
              var newEnv = Object.create(env);
              variableBinder(v, newEnv)(x);
              if (!cond || this.eval(cond, newEnv)) {
                  results.push(this.eval(body, newEnv));
              }
          }
          return results;
      }

      // for x in y do z end
      handlers.push({
          key: "_ for E in E do E end _",
          func: function (node, env, v, list, body) {
              return forHandler.call(this, v, list, null, body, env);
          }
      });

      // for x in y when c do z end
      handlers.push({
          key: "_ for E in E when E do E end _",
          func: function (node, env, v, list, cond, body) {
              return forHandler.call(this, v, list, cond, body, env);
          }
      });

      var interpreter = new Interpreter(handlers, rootEnv);
      var tests = [
         '(x -> x * x)(10)',
         '((x, y) -> x / y)(10, 2)',
         'let x = 9, y = 2 in x * y end',
         'let sq(x) = x * x in sq(20) end',
         '[1, 2, 3].map(x -> x * x)',
         'for x in [1, 2, 3] do x * x end',
         'for x in 1..10 when x > 3 do x * x end',
         'let x // y = Math.floor(x / y) in\n  100 // 3\nend',
      ]
      p = new Pipeline(lexer, parser, interpreter);
      for (var test of tests)
         log(test, p.process(test));


Well, look at that! langspan:: is almost complete!


== Adjustments

The one small detail we have to fix is unary `[-] which,
unfortunately, doesn't work. With our current setup, `(10 + -2) will
parse as `((10 +) - 2).

There is an easy fix: we will write a pass that looks for sequences of
infix tokens and make every operator except for the first one
prefix. We will sandwich that pass between the lexer and parser.

inherit %
  style = height:450px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      function tagPrefix(tokens) {
          var prevType = "infix";
          for (var token of tokens) {
              if (token.type === "infix" &&
                  (prevType === "infix" || prevType === "open")) {
                  prevType = token.type;
                  token.type = "prefix";
              }
              else
                  prevType = token.type;
          }
          return tokens;
      }
      var p = new Pipeline(lexer, tagPrefix, parser, interpreter);
      var testCode = '10 + -9' // change me!
      log(testCode);
      log(p.process(testCode));

There. We're done :\)


== Play pen

You can try the final result here. I have added syntax highlighting
and automatic indent for your convenience. The highlighting depends
only on the regular expressions defined in the lexer@@[#lexer]
section, so it will adapt to whatever changes you make. Fun!

Note: if the play pen is empty, that's because you evaluated code in
some other editor on your way here. If you refresh the page, you will
see an example.

__ Hit Ctrl+Enter to evaluate.

.repple-theme-light.repple-container.repple-editor-container %
  style = height:400px
  .repple-editor#playpeneditor %
    textarea.repple-editorarea#playpeneditor %
  .repple-aside %
    #playpentarget %

js ::
  var qrj = require("quaint-repple-javascript");
  var cm = qrj.codemirror;
  function clearNode(n) {
    while (n.firstChild) {
      n.removeChild(n.firstChild);
    }
  }
  function setupPlaypen() {
    var parent = document.getElementById("playpeneditor");
    clearNode(parent);
    var tx = document.createElement("textarea");
    tx.className = "repple-editorarea";
    parent.appendChild(tx);
    makeCustomMode(cm, tokenDefinitions, "teacup");
    var target = document.getElementById("playpentarget");
    var outputter = qrj.Outputter(target);
    var ed = cm.fromTextArea(tx, {mode: "teacup", theme: "eclipse"});
    ed.setSize("auto", "auto");
    ed.setOption("extraKeys", {
      "Ctrl-Enter": cm => {
        var ipt = new Interpreter(handlers,
                                  makeEnvironment(rootEnv, {log: x => outputter.log(x)}))
        var p = new Pipeline(lexer, tagPrefix, parser, ipt);
        clearNode(target);
        var result = p.process(ed.getValue());
        outputter.log(result);
      }
    });
    return ed;
  }
  var pen = setupPlaypen();
  pen.setValue('let odd(x) = if x == 0 then false else even(x - 1) end\n    even(x) = if x == 0 then true else odd(x - 1) end\nin\n  for i in 1..10 do\n    log(i + " is " + if even(i) then "even" else "odd" end)\n  end\n  "done"\nend');


== Conclusion

We made langspan::~! Yay! That wasn't too hard.

There's a bunch of stuff we could do to tweak or improve it, and which
may be the subject of future posts, if there is interest:

* Static type annotations and inference.
* Interesting special forms, like pattern matching.
* Simple macro system.
* Incremental parser.

A git repository with the code is available __here@@https://github.com/breuleux/teacup~.

I also made a __JSFiddle@@https://jsfiddle.net/qh3bvqjh/ for your convenience.


js ::
  $$quaintReppleInstall().then(function () {
    var q = $$quaintReppleInstances;
    function onSubmit(i) {
       if (q[i + 1]) {
          q[i + 1].editor.submit();
       }
       setupPlaypen();
    }
    q.forEach((x, i) => x.editor.on("submit", y => onSubmit(i)));

    // var testotron = document.getElementById("testotron");
    // var cm = CodeMirror.fromTextArea(testotron);
    // cm.setOption("mode", "lang");

  });


store more ::
  __ Related links

  * __[The Earl Grey language]@@http://earl-grey.io which I designed
    using some of the principles in this tutorial.
  * __["Screw it, I'll make my own!"]@@my-own-language.html, an article
    about my experience designing a programming language.

  __ Unrelated links

  * __[My short stories ;\)]@@index.html#shortstories



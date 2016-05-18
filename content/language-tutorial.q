
template :: default

meta ::
  id = 2d68aba0-f140-11e5-a13a-9bad23a1302c
  title = Trivial language design
  tagline = A 450-lines implementation of a programming language in JavaScript
  author = Olivier Breuleux
  date = 2016/03/23
  language = English
  category = Programming
  tags =
    * Programming Languages
  comments = true
  list = true

store nav ::
  toc::


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

langname => Mega Crocodile
[langspan ::] => [span.langname % {langname}]

css ::
  #langname {
    display: inline-block;
    border-bottom: 2px solid #888;
    padding-right: 5px;
    padding-left: 5px;
    background: #f8f8f8;
  }
  #langname:focus {
    outline: none;
    border-bottom: 2px solid black;
  }
  .repple-editor-container .repple-editor, .repple-editor-container .repple-aside {
    height: auto;
  }

js ::
  function loggable(cls) {
    cls["::egclass"] = true;
    cls["::name"] = cls.name;
  }


$$$A bit over a year ago I posted [this little gem]@@http://jsfiddle.net/osfnzyfd/
on Hacker News, where I define a simple programming language in 450 lines
of JavaScript or so (that includes comments). I made a mental note
at that moment to make a more detailed post explaining how it worked, but I never
got around to it. So I'm going to go ahead and do it now.

That language was a nameless throwaway experiment, but for the
purposes of this post I should probably give it a name. Now, at first
I thought about giving it an unassuming name, something adorable, like
"Teacup", perhaps. But as this language is probably going to fade from
everyone's memories in less than a day, this is a golden opportunity
to give it a properly outrageous name:
div#langname %
  contenteditable = true
  {langname}

So without further ado, dear readers, let us write the langspan::
programming language.

js ::
  var langname = document.getElementById("langname");
  function updateLang(name) {
    var spans = document.querySelectorAll(".langname");
    for (var i = 0; i < spans.length; i++) {
      spans[i].innerHTML = langname.innerHTML;
    }
  }
  langname.onkeyup = function () { updateLang(name); }


== Lexer

The job of a lexer is to split the input text into a list of discrete
_tokens (atomic parts like numbers, strings, an opening parenthesis,
and so on). Not all parsing methodologies have this step, but for the
method we are going to use, it simplifies things.

First we will define a regular expression for each of our token types:
we'll have numbers, words (variables), operators, strings (with double
quotes) and comments (starting with `[#] and up to the end of the
line):

inherit %
  style = height:320px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      // You can edit this and execute the code with Ctrl+Enter
      // However, note that the other code boxes will use these
      // definitions, so if you break this, you will break the rest
      // of the tutorial.
      var tokenDefinitions = {
         number: "\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?",
         word: "\\w+",
         op: "[\\(\\)\\[\\]\\{\\},;\n]|[!@$%^&*|/?.:~+=<>-]+",
         string: "\"(?:[^\"]|\\\\.)*\"",
         comment: "#[^\n]*(?=\n|$)"
      };
      log(tokenDefinitions);

The order is important: the regular expression for `word is a superset
of the expression for `number, for example, which is why `number is
before `word. Also note that whatever is not covered by these regular
expressions will be ignored by the parser.

Here's the code for transforming a string into a joyous list of
tokens:

inherit %
  style = height:700px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      function Tokenizer(tokenDefinitions) {
         // Build a big ass regular expression
         var keys = Object.keys(tokenDefinitions);
         var regexps = keys.map(k => tokenDefinitions[k]);
         this.re = new RegExp("(" + regexps.join(")|(") + ")");
         // this.types associates each group in the regular expression
         // to a token type (group 0 => not matched => null)
         this.types = [null].concat(keys);
      }
      loggable(Tokenizer);
      Tokenizer.prototype.tokenize = function(text) {
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
            .filter(t => t.type && t.text) // remove empty tokens
      }
      var tokenizer = new Tokenizer(tokenDefinitions);
      // log(tokenizer)
      var testCode = 'one + "two" == 3' // change me!
      log(testCode);
      tokenizer.tokenize(testCode).forEach(x => log(x));

You can change `testCode to something else you want to test (hit
Ctrl+Enter to run).

Essentially, we build a large regular expression with one matching
group for each token type, then we use `String.split to get our list
of tokens, which is a mix of matching strings and the value `undefined
(when there is no match). The type of each token can be figured out
from its position in the list. Then we filter out the spurious tokens,
those that have `undefined in the text field or a `null type.

We also store start and end positions for each token. It is very
important to keep track of these numbers so that when things go wrong,
we know _where they went wrong.


== Parser

Alright, so we have a list of tokens. Now we need to organize them
into a structure that resembles some kind of program. We are going to
use a very simple, but elegant system for this: an operator precedence
grammar.

OPGs are more limited than the LL or LR grammars that are used for
most languages, but I think these are overkill anyway. OPGs have some
interesting properties that in my view make up for the
limitations. For instance, the parsing rules are highly local, which
means they are, in principle, amenable to parallel parsing. Also,
nobody ever talks about them.

Now, the common understanding of operator precedence is that each
operator has a precedence number and is either left-associative or
right-associative. But forget about this system. It's rubbish. Let me
show you a better one.


=== Operator precedence grammars

Instead, imagine that you have a precedence _matrix, with a cell for
each (ordered) pair of operators. So if you have the expression `(a +
b * c), instead of looking up the numbers for `[+] and `[*], you look
up the matrix entry `M(+, *). There are three possibilities:

* `[M(+, *) = -1]: `[+] has precedence, so the expression should be
  parenthesized as `((a + b) * c).
* `[M(+, *) = 1]: `[*] has precedence, so the expression should be
  parenthesized as `(a + (b * c)).
* `[M(+, *) = 0]: both operators are equal, so `b "belongs" to both of
  them. If you want a better intuition as to what this means, it means
  you are making the ternary operator `[+*] and `b is its middle operand.

If the expression, instead, was `(a * b + c), then we would consult
`M(*, +), which may or may not be the opposite of `M(+, *). In fact:

* `[M(+, +) = -1] means that `[+] is left-associative.
* `[M(^, ^) = 1] means that `[^] is right-associative.
* For a ternary operator, for example `[a ? b : c], then `[M(?, :) = 0].
* The same idea works for brackets: `[M([, ]) = 0].

So you can see this is pretty powerful. You get associativity, you get
ternary operators, brackets, and so on, for free. You could also
define a complex operator like `[if a then b elseif c ... else d end]
if you wanted to (and we _will want to do this).


=== Precedence definitions

Granted, defining a precedence matrix sounds like work. If you have
ten operators, the matrix is ten by ten, which means a hundred
entries. If you have twenty, well... yeah. We certainly don't want to
fill that manually.

There are many solutions to this problem, but a tutorial can only
afford so much sophistication, so what we're going to do is this: for
each operator `op, we will have _two numeric priorities: a
left-priority `L(op) for when the operator is on the left and a
right-priority `R(op) for when it is on the right. And then we will
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
      var priorities = {

        // Basic arithmetic
        "op:+":          {left: 501, right: 500},
        "op:-":          {left: 501, right: 500},
        "op:*":          {left: 601, right: 600},
        "op:/":          {left: 601, right: 600},
        "op:^":          {left: 700, right: 701},

        // Comparison and logic
        "word:or":       {left: 100, right: 100},
        "word:and":      {left: 110, right: 110},
        "op:>":          {left: 200, right: 200},
        "op:<":          {left: 200, right: 200},
        "op:>=":         {left: 200, right: 200},
        "op:<=":         {left: 200, right: 200},
        "op:==":         {left: 200, right: 200},

        // Brackets
        "op:(":          {left: 0,     right: 10000},
        "op:)":          {left: 10001, right: 0},
        "op:[":          {left: 0,     right: 10000},
        "op:]":          {left: 10001, right: 0},
        "op:{":          {left: 0,     right: 10000},
        "op:}":          {left: 10001, right: 0},

        // Lists
        "op:,":          {left: 5, right: 5},
        "op:;":          {left: 1, right: 1},
        "op:\n":         {left: 1, right: 1},

        // Field access
        "op:.":          {left: 15001, right: 1000},

        // Declaration, lambda
        "op:=":          {left: 10, right: 11},
        "op:->":         {left: 10, right: 11},

        // if _ then _ elseif _ ... else _ end
        "word:if":       {left: 0,     right: 10001},
        "word:then":     {left: 0,     right: 0},
        "word:elseif":   {left: 0,     right: 0},
        "word:else":     {left: 0,     right: 0},
        "word:end":      {left: 10000, right: 0},

        // let _ = _ in _ end
        "word:let":      {left: 0,     right: 10001},
        "word:in":       {left: 0,     right: 0},
        "word:end":      {left: 10000, right: 0},

        // for _ in _ [when _] do _ end
        "word:for":      {left: 0,     right: 10001},
        "word:in":       {left: 0,     right: 0},
        "word:when":     {left: 0,     right: 0},
        "word:do":       {left: 0,     right: 0},
        "word:end":      {left: 10000, right: 0},

        // Other operators
        "type:op":       {left: 900,       right: 900},

        // atoms
        "type:word":     {left: 20000,     right: 20001},
        "type:number":   {left: 20000,     right: 20001},
        "type:string":   {left: 20000,     right: 20001},
      };
      log(priorities);


The arithmetic priorities are straightforward enough, but for brackets
and some keywords you might wonder what the `10000 and `10001
priorities are for. Basically, they are to make sure an operator is
prefix or suffix (or both).

Imagine you have the expression `(a + * b).  You are still going to
compare `[+] to `[*], but what does it mean when there is no token in
the middle? Well, it's either going to be `((a +) * b) or `(a + (*
b)), so we want to know whether `[+] is suffix or `[*] is prefix. But
as you can imagine, if `R(*) is very high, then it's going to be
prefix no matter what. That's why `R is high for opening brackets and
`L is high for closing brackets.

And what about the entries for `word, `number and `string? These are
not operators, right? Well, to simplify the code, we will assume that
they _are operators, but these operators are nullary (they are both
prefix and suffix).

What follows is the code to get a token's priority and the `order
method, which calculates the matrix entry corresponding to two tokens:

inherit %
  style = height:500px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      function Parser(tokenizer, priorities) {
          this.tokenizer = tokenizer;
          this.priorities = priorities;
      }
      Parser.prototype.getPrio = function (t) {
          var x = this.priorities[t.type + ":" + t.text]
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
      var parser = new Parser(tokenizer, priorities);


=== Algorithm

Now that we have a priority system for our operators here is the meat:
the operator precedence parser. It is not a long algorithm, nor is it
very complicated. The most difficult is to properly visualize its
operation, but you can uncomment the `log line in the code to get a
useful trace of what the algorithm is doing.

inherit %
  style = height:800px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
      Parser.prototype.parse = function (text, finalize) {
          var tokens = this.tokenizer.tokenize(text);
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
                  middle = finalize(current);
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
      log(parser.parse(testCode, node => node));

In the right pane, you can see the output of the raw algorithm, which
is a deeply nested list. It may seem oddly organized at first glance,
but it is actually very neat: notice that in each list (0-based),
which we will also call a "handle", the odd indexes are the operator
tokens, and the even indexes are the operands. For instance:

* The atom `a
  (which as I explained before is parsed as a nullary
  operator) corresponds to the list `[[null, a, null]] the operator is
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
want. The `finalize function is given a handle after it is completed
and must return the "value" associated to that handle. If you are
writing a simple calculator, that can be an evaluation function; if
you are writing a compiler or a more elaborate interpreter, it can be
a node of your abstract syntax tree (or AST).

Here we will define a `finalize function that transforms our infix AST
nodes into prefix ones and computes location information. We will do
this somewhat cleverly, for reasons that will become apparent later
(note that in what follows, `"a" is shorthand for the token object for
`a):

* `[[null, "a", null]         ==> "a"]
* `[[a, "+", b]               ==> ["E + E", a, b]]
* `[[null, "+", b]            ==> ["_ + E", b]]
* `[[null, "(", a, ")", null] ==> ["_ ( E ) _", a]]

In other words, we will eliminate nullary operators, and aggregate the
operators that we find in odd positions into an expression that
describes which of the operands are not null.

Also we are not really going to return an expression in prefix
notation, instead we will put the function's "signature" in the `type
field and the arguments in the `args field. That simplifies things a
little: our AST will have our old token nodes as leaves, with types
`word, `number, `string. And now we're going to add inner nodes with
type `[E + E] and the like, so that later on we can simply dispatch on
`type.

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
                  orig: node,
                  start: node[0] ? node[0].start : node[1].start,
                  end: node[l-1] ? node[l-1].end : node[l-2].end};
      }
      testCode = "a + b * c";
      log(testCode);
      log(parser.parse(testCode, finalize));


== Interpreter

Now that we have our AST, there are a few things we could do. We could
write a compiler, either to JavaScript, or to a different language, or
machine code. Or we could write a simple interpreter. We are going to
do the latter, because it is a bit more interesting than compiling to
JavaScript.

=== Environment

In our interpreter we will implement variables and lexical
scoping. This means we need some kind of structure to map variable
names to values. For this purpose we will use a simple JavaScript
object with a `null prototype (which means it has no built-in fields
like `toString that could interfere with symbol resolution). Then, to
implement nested scopes, all we need to do is to call `Object.create
on the parent environment. JS's prototype inheritance will do the rest
for us.

So we define the `makeEnvironment function that takes an optional
`bindings argument (for initial bindings). It will also populate the
environment with basic functionality that we want to have in our
language.

inherit %
  style = height:500px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
       function makeEnvironment(bindings) {
          var base = Object.create(null);
          Object.assign(base, {
             true: true,
             false: false,
             null: null,
             "+": (a, b) => a + b,
             "-": (a, b) => a - b,
             "*": (a, b) => a * b,
             "/": (a, b) => a / b,
             "^": Math.pow,
             "<": (a, b) => a < b,
             ">": (a, b) => a > b,
             "<=": (a, b) => a <= b,
             ">=": (a, b) => a >= b,
             "==": (a, b) => a == b,
             Math: Math
          });
          Object.assign(base, bindings || {});
          return base;
       }

Notice that we populate the environment with some symbolic names like
`["+"]. Operator applications like `(a + b) will use these
bindings. The only operators that we will treat specially will be
operators with special or short-circuiting behavior like `and~.


=== Utilities

Before going any further we will write some utilities to manipulate
the AST a bit more easily:

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
              return [node.orig[1], args];
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

Now comes the time to write our interpreter, which will evaluate a
source string into a value. Our interpreter will have three parameters:

* A `parser to produce the AST.
* A mapping from node "type" (word, number, E + E, etc.) to a function
  that handles that kind of node.

One caveat for the mapping is that we will also map regular
expressions to handlers. For instance, we may have a node of "type"
`[_ if X elseif X elseif X else X end _]. We will therefore want to be
able to match an arbitrary number of `elseif. A regular expression
will do just fine.

We will define an `evalAST method on the interpreter which will take
two arguments: an AST node, and an _environment, which is simply an
object that maps variable names to values or functions.

inherit %
  style = height:500px
  repple editor ::
    language = javascript
    theme = eclipse
    code =>
       function Interpreter(parser, handlers) {
           this.parser = parser;
           // We reverse the handlers so that the most recent
           // have precedence over the rest.
           this.handlers = handlers.slice().reverse();
       }
       Interpreter.prototype.eval = function (node, env) {
           if (typeof(node) === "string")
              node = this.parser.parse(node, finalize);
           for (var h of this.handlers) {
              var args = extractArgs(h.key, node, false);
              if (args)
                 return h.func.apply(this, [node, env].concat(args));
           }
           throw SyntaxError("Unknown node type: " + node.type);
       };
       Interpreter.prototype.evalAST = Interpreter.prototype.eval;
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
  style = height:500px
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
          var args = res[1].map(x => interpreter.eval(x, env));
          return fn.apply(interpreter, args);
      }
      
      // Variables
      handlers.push({
          key: /^(word|op)$/,
          func: (node, env) => resolve(env, node.text)
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
          key: /^E [!@#$%^&*+/?<>=-]+ E$/,
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

      // Logical short-circuiting operator: and
      handlers.push({
          key: /^E( and E)+$/,
          func: function (node, env) {
             var exprs = [].slice.call(arguments, 2);
             return exprs.every(x => this.eval(x, env))
          }
      });

      // Logical short-circuiting operator: or
      handlers.push({
          key: /^E( or E)+$/,
          func: function (node, env) {
             var exprs = [].slice.call(arguments, 2);
             return exprs.some(x => this.eval(x, env))
          }
      });

      // if x then y else z end
      handlers.push({
          key: /^_ if E then E( elseif E then E)*( else E)? end _$/,
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

      var interpreter = new Interpreter(parser, handlers);
      var env = makeEnvironment({a: 10, b: 20});
      var tests = [
         'a + 2 * b',
         '(a + 2) * b',
         'a > 10 and b > 2',
         '[1, 2, 3].length',
         '[1, 2, 3].length.toString()'
      ]
      for (var test of tests)
         log(test, interpreter.eval(test, env));


=== Variables and functions

Now that the basics are there, we will add the capability to define
variables and functions, as well as simple list comprehension syntax:

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
      function variableBinder(expr) {
         if (expr.type !== "word" && expr.type !== "op")
            throw SyntaxError("Invalid variable declaration.");
         return function (env, value) {
            env[expr.text] = value;
         }
      }
      function buildFunction(self, decls, body, env) {
          return function () {
             var arguments = [].slice.call(arguments);
             var newEnv = Object.create(env);
             for (var decl of decls) {
                variableBinder(decl)(newEnv, arguments.shift());
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
                variableBinder(decl[0])(newEnv, value);
             }
             return this.eval(body, newEnv);
          }
      });

      // for x in y do z end
      handlers.push({
          key: "_ for E in E do E end _",
          func: function (node, env, v, list, body) {
             var bind = variableBinder(v);
             var newEnv = Object.create(env);
             var results = [];
             for (var x of this.eval(list, env)) {
                bind(newEnv, x);
                results.push(this.eval(body, newEnv));
             }
             return results;
          }
      });

      var interpreter = new Interpreter(parser, handlers);
      var env = makeEnvironment({a: 10, b: 20});
      var tests = [
         '(x -> x * x)(10)',
         '((x, y) -> x / y)(10, 2)',
         'let x = 9, y = 2 in x * y end',
         'let sq(x) = x * x in sq(20) end',
         '[1, 2, 3].map(x -> x * x)',
         'for x in [1, 2, 3] do x * x end',
         'let x // y = Math.floor(x / y) in\n  100 // 3\nend'
      ]
      for (var test of tests)
         log(test, interpreter.eval(test, env));


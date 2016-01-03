
template :: default

meta ::
  id = 21
  title = The taste of dog food
  tagline =
    On using a programming language you designed yourself.
  author = Olivier Breuleux
  date = 2015/08/31
  language = English
  category = Programming
  tags = {O-Expressions, S-expressions, Earl Grey, Programming Languages}
  comments = false
  list = false


__[$$$As basically nobody knows], I have been designing a new
programming language called [Earl Grey]@@{earlgrey}. I have also been
using it intensively, to the point that virtually all my programming
projects at the moment involve my language. It is an... interesting
experience, to say the least, and that experience is what I am going
to write about here.


Some people adapt to the tools that are available. Others believe that
they should not have to, and the tools should be adapted to
them. Programming language designers typically belong to the second
group: they would prefer the languages they know to be different, and
so they make new ones that do. It is not always a good
investment. First because features that sound good in your head may
not work all that well in practice. Second because most new languages
take more effort than the value they add, a bit like spending a
hundred dollars on a machine that will save a penny a year. Perhaps
you can be lucky and get a decent number of people to use your
language, but this isn't a realistic expectation unless you are a
large company and can buy your way into success. Perhaps there is
something in your design that's a publishable contribution to the
field. Or it may simply be that you enjoy the challenge.


In my case I wanted to create a language that I could use for scripts,
web applications and any new projects I may decide to put my mind
to. My bet was that I would spend less time making it than I would
save using it, and thus even if the language had no success at all
outside of my own use, it would still have been worth making. You
could say it is a rationalization: if I really want to make my own
language, but cannot expect many people, if anyone at all, to adopt
it, then I need the work to make up for more of my own work.


That did entail some sacrifices to my vision of a perfect language. I
decided to target JavaScript, for one, which is not a language I
appreciate very much, but because of its ubiquity it was clearly the
most useful target. I did not want to change its semantics too
radically either, because I wanted to be able to interoperate smoothly
with the node ecosystem: making a language is one thing, making up a
whole ecosystem and thousands of packages is quite another. These
steps would ensure that I could use my language productively and even
publish new packages written in Earl Grey but which could be imported
from JavaScript. Pragmatism, you see.


So let me tell the story of Earl Grey.


= Bootstrapping

I had been dabbing in programming language design for a while before
this. I made a language prototype that compiled to Python, dubbed
Unholy Grail. Then I made an alternative syntax for s-expressions
called [o-expressions]@@@oexprs and an implementation of them in
Racket which I called LISO@@@liso.

So I wrote the simplest JavaScript code generator I could in LISO for
a small subset of my language (one without significant indent and only
a few essential operators like arithmetic, assignment and
lambda). Once it worked, I rewrote it in that subset. And then, would
you look at that, the compiler could compile itself. Earl Grey
(though, I think I was calling it teacup at the time) was
self-hosting.

The main advantage of a self-hosting compiler, I find, is that it
instantly becomes a language's main application and a rather thorough
test of its correctness. More importantly, though, as you work and
improve on the compiler, you are forced to deal with the language you
have created. You have to experience its flaws, which is good since
you are in a great position to fix them as soon as they become
evident.

You also have to experience its lack of tooling.


= Tooling

Tooling sucks, or at least the need for it does. Different programmers
have different expectations regarding what they expect their tools to
do for them. Some, like me, mostly get by with syntax highlighting and
auto-indent. Others need a more complete environment to be comfortable
and feel productive. Fine by me. The thing is, though, when you make a
new language, you have nothing at all. No colors, no rules, just black
on white text, or white on black, or whatever fancy colors you choose
to use by default, like turquoise on burgundy or whatever. Not many
people are comfortable coding in such an environment.

It's not necessarily a pressing matter if you are implementing your
language in an established language like, say, C++, which has plenty
of tools, but as I mentioned, I was now making Earl Grey in Earl
Grey. I needed _something. It was a good thing that I'd been toying
with language design a lot before Earl Grey, and I had once designed
an Emacs mode for an old attempt. It took me a day or two, but I
managed to adapt it to my new vision. That code was, and still is,
very filthy, but it works.

Besides editor support, there is of course the issue of error
reporting. There is nothing more frustrating than errors you cannot
understand, or cannot trace. Unless you take good care to trace each
symbol in the original source code to the corresponding generated
code, the relationship between source and error will inevitably be
obfuscated. Source maps, thankfully, exist to alleviate the problem,
but I waited much too long to make use of them. It was not pleasant.

There is an interesting lesson to take from all this, mind you, which
is that support systems for programming languages are
_immense. Languages are supported by packages and libraries, by syntax
highlighting, IDE support, debuggers, online documentation,
communities on sites such as StackOverflow, paid support, and so
on. Brand new languages have _nothing. They can, as I have done, play
nice with existing ecosystems so that they can use another language's
packages and libraries, as I have done. Source map support can open
access to some editors and debuggers. Still, people will only use
languages that cater to their needs, and many people demand a lot (not
that they aren't entitled to).

But let's put it aside for a moment and keep the tale going.


= Evolution

The first few weeks were quite blissful: new feature after new feature
was implemented, and each of them simplified the compiler itself, or
made it more beautiful. If code seemed forced or inelegant, that could
be addressed with clever new structures. Keywords and operators
themselves could be changed and adapted.

After a while the language seemed good enough, so I started developing
other projects using it. For example:

* A remake of a previous project, a markup language called Quaint@@{quaint} (that I made the documentation with).
* An IRC bot to play holdem poker, cards against humanity and some other games.
* A REPL for Earl Grey that I could use to show it off online.
* Macros for express, react and other libraries.

Started work on a web application, too. That particular project showed
me just how soul-numbingly horrible JavaScript's callback hell was,
and even though they were clearly better, how awkward promises
were. My language had no special support for asynchronous programming
and that made it just as bad as JavaScript was. This prompted me to
add generators and `async/await keywords to Earl Grey. And so I did;
it was a bit tricky, but it all worked out in the end.

quaint => https://breuleux.github.io/quaint

There's something liberating about it, you know: seeing that something
is lacking, that some code is significantly more awkward than it
_should be... and then fixing it yourself. No need to wait for the
EcmaScript standards to address the problem, or for
[PEP0492]@@{pep0492} to be accepted in mainstream Python, and so
forth. You just... do it. Of course, it's no small time investment,
but once it works it is quite rewarding.

pep0492 => https://www.python.org/dev/peps/pep-0492/

But can you always do it, though?


= Inertia

There is a bit of a catch-22 in language design where the more a
language is used, the clearer it becomes which parts of it are
problematic and should change, but the harder it gets to actually
change them. To perfect a language you must use it, but using a
language requires that its features be stable, robust, set in stone,
and therefore to remain as imperfect as they were at that
moment. Furthermore, the more delays are suffered in fixing flaws or
plugging holes, the more likely it gets that a dependency is fostered
upon them. The options you do not explicitly and insistently leave
open, tend to close and seal themselves before you know it.

Having very few users besides oneself helps, since you don't have to
worry too much about breaking libraries and applications besides your
own. For a long time, Earl Grey's sole and most important application
was the compiler itself. But _[even then], came moments where I
thought something ought to be changed, but doing so seemed nearly
impossible.

There are several examples of changes that became awkward. I added a
`method keyword at some point, and of course that broke all the few
instances I had of using `method as a variable. Manageable, but with
time and a greater number of users it would become difficult. At some
point I wanted to experiment with changing the behavior of the `[?]
operator (it typechecks, e.g. `[String? "hello"] returns true), but I
deemed that it would break too much of what I already had. Same for
the `[#] operator, where e.g. `[#point{1, 2}] is shorthand for
`[{"point", 1, 2}]. I wanted to change that, but the compiler depended
on it too much. It feels strange that this would happen with only one
user, but it makes sense: languages are bound by rules and convention
as soon as they are spoken.



= Getting a few users

[I posted the language on Hacker News]@@{hn} to get some
feedback. That stressed me out, but the feedback seemed mostly
positive. Some people tried out the language and opened a few
issues. A smaller few still hang out with me on gitter@@{gitter}. On
IRC too, but that dried out.

hn => https://news.ycombinator.com/item?id=9509070
gitter => https://gitter.im/breuleux/earl-grey

There is something fascinating in seeing how other people use your
language and realize that they naturally settle on styles and
conventions that are different from yours, even conventions which you
believed looked "obviously" nicer, but some prodding around reveals
that your opinion isn't even the majority one. For instance, I would
write:

& square(x) = x * x

And they would write:

& square = x -> x * x

Both lines do exactly the same thing: define a function called `square
that multiplies a number by itself. The former uses a special syntax
that I made and thought looked more elegant and more mathematical; the
latter uses the syntax for anonymous functions (which is also
available in CoffeeScript and JavaScript as of ES6). Part of the
reason I added the first syntax is because I liked it better and
thought others would; I might decide differently if I thought it was
only me, since it complicates the syntax and is a bit of a pain in the
ass when writing macros.


[$$$T]he current state of Earl Grey is not necessarily what I would
have expected, but it is not too bad. I have written about 20 npm
packages in my language including itself, a markup language, a
serialization library, an incremental build tool, parts of a web
framework. There is syntax highlighting for Emacs, Atom and Pygments
(many thanks to MadcapJake for working on the last two!). I wrote
macros for mocha, gulp, express, react which I think are quite neat,
and there are plugins for gulp and fly. I feel like there would
probably be a richer ecosystem if I wasn't dreadful at publicity and
communicating with people, but such is life.

In closing I am going to give a summary of the important wisdom my
experience in designing a usable programming language gave me:


* __[Usefulness constrains design.] Unless you have lots of money and
  resources to throw at the problem, or enough luck to entice others
  to use your language and make it flourish, the simple fact of the
  matter is that a useful language needs to empower you to do the
  things you want to do, and the least that needs to be done to get to
  this state, the better. In other words, you need to be able to tap
  into existing ecosystems and existing libraries.

* __[Error reporting is a priority.]

* __[Use your language.]

* __[Observe how people code.]

* __[Fix any imperfection immediately.] I will not define
  "imperfection" here. What I am saying is that if something isn't the
  way it should be,














;; throwaway [
 And the fact of the matter is that I need to be able to
tap into libraries and functionality written by others, lest I want to
spend countless hours reimplementing algorithms I do not care to
improve upon. I also need the libraries that I write using my language
to play well in the ecosystem so that I can contribute to it. That is
why I had to compile Earl Grey to an existing language, and had to do
so as straightforwardly as possible without sacrificing too much of my
vision. Given that I wished to write web applications, compiling to
JavaScript was the most natural choice.

Right off the bat this was a bit of a sacrifice. I don't like
JavaScript's loosely typed semantics. But doing otherwise would have
been a greater limitation on my future options. So I went for it and
started by making Earl Grey into its own image. I made a very simple
version in Racket that produced valid JavaScript, based on previous
work I had done with [operator precedence grammars]@@@oexprs. A couple
hundred lines or so. Then I reimplemented it in Earl Grey, completing
the bootstrap. It is quite satisfying to do, although it can be a bit
confusing.
]








;; throwaway [
At this point I'd like to give some advice to would-be language
designers. Do not neglect error reporting. Track the position of every
token and every expression and keep good track of it when you expand
macros. If you compile to JavaScript, generate source maps. Every
error that could happen should also have a clear, precise, unique
message. Every time you cut corners will eventually cause you
confusion and displeasure. It will. I tried to do decent error
reporting for Earl Grey, but I did cut corners here and there and I
shouldn't have.
]





;; throwaway [

We may spend a lot of time arguing about the merits of actually doing
it, but in a sense, if you manage to create a new language and then
use it productively in a few projects, I don't believe it necessarily
requires wide exposure to be worth the effort.

Now, you might ask why it's cool, why you should use it, and so on,
but you can check out the project if you want to know that. That's not
what I'm going to write about here. No, what I'm going to write about
is... well, you see, when I made Earl Grey, what I aimed to do was to
design the language best adapted to my own way of thinking. Instead of
adapting to an existing language, I was going to adapt a language to
_me. And once that was done, I was going to _use that language to do
anything henceforth.

In a sense, that is a convenient justification for designing a new
language: it doesn't matter how popular it gets, it only needs to make
its designer's life better. That's how I went into it.

]

;; store nav ::
  a %
    href = http://breuleux.github.io/earl-grey/
    img %
      src = {siteroot}assets/earlgrey-text.svg
      width = 200px
      style = padding: 10px;

earlgrey => http://breuleux.github.io/earl-grey/


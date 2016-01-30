
template :: default

meta ::
  id = 8829cb0e-b596-11e5-a523-175f580c517c
  title = "\"Screw it, I'll make my own!\""
  tagline = The story of a new programming language
  author = Olivier Breuleux
  date = 2016/01/29
  language = English
  category = Programming
  tags =
    * O-Expressions
    * S-expressions
    * Earl Grey
    * Programming Languages
  comments = true
  list = true


__[$$$As... very few people know], for the past couple years I have
been designing a new programming language called [Earl Grey]@@{earlgrey}.
I did not design it as a test of my capabilities, or as an academic
paper, or any of that. I made it so that I could _use it, and use it I
have, intensively, to the point that virtually all my programming
projects at the moment involve my language. To this day I am not sure
if it was a sane or wise thing to do, but I believe that it is a
rather unique perspective to share -- one of the few experiences I can
think of that (curiously enough) is both empowering and isolating.


== The motivation


If you ask me why I made a programming language, I could justify it in
a lot of ways, point out its strengths, what I think it does better
than the others, and so on. But I don't think that's really the
driving force. As I see it, that driving force is, basically, a kind
of conceit. A typical programmer will learn one or several
well-established languages, depending on what they aim to
achieve. They will adapt their way of thinking to fit these tools as
best they can. But perhaps you don't want to _adapt. You don't like
any of the tools you can find because they are never exactly the way
you want them, it's like they don't fit your brain at the moment. If
you won't adapt to the language, the only alternative is to adapt the
language to you. And if you are like me it becomes a bit of an
obsession, an itch you just _have to scratch.

Of course, this can be a good thing: your preferred tool may very well
end up being preferred by many others. On the other hand, it could be
mere idiosyncrasy: an idea that for you is game-changing, but that
most people are indifferent to. And you know, when you think about it,
that is the most likely outcome. Simply look at the humongous number
of programming languages that exist, most of them half-done or
abandoned, others excellent but largely ignored. Take languages like
Oz@@{oz} or Icon@@{icon} which implement novel and powerful concepts
that are probably better than any you've come up with, and yet, I
imagine few people have even heard about them. In fact, most of the
languages that are used in practice are basically cookie-cutter clones
of each other, with some minor variations and a few ideas filched from
decade-old research.

oz => https://en.wikipedia.org/wiki/Oz_(programming_language)
icon => https://en.wikipedia.org/wiki/Icon_(programming_language)

I don't mean to sound bitter about it... well of course I'm a little
bitter about it. But it's normal. Learning a new language is a large
commitment that few people are willing to make. That cost penalizes
difference, as people seek tweaks on a familiar formula rather than
completely new paradigms. Pragmatic issues such as libraries and
tooling support also play a large role, since they are central to most
people's workflows. You really have to fill a pressing need, just at
the right moment, for a significant number people to invest
themselves, but that's not necessarily _your need you would be
filling. In the end, the only sure way to gain a decent following for
a language is to have support from a large corporation, but then
again, that is true of almost anything.

I don't have such backing, of course, and I have no social networking
skills either (sucks to be schizoid). But here's the thing. The more I
thought about this the more I realized _[I didn't care]. The itch was
still there, it wouldn't go away. I'd been having ideas about
programming languages for the better part of a decade and I was still
mostly using Python, sometimes JavaScript. They felt crippling, not
powerful enough. I dabbled in Scheme and Racket a bit too, but to be
honest, I just don't _like s-expressions. So after some
experimentation I came up with something I called
[o-expressions]@@oexprs.html, which (in my opinion) combine the
advantages of conventional syntax and s-expressions. I had several
other ideas, for instance about how powerful pattern matching
facilities could be integrated to the language, about ad-hoc
structures and exceptions, and so on.

But I felt I had waited long enough and I needed to do _something
about it. I needed to, so that instead of writing some Python script
and thinking, I wish I could abstract this pattern with a macro or
custom operator, or instead of writing something in Racket or Clojure
and wishing for more syntax, I could use a language that I like and
that I have control over. I needed to do it for myself, regardless of
whether anyone else would want anything to do with it or not.


== Compromise


Grand visions are always dangerous, because of how difficult they are
to satisfy. Any programming language designer, by nature, is going to
be much harder to satisfy than anyone else, because most of the time
other people are already satisfied. And there are a lot of things I
want from my ideal language, that roughly fall into three categories:

# Ideas that are clear in my mind, like o-expressions, hygienic
  macros, pattern matching, ad-hoc structures, and so on.

# Ideas that I think have potential, but that I haven't worked out the
  details: gradual typing, user-space program optimization, built-in,
  fine-grained serialization of data and code, including support for
  distributed computing, code signing, and so on.

# Things that require thousands of man-hours, like a sizable package
  ecosystem, widespread editor/IDE support, and a thriving community.

The problem, of course, is that trying to satisfy that specification
is basically insane. Just figuring out all the ideas in 2. would take
years and may never reach a satisfactory conclusion, and during all
that time I would have to use existing languages. This wasn't
acceptable: it dawned on me that if I either had to have a perfect
language, or nothing at all, then I would have nothing at all, plainly
said. Then it becomes a matter of choosing a particular focus. That
focus had to be the ideas I was mostly certain about.

Now, I needed a language that would be productive for me, a language
to make applications in. If for some reason I needed to parse XML,
serve static files over HTTP, and so on, it would be _nice if I didn't
have to sink hours implementing these things. In other words, there
was no getting around the fact that my language had to be compatible
with some existing runtime. That is why I chose to compile Earl Grey
to JavaScript. I don't _like JavaScript, but it is ubiquitous from
running in every browser, and it has an immense ecosystem. I also
decided not to change its semantics significantly: I had to ensure
smooth interoperation, make sure that I could easily use any existing
JavaScript package in Earl Grey, and that JavaScript users could
easily import packages written in Earl Grey.

It wasn't easy to drop so many interesting ideas, but I didn't really
have a choice if I wanted something to get done, and in the end, if I
succeeded in this capacity, within the limited bounds I had set, it
could only embolden my future projects. Once Earl Grey would be done,
I could use it to make another language and perhaps take greater risks
with it. Furthermore, I would certainly make mistakes, and the
experience is often much more formative than brooding on theory. You
don't really have much choice but to understand something, after
you've messed it up.


;; [

== Satisfying oneself

.todo %
  * Make the content/title fit the title/content better.
  * A bit more personal.

In a way, satisfying yourself in harder than satisfying other people,
because most of the time other people are already satisfied. It is
also easier, because by this point you already committed to eat
whatever crap you put on your plate.

.todo % what does that last sentence mean?

The main issue is the _ecosystem. Because languages don't exist in
isolation, oh, no. They come with a whole menagerie. Packages and
libraries, frameworks, editors, development environments, debuggers,
and so on. The libraries are the most important: thousands upon
thousands of lines of code written in or for a language to perform
common tasks. Lines you very well may need at some point, and don't
want to write yourself because there are only so many wheels you can
afford to reinvent.

Now, I always had that dream of a language I would design entirely
from scratch, with carefully picked semantics, exactly the way I want
them, but after a while I had to come to terms with the fact this
wasn't realistic. I wanted a language to make applications in, and if
for some reason I needed to parse XML, serve static files over HTTP,
and so on, it would be _nice if I didn't have to sink hours
implementing these things. That is why I chose to compile Earl Grey to
JavaScript. I don't _like JavaScript, but it is ubiquitous from
running in every browser, and it has an immense ecosystem. I also
decided not to change its semantics significantly: I had to ensure
smooth interoperation, make sure that I could easily use any existing
JavaScript package in Earl Grey, and that JavaScript users could
easily import packages written in Earl Grey. These are the compromises
I knew I had to make so that I could be certain I would be able to use
my own language productively.

Even with these compromises, the tooling parts of the ecosystem remain
an issue. To improve their productivity, people smother their
languages in makeup, highlighting keywords and other tokens with every
color in the rainbow. IDEs put squiggles under errors, helpfully
complete thoughts, and so on. But when a new language is born, it has
none of these amenities. It is stark naked, black on white (or white
on black, or whatever fancy colors you choose to use by default, like
turquoise on burgundy). No annotations, automatic completion, no
linting... not many people are comfortable coding in such an
environment.

So I wrote an Emacs mode to highlight my language, since that is the
editor I use. But you can see how designing a new language is an
isolating force: I don't have Vim syntax definitions, so I can't use
that editor productively. I didn't have Atom definitions until someone
helpfully [wrote some]@@{egatom}. Thus there are a lot of interesting
tools, editors and toys that are basically out of reach until I or
someone equally motivated addresses the issue.

egatom => https://atom.io/packages/language-earl-grey


== Bootstrapping

.todo % remove section

Or: what worth is a language that doesn't compile itself? Worthless,
that's what! The height of _chic for a programming language is for its
compiler to be self-hosting. There are advantages to the strategy: a
compiler is often a large and complex application, so it is a good,
thorough test of the language's ability. It also forces you to deal
with the language you have created from the outset. You have to
experience its flaws, which is good since you are in a great position
to fix them as soon as they become evident. Plus, you will naturally
end up adapting the language so that it is good at writing compilers,
at which point it is practically going to write itself.

A simple way to bootstrap a new language (let's call it X) is to pick
a small, simple, but sufficiently powerful subset of it that you know
isn't going to change (much), and use this for the bootstrap process
(let's call the subset mini-X). For instance, I had if/then/else in
mini Earl Grey, but no pattern matching, nor macros or significant
indent and other features I planned but didn't need immediately. It is
probable that mini-X has significant overlap (possibly _perfect
overlap) with an existing programming language Y, in which case you
should use Y to implement the first version of the compiler. Once you
can successfully and correctly compile the subset you chose, which
shouldn't be more than a few hundred lines, you have a compiler for
mini-X, written in Y. Then you translate the Y code to mini-X, which
should be easy, or trivial if you took care to avoid the advanced Y
features that aren't in mini-X. Now you can compile the mini-X
compiler, use it to compile itself a few times to make sure it isn't
bugged, and you don't need Y any more. I could write a full post about
this process (I probably will).

A last note for this section: [__ error reporting is so, so
important.] If there is anything you must work on first, this is
it. When an error occurs, you need to know what went wrong and most
importantly _where the error is before you can do anything about it.
You can't afford to spend hours hunting something down that the
machine could find for you. I did this half correctly: I took good
care of tracking the location of code tokens all through parsing and
macro expansion, so syntax errors would be easy to debug. Then I knew
I had to implement proper source maps (maps that retrace positions in
Earl Grey's source code from positions in the generated JavaScript),
but I was too lazy to learn how they worked. It was actually fine most
of the time, but I still got bit a few times by hard-to-find errors,
which is always incredibly frustrating. That time adds up, and so does
the frustration. I got around to it at last, and it's been better.

But even now I have issues with errors in the boilerplate code of some
macros because they don't track location information properly, and I
ran into difficulties attempting to fix the problem because it breaks
in too many places. You just _have to get this right the first
time. It's boring, it's easy to neglect, but if you don't do it, it
will bite you in the ass, it's inevitable.

]

== Getting to work

I started by bootstrapping@@{bstrap} Earl Grey, meaning that I would
write its compiler in itself. That has a few advantages: compilers are
usually large and complex applications, so this is a good, thorough
test of the language's ability. It also forces you to deal with the
language you have created from the outset. You have to experience its
flaws, which is good since you are in a great position to fix them as
soon as they become evident. Plus, you will naturally end up adapting
the language so that it is good at writing compilers, at which point
it is practically going to write itself.

bstrap => https://en.wikipedia.org/wiki/Bootstrapping_(compilers)

The first weeks of language development are blissful. New feature
after new feature is implemented, each of them making the compiler
simpler or more beautiful. If code seems forced or inelegant, that can
be addressed with clever new features. New keywords and operators can
be added or tweaked. I added significant indent at some point, cleaned
out all braces, and it felt great. I added pattern matching, replaced
countless if/then/else statements, and it felt great also. These are
good times. You never have to fight against the language, because you
have complete dominion over it, it cannot fight you, it has to bend to
your will. Frustration turns to elation as you spin a Feature out of
it.

But after a while, the language will turn into "good enough". It has
to, in order to be worthwhile. That's when you start developing other
projects using it. I did quite a few:

* An IRC bot to play holdem poker, cards against humanity and some other games.
* A little arcade game I call Glub and that I'll probably try to publish on mobile.
* A REPL@@{repl} for Earl Grey that I could use to show it off online.
* Macros for Express, React@@{egreact} and other libraries.
* A markup language called Quaint@@{quaint} (that I made the documentation with).
* About twenty plugins for that markup language.
* An incremental build system, Engage@@{engage}.

quaint => https://breuleux.github.io/quaint
engage => https://github.com/breuleux/engage
glub => http://breuleux.net/glub/
repl => https://breuleux.github.io/earl-grey/repl.html
egreact => https://github.com/breuleux/earl-react

All in all, these add up to about 30,000 lines of Earl Grey.

I started work on a web application, too. That particular project
showed me just how soul-numbingly horrible JavaScript's callback hell
was, and even though they were clearly better, the awkwardness of
promise syntax. Earl Grey had no special support for asynchronous
programming and that made it just as bad as JavaScript was. This
prompted me to add generators and `async/await keywords to Earl
Grey. And so I did.

There's something liberating about this, you know: seeing that
something is lacking, that some code is significantly more awkward
than it _should be... and then fixing it yourself. No need to wait for
the EcmaScript standards to address the problem, or for
[PEP0492]@@{pep0492} to be accepted in mainstream Python (that is a
done thing now), and so forth. You just... do it. Of course, it's no
small time investment, but once it works it is quite rewarding.

pep0492 => https://www.python.org/dev/peps/pep-0492/

But can you always do it, though? Can you always adapt?


== Inertia

There is a bit of a catch-22 in language design where the more a
language is used, the clearer it becomes which parts of it are
problematic and should change, but the harder it gets to actually
change them. To hone a language you must use it, but applications
require that a language's features remain stable, robust, set in
stone, and therefore as imperfect as they were at that
moment. Furthermore, the more delays are suffered in fixing flaws or
plugging holes, the more likely it gets that a dependency is fostered
upon them. The options you do not explicitly and insistently leave
open, tend to close and seal themselves before you know it.

Having very few users besides oneself helps, since you don't have to
worry too much about breaking libraries and applications besides your
own. For a long time, Earl Grey's sole and most important application
was the compiler itself. But _[even then], came moments where I
thought something ought to be changed, but doing so was nearly
impossible.

I made several changes in Earl Grey that were awkward to implement and
stopped short of implementing others because of how complicated it
would have been for me:

* I added a `method keyword at some point, and of course that broke
  all the instances I had of using `method as a variable. There
  were... quite a few.

* At some point I wanted to experiment with changing the behavior of
  the `[?]  operator (it performs runtime type checking,
  e.g. `[String? "hello"] returns true), but I deemed that it would
  break too much of what I already had.

* Same for the `[#] operator, where e.g. `[#point{1, 2}] is shorthand
  for `[{"point", 1, 2}]. I wanted to change that, but the compiler
  was already committed to the equivalence.

* For a long time I wanted to keep my options open as to whether
  accessing a field that didn't exist would raise an error or not. In
  JavaScript it doesn't, so I went with that default. Unfortunately,
  out of pure laziness, I came to rely on that behavior in a few
  cases. Then I forgot where I did that. Welp. Too late.

It feels strange that this would happen with only one user, but it
makes sense. You can only ever change features that are never used, or
used seldom enough that it is reasonable to change all existing
occurrences. In some cases it may be nigh impossible to identify what
has to be adapted, and then things must be set in stone.

I was aware that Earl Grey was necessarily going to be imperfect, but
it was interesting to see that even features that I could easily have
added in theory were becoming impossible. So it was "worse" than I
thought. I imagine it must be possible to foresee or prevent these
issues to some extent, but I expect it would be mostly through good
static analysis, and dynamic languages are more vulnerable to this
problem. I think Rust@@{rust} did it right, with a long period of
language design and refinement guided by application, but the
language's static nature and Mozilla's resources and support certainly
helped.

rust => https://www.rust-lang.org/


== About idiosyncrasy

Idiosyncrasy is that which is peculiar to you. Thoughts and ideas that
you think are interesting, seductive, an improvement over the state of
the art, but that other people don't perceive as such. If you get the
chance to have feedback about something you made, and you take care to
prod and listen, you will find out some interesting things.

I posted about Earl Grey [on Hacker News]@@{hn} a year ago or so to
get some feedback. That stressed me out, but the feedback was mostly
positive (yay!) Some people tried out the language and opened a few
issues. By far the greatest amount of discussion, next to jokes about
tea, was about one of Earl Grey's most insignificant features:
_[variable names can contain dashes]. For instance, `[the-value = 123]
is equivalent to `[theValue = 123]. Oh boy. Personally I like that a
lot, and I am not alone in this. Dashes in identifiers just look
good. Nonetheless it sparked a fierce bout of bikeshedding. I reckon
that this is actually the essence of programming language debate:
simple issues about which everyone can, and will have an opinion. Not
that this is an original thought, it is an old wisdom. But now when I
see bikeshedding elsewhere I have to wonder how the author feels about
that ocean of pointless bickering, spreading around the footnotes of
their work. Dry amusement, perhaps.

hn => https://news.ycombinator.com/item?id=9509070

The thing with bikeshedding is, if you observe it objectively, it
becomes clear that the main factor in anyone's preference is whatever
they are used to, and that reasons for that preference are usually
(although not always) reverse-engineered from there. I have
experimented a lot, before Earl Grey. For instance, I have tried all
combinations of brackets for function calls (`f(x), `f[x], `f{x}),
data structures, grouping and blocks. There is always a point where
whatever I was currently doing felt more natural, _nicer than the
alternatives. And I am willing to bet that if one forced themselves to
omit or use semicolons, use significant indent, use s-expressions,
whereas they never did before, that they would (often, but not always)
eventually end up preferring it to the alternative, regardless of what
they did before or after the switch. Of course this is mostly true of
cosmetic aspects, but even for important distinctions such as dynamic
versus static typing, I am not under the impression that most people
truly have a good grasp of the tradeoffs involved, and if they don't,
then their preference isn't grounded any better than their preference
for semicolons and whatnot.

One of the little cosmetic things in Earl Grey that feel natural to me
is the function declaration syntax:

& square(x) = x * x

For some reason I thought that this was clearly nicer than
alternatives. Cleaner, more mathematical. I was a bit surprised to
find out that most of the other people trying out my language
preferred an alternative notation, using the anonymous function
declaration syntax (`[argument -> expression]):

& square = x -> x * x

I thought it was interesting. And you know what else I find natural?
Writing subtraction as `[x - y] instead of `[x-y]. The first version
of Earl Grey did not allow dashes in variable names; but as it turned
out, save for one or two occurrences, I _always put spaces on each
side of the subtraction operator. So it was quite natural for me to
think that dashes in variable names would be nice, after all, how
could it ever be confused with subtraction?

Perhaps those who questioned that choice had a different idea about
what is natural to write. But they would probably get used to my way,
just like I could get used to theirs.


== Things I learned


There are many things I learned along this journey. Some of them I
already suspected, others are somewhat obvious, but they are all worth
listing.

The first thing is that __[programming languages are massive.]
Packages and libraries, editor and IDE support, tutorials and
documentation, questions and answers on Google and StackOverflow, all
these things accrete and gravitate around languages. And although the
field of programming language design is concerned with a language's
proper aspects, its syntax, semantics, performance profile, type
system, and so on, the fact is that when comes the time to write
complex applications, these aren't the things that matter most. If you
want to create a language that you can _use as quickly and
productively as possible, you have to compromise along those lines:
the most important being compatibility with as many existing libraries
as possible, and at a minimum, with the editor/tools you plan to use.

__[The things you feel the most passionately about are often the least
important.] Well, that's not entirely fair -- they can be pretty
important. But not as much as you think. For example, I cared a lot
about "purity" and making sure that every operator or syntactic
construct has one and only one "meaning" (for instance, I believe that
one shouldn't use braces to delimit both data structures and blocks,
because these are two incompatible semantics). But I never think about
"purity of design" when I actually _code. If purity is compromised to
make some common task easier to write, that will make me happier
whenever I have to perform that task, but when will I ever think about
how ugly the compromise is? Basically never, that's when.

__[It is never done.] There are always moments when the code you are
writing feels awkward or imperfect, as if the language struggled to
express some concepts elegantly. You can never figure that out in
advance, because you can't predict how all the features of your
language will interact with each other. Some of these combinations
will be unique, issues that can only happen in your language (which is
good, since it means it isn't a bland copy of everything else). One
has to resist the temptation fix every single issue and create bloat.
My strategy at the moment is to hold on implementing a feature until I
can recall a dozen times I wished for it.

__[It is isolating.] I like to do things alone, so that doesn't bother
me a lot. But it is still unsettling when you feel like you can't
participate in discussions about programming languages without
indulging into self-promotion, and when you can't really relate to
most people's experiences using mainstream languages. There is also a
shortage of toys to play with: I can use Emacs because I wrote
earl-mode myself. But I don't have Vim syntax definitions, so I can't
use that editor productively. I didn't have Atom definitions until
someone helpfully [wrote some]@@{egatom}. In any case it is clear that
language limits one's choice of tools and the support they can get
using them.

egatom => https://atom.io/packages/language-earl-grey

$$$Writing Earl Grey was an enlightening experience, and it still is,
since I am not fully done designing it, fixing bugs, improving it in
any way I can. It has become stable, with some parts true to my
original vision, others not. It has taught me a few things.

I must say I'm still itching to make a new programming language, or
more than one. It is a different itch, though, because I feel I
already have something nice going on, so I could write a language
that's experimental or limited in scope, maybe one language for each
idea I have, that would save the trouble of properly integrating them
with each other before knowing if they are any good.

I would write them in Earl Grey, of course.





;; throwaway [

= Getting a few users

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

]












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






Besides editor support, there is of course the issue of error
reporting. There is nothing more frustrating than errors you cannot
understand, or cannot trace. Unless you take good care to trace each
symbol in the original source code to the corresponding generated
code, the relationship between source and error will inevitably be
obfuscated. Source maps, thankfully, exist to alleviate the problem,
although I waited way too long to make use of them. Every time I save
a few minutes debugging something because the language tells me where
the problem is, I have to think of the minutes I spent on other bugs,
before I had that ability. It adds up, over time.

]

;; [
== Tooling


Languages don't exist in isolation, they come with a whole
menagerie. Editors, development environments, debuggers, and so
on. They cover them in makeup to highlight their features with every
color in the rainbow, point out errors here and there, helpfully
complete your thoughts, and so on, and so forth. But when a new
language is birthed, it has nothing of this. It is naked, black on
white, or white on black, or whatever fancy colors you choose to use
by default, like turquoise on burgundy. No annotations, automatic
completion, no linting... not many people are comfortable coding in
such an environment.

It's not necessarily a pressing matter if you are implementing your
language in an established language like, say, C++, which has plenty
of tools. Alas, I was writing Earl Grey in Earl Grey. I needed
_something. Thankfully my needs are limited: some Emacs Lisp to
highlight the features I needed and I was pretty much
set. Nonetheless, there is something to be said about all the tools
one has to either remake or forfeit because they cannot be abstracted
from a language to another.

Truth is, support systems for programming languages are
_immense. Languages are supported by packages and libraries, by syntax
highlighting, IDE support, debuggers, online documentation,
communities on sites such as StackOverflow, paid support, and so
on. Brand new languages have _nothing. They can, as I have done, play
nice with existing ecosystems so that they can use another language's
packages and libraries. Source map support can help too, with some
editors and debuggers. Still, people will only use languages that
cater to their needs, and many people demand a lot (not that they
aren't entitled to). A language designer will put up with whatever
they make, but it is still an isolating force: all these editors, all
these toys, out of reach.



= MORE




There are many factors behind
"mainstream" success that I believe are stronger than the language's
ideas or academic merits. Support from large corporations comes to
mind (Jave, C#, Go, and so on) along with chance or opportunism


To name a few, there is support from a large
corporation (Java, C#, Go), opportunism (Coffeescript), being used by
its authors to create groundbreaking software (C, to write UNIX, or
Ruby on Rails), necessity (JavaScript, Objective-C and now Swift), or
regular human sacrifice to the bull-headed god Moloch (I dare you to
find a better explanation for PHP's continued existence). Not that
these languages are bad, but even when they are good, the principal
drive behind their success isn't their quality. If one wants to
improve the state of programming languages, the best thing they could
possibly do would be to figure out a way to "fast-track" these
hundreds of worthy concepts and ideas from fringe languages and
academic papers to public awareness, so that people would actually try
them out.


]



store nav ::
  ;; a %
    href = http://breuleux.github.io/earl-grey/
    img %
      src = {documents.meta.getRaw("siteRoot")}/assets/earlgrey-text.svg
      width = 200px
      style = padding: 10px;
  .extra %
    [Earl Grey]@@{earlgrey}
    a.github-button %
      href = https://github.com/breuleux/earl-grey
      data-icon = octicon-star
      data-count-href = /breuleux/earl-grey/stargazers
      data-count-api = /repos/breuleux/earl-grey#stargazers_count
      data-count-aria-label = # stargazers on GitHub
      aria-label = Star breuleux/earl-grey on GitHub
      Star
    script#github-bjs %
      async = true
      defer = true
      src = https://buttons.github.io/buttons.js
  toc ::

earlgrey => http://breuleux.github.io/earl-grey/

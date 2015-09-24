
meta ::
  template = default
  id = 21
  title = The taste of dog food
  tagline =
    Or the stress and elation of using a programming language you
    designed yourself.
  author = Olivier Breuleux
  date = 2015/08/31
  language = English
  category = Programming
  tags = {O-Expressions, S-expressions, Earl Grey, Programming Languages}
  comments = false
  list = true


__[As basically nobody knows], I have been designing a new programming
language for the past year or so called [Earl Grey]@@{earlgrey}. It's
pretty cool. I think. I hope. But I am not here to talk about the
language's wondrous features and how using it is a life-changing
experience that will make you feel like an eagle soaring over
mountains of algorithmic beauty, light yet powerful. No... no, that's
something you will have to experience for yourself.

I am rather going to try and communicate to you the experience of
being a solo mule-headed programming language designer who decided to
create a language for their own benefit. The reasoning here is simple:
instead of adapting to an existing language (like I imagine most sane
individuals do, and I did for a time), I was going to design the
language best adapted to my own way of thinking and recoup the
investment over the time I would save myself. I do believe that this
is the idea behind most new languages: you learn an existing language,
you like it well enough, but there are things about it that bother
you, so you decide to "fix" it. I imagine most of the people who are
still reading have had that thought at some point. We could debate
endlessly about the merits of _actually doing it, but I think that in
a way, it is possible for a language to be worth creating even if it
only has a single user, _if it can make that user's life better. Which
is no easy task.


__[Usefulness constrains design.] Unless you have lots of money and
resources to throw at the problem, or enough luck to entice others to
use your language and make it flourish, the simple fact of the matter
is that a useful language needs to empower you to do the things you
want to do, and the least that needs to be done to get to this state,
the better. And the fact of the matter is that I need to be able to
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


__[Then I had to make tools]. Tooling sucks, or at least the need for
it does. Different programmers have different expectations regarding
what they expect their tools to do for them. Some, like me, mostly get
by with syntax highlighting and auto-indent. Others need a more
complete environment to be comfortable and feel productive. Fine by
me. The thing is, though, when you make a new language, you have
nothing at all. No colors, no rules, just black on white text, or
white on black, or whatever fancy colors you choose to use by default,
like turquoise on burgundy or whatever. Not many people are
comfortable coding in such an environment.

It's not necessarily a pressing matter if you are coding your language
in an established language like, say, C++, which has plenty of tools,
but as I mentioned, I was now making Earl Grey in Earl Grey. I needed
_something. Thankfully, I'd been toying with language design a lot
before Earl Grey, and I had once designed an Emacs mode for an old
attempt. It took me a day or two, but I managed to adapt it to my new
vision.


__[There is a bit of a catch-22 in language design] where the more a
language is used, the clearer it becomes which parts of it are
problematic and should change, but the harder it gets to actually
change them. Furthermore, the more delays are suffered in fixing flaws
or plugging holes, the more likely it gets that a dependency is
fostered upon them. The options you do not explicitly and insistently
leave open, tend to close and seal themselves before you know it.

Having very few users besides oneself helps, since you don't have to
worry too much about breaking libraries and applications besides your
own. For a long time, Earl Grey's sole and most important application
was the compiler itself






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


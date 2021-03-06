
template :: title

meta ::
  title = About me
  author = Olivier Breuleux

githubi =>
  img %
    title = breuleux
    src = {documents.meta.getRaw("siteRoot")}assets/github.png
    height = 20pt
    alt = breuleux on GitHub

;;
  img.github-image %
    title = breuleux
    src = {siteroot}assets/github.png
    height = 16px
    alt = breuleux on GitHub
  twitter =>
    img %
      title = @broolucks
      src = {siteroot}assets/twitter.png
      height = 50px
      alt = @broolucks
  {github} @@ https://github.com/breuleux
  {twitter} @@ https://twitter.com/broolucks

github => https://github.com/breuleux

I don't really like to say things about myself. So I won't.

I do like to talk about the random projects I start, though. You can
check them out on [GitHub {githubi}]@@{github} or read about them here:


[horb :: \text] => ornate L2+2L :: h1 % {text}


horb :: current projects


hpl => http://histoirespourlecteurs.com
ow => http://outsideword.com

div.project %
  .project-title %
    onclick = window.location = '{ow}';
    inherit %
      style = width:100px
      @@@image:assets/ow.png
    The Outside Word @@ {ow}
  .project-description %
    A site where my sister and I post __[short stories @@ {ow}],
    updated every Sunday. It was made with Quaint and Earl Grey
    (see below).
    Also available [in French @@ {hpl}].


earlgrey => https://breuleux.github.io/earl-grey/

div.project %
  .project-title %
    onclick = window.location = '{earlgrey}';
    inherit %
      @@@image:assets/earlgrey.svg
    Earl Grey @@ {earlgrey}
  .project-description %
    __ Earl Grey is a new programming language. @@ {earlgrey}
    It compiles to JavaScript and has a lot of neat features such as
    pattern matching and macros. Earl Grey is my language of choice
    for all my new programming projects, so even if nobody else uses
    it, well, I do.


quaint => https://breuleux.github.io/quaint

div.project %
  .project-title %
    onclick = window.location = '{quaint}';
    @@@image:assets/quaint.png
    Quaint @@ {quaint}
  .project-description %
    __ Quaint is a new markup language. @@ {quaint}
    It is simple and looks a bit like Markdown, but it is more regular
    and very easy to extend. It is possible to write macros in Quaint
    to simplify repetitive operations. Quaint is written in [Earl
    Grey]@@{earlgrey}. This blog is written in Quaint.


horb :: unmaintained

terminus => https://github.com/breuleux/terminus

div.project %
  .project-title %
    onclick = window.location = '{terminus}';
    @@@image:assets/terminus.png
    Terminus @@ {terminus}
  .project-description %
    __ Terminus is an HTML terminal. @@ {terminus}
    It works just like a normal VT100 terminal, the escape codes work,
    you can run emacs or vi inside it if you want. Terminus's
    distinguishing feature, though, is that you can embed HTML inside
    your workflow. So you can print actual tables, plots, and so on,
    inline.


horb :: I also worked on

theano => http://deeplearning.net/software/theano/

div.project %
  .project-title %
    onclick = window.location = '{theano}';
    @@@image:assets/theano.png
    Theano @@ {theano}
  .project-description %
    __ Theano is an arithmetic expression compiler. @@ {theano}
    It is a Python package which can do symbolic differentiation and
    analysis of arithmetic expressions, and then compile them to
    efficient specialized code to run on CPU or GPU. It is mainly used
    in research on deep neural networks. I am one of the founding
    developers and have worked on it from 2008 to 2010 at the LISA lab
    at University of Montreal. I have since stopped working on it
    personally, but it is still actively maintained.


horb :: papers

Selected publications (or maybe that's all of them, who knows):

fpcdpaper =>
  http://www.iro.umontreal.ca/\~lisa/pointeurs/breuleux+bengio_nc2011.pdf

p.paper %
  O. Breuleux, Y. Bengio and P. Vincent
  [“Quickly Generating Representative Samples from an RBM-Derived Process”]@@{fpcdpaper}.
  _ Neural Computation, August 2011, Vol. 23, No. 8, Pages 2058-2073


theanopaper =>
  http://www.iro.umontreal.ca/\~lisa/pointeurs/theano_scipy2010.pdf

p.paper %
  J. Bergstra, O. Breuleux, F. Bastien, P. Lamblin, R. Pascanu,
  G. Desjardins, J. Turian, D. Warde-Farley and Y. Bengio.
  [“Theano: A CPU and GPU Math Expression Compiler”]@@{theanopaper}.
  _ Proceedings of the Python for Scientific Computing Conference
    (SciPy) 2010. June 30 - July 3, Austin, TX




horb :: contact me

myemail => breuleux@gmail.com

You can send me email at
[{myemail} @@ mailto:{myemail}]
and maybe I'll even read it!


ornate :: 1


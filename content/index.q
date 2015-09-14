
meta ::
  title = Olivier Breuleux's blog
  author = Olivier Breuleux
  template = plain

ornate :: 131

[horb :: \text] => ornate L2+2L :: h2 % {text}

div.intro %
  Hello! Welcome to __[Olivier Breuleux]@@about.html~'s humble slice of the web :\)

horb :: articles

{
  require: moment
  require: lodash
  n = null
  sorted = lodash.sort-by{articles} with {x} -> x.date??.raw{}
  final-list = if{n, lodash.take{sorted.reverse{}, n}, sorted.reverse{}}
  ul.articles %
    final-list each article when eval{article.list??.raw{}} ->
      li.postbit %
        onclick = 'window.location = \'{article.url}\''
        a %
          href = article.url
          article.title??.raw{} or "Untitled"
        .date % moment{article.date??.raw{}, "YYYY/MM/DD"}.format{"MM/YYYY"}
        .tagline % engine.gen{article.tagline}
}

ornate :: 1


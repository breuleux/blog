
template :: plain

meta ::
  title = Olivier Breuleux's blog
  author = Olivier Breuleux

ornate :: 131

[horb :: \text] => ornate L2+2L :: h2 % {text}

div.intro %
  Hello! Welcome to __[Olivier Breuleux]@@about.html~'s humble slice of the web :\)

horb :: articles

articles => data :: meta.json

{
  require: moment
  require: lodash
  n = null
  a = engine.gen{articles}
  var res = lodash.sort-by{items{a} each {k, v} -> v} with x -> x.date
  res = res.reverse{}
  sorted = if{n, lodash.take{res, n}, res}
  ul.articles %
    sorted each article when article.list ->
      li.postbit %
        onclick = 'window.location = \'{article.localUrl}\''
        a %
          href = article.localUrl
          article.title or "Untitled"
        span.date % moment{article.date, "YYYY/MM/DD"}.format{"MM/YYYY"}
        span.tagline % engine.gen{article.tagline} 
}


ornate :: 1

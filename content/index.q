
template :: plain

meta ::
  title = Olivier Breuleux's blog
  author = Olivier Breuleux

ornate :: 131

[horb :: \text] => ornate L2+2L :: h1 % {text}

div.intro %
  Hello! Welcome to __[Olivier Breuleux]@@about.html~'s humble slice of the web :\)

horb :: articles

articles => data :: meta.json

css ::
  #main-container .postbit > a {
    text-decoration: none;
  }
  #main-container .postbit > a:hover {
    text-decoration: underline;
  }

ul.articles %
  each data::meta.json x data ::
    {data.list} ??
      li.postbit %
        onclick = window.location = '{data.localUrl}'
        {data.title}!!Untitled @@ {data.localUrl}
        span.date % {
          require: moment
          moment{data.date, "YYYY/MM/DD"}.format{"MM/YYYY"}
        }
        span.tagline % {data.tagline}


ornate :: 1

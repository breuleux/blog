doctype :: html
html %
  head %
    title %
      [meta::title !! Untitled][meta::tagline ?? [ - meta::tagline]]
    meta %
      name = description
      content = {documents.meta.get{"tagline"}}
    meta %
      name = author
      content = {documents.meta.get{"author"}}
    meta %
      name = keywords
      content = programming,blog
    meta %
      http-equiv = Content-type
      content = text/html
      charset = UTF-8
    meta %
      name = viewport
      content = width=device-width
      initial-scale = 1
    dump :: head
  body % {body}
head ::
  meta %
    property = og:site_name
    content = Olivier Breuleux's Blog
  meta %
    property = og:url
    content = {documents.meta.get{"url"}}
  meta %
    property = og:type
    content = article
  meta %
    property = og:title
    content = {documents.meta.get{"title"}}
  meta %
    property = og:description
    content = {documents.meta.get{"tagline"}}
  meta %
    property = og:image
    content = {documents.meta.get{"hostname"} + "/assets/greendisk.png"}
  meta %
    property = article:published_time
    content = {documents.meta.get{"date"}.replace{R.g"/", "-"}}

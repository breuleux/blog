doctype :: html
html %
  head %
    title %
      [meta::title !! Untitled][meta::tagline ?? [ - meta::tagline]]
    meta %
      http-equiv = Content-type
      content = text/html
      charset = UTF-8
  body % {body}

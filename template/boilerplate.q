
raw % <!DOCTYPE html>

html %

  head %
    meta %
       http-equiv = Content-type
       content = text/html
       charset = UTF-8
    title % meta :: title
    link %
       rel = stylesheet
       type = text/css
       href = {
         s = doc.meta.get{.style}??.raw{} or "style"
         '{siteroot}style/{s}.css'
       }
    script %
       src = {siteroot}lib/social-popup.js
    resources :: !dump!

  body %
    {body}
    resources :: !run!

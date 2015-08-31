
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
       href = {siteroot}style/style.css
    {
       incl = doc.meta.get{.include}??.raw{} or ""
       incl.split{R" *\n *"} each
          "" -> ""
          R".css$"? lnk ->
             link %
                rel = "stylesheet"
                type = "text/css"
                href = if{lnk[0]=="/", siteroot + lnk.slice{1}, lnk}
          R".js$"? script ->
             script %
                src = if{script[0]=="/", siteroot + script.slice{1}, script}
    }

  body %
    {body}

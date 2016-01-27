
template :: nav

div#title-container %
  div#title %
    div.title % meta :: title!

div#main-container.container %
  div#main %
    div.tagline % [meta :: tagline!] !! []
    {body}
    div.signature %
       [meta :: author]@@@about {
          require: moment
          date = moment{x, "YYYY/MM/DD"} where
             x = doc.meta.get{"date"}
          if date.is-valid{}:
             span.date % date.format{"MMMM DD, YYYY"}
          else:
             ""
       }

    share ::
      facebook
      twitter
      google+
      reddit
      email

    ornate :: 1

    meta::comments ??
      disqus ::

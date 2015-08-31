
meta :: template = nav

div#main-container.container %
  div#main %
    div.title % meta :: title
    div.tagline % meta :: tagline
    {body}
    div.signature %
       [meta :: author]@@@about {
          require: moment
          date = moment{x, "YYYY/MM/DD"} where
             x = doc.meta.get{"date"}??.raw{}
          if date.is-valid{}:
             span.date % date.format{"MMMM DD, YYYY"}
          else:
             ""
       }

    ornate :: 1

    {raw % '<script>postId = {doc.meta.get{"id"}??.raw{}}</script>'}
    
    comments =>
      div % id = disqus_thread
      js ::
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        var disqus_shortname = 'breuleux';
        var disqus_identifier = 'breuleux-blog-' + postId;
        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
          var dsq = document.createElement('script');
          dsq.type = 'text/javascript';
          dsq.async = true;
          dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
          (document.getElementsByTagName('head')[0]
           || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
      noscript %
        Please enable JavaScript to view the
        [comments powered by Disqus.]@@http://disqus.com/?ref_noscript
      ;; a.dsq-brlink %
        href = http://disqus.com
        comments powered by [.logo-disqus % Disqus]
    
    {if{eval{doc.meta.get{"comments"}??.raw{}}, comments, ""}}

    js ::
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
      ga('create', 'UA-42450029-1', 'breuleux.net');
      ga('send', 'pageview');


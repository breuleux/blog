
template :: @minimal

logo =>
  img %
    src = {documents.meta.getRaw{"siteRoot"}}assets/home.svg
    height = 70px
    alt = Olivier Breuleux's blog

div#nav-container %
  div#nav %
    div #logo % {logo} @@@ index
    store nav :: dump!

{body}

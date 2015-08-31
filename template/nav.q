
meta :: template = boilerplate

logo =>
  img %
    src = {siteroot}assets/home.svg
    height = 70px
    alt = Olivier Breuleux's blog

div#nav-container.container %
  div#nav %
    div #logo % {logo} @@ {siteroot}index.html
    store nav :: dump!

{body}

div#foot-container.container %
  div#foot %
    .footlink % []

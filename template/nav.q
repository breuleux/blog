
template :: boilerplate

logo =>
  inherit %
    height = 70px
    [Olivier Breuleux's blog] @@@ image:assets/home.svg

div#nav-container %
  div#nav %
    div #logo % {logo} @@@ index.html
    store nav :: dump!

{body}

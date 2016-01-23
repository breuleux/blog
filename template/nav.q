
template :: boilerplate

logo =>
  inherit %
    height = 70px
    [Olivier Breuleux's blog] @@@ image:home.svg

div#nav-container %
  div#nav %
    div #logo % {logo} @@@ index
    store nav :: dump!

{body}

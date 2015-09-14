// Got this from: http://www.sitepoint.com/social-media-button-links/
// create social networking pop-ups

function configurePopups() {
    // link selector and pop-up window size
    var Config = {
	Link: "a.share",
	Width: 500,
	Height: 500
    };

    // add handler links
    var slink = document.querySelectorAll(Config.Link);
    for (var a = 0; a < slink.length; a++) {
	slink[a].onclick = PopupHandler(slink[a].href);
    }

    // create popup
    function PopupHandler(href) {
        return function (e) {
	    // popup position
	    var px = Math.floor(((screen.availWidth || 1024) - Config.Width) / 2),
	        py = Math.floor(((screen.availHeight || 700) - Config.Height) / 2);

	    // open popup
	    var popup = window.open(href, "social", 
			            "width="+Config.Width+",height="+Config.Height+
			            ",left="+px+",top="+py+
			            ",location=0,menubar=0,toolbar=0,status=0,scrollbars=1,resizable=1");
	    if (popup) {
	        popup.focus();
	        if (e.preventDefault) e.preventDefault();
	        e.returnValue = false;
	    }
	    return !!popup;
        }
    }
}

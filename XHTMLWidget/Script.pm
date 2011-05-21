# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::XHTMLWidget::Script;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Widget::Script';
#use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub JAVASCRIPT_TOGGLE_FORM {
    return <<'EOF';
function toggle_form() {
    var i = document.getElementById("c4_inputs");
    var t = document.getElementById("c4_inputs_toggle_button");
    var s = i.currentStyle || window.getComputedStyle(i, null);
    if (s.display == "none") {
        i.style.display = "block";
        t.innerHTML = "&#9650;";
    } else {
        i.style.display = "none";
        t.innerHTML = "&#9660;";
    }
}
function font_size(increase) {
   var b = document.getElementsByTagName('body');
   for(i = 0; i < b.length; i++) {
       var cs = b[i].currentStyle || window.getComputedStyle(b[i], null);
       var fs = parseInt(cs.fontSize.replace("px",""));
       if (increase) {
           fs += 1;
       } else {
           fs -= 1;
       }
       if(fs > 32) {
           fs = 32;
       }
       if (fs < 8) {
           fs = 8;
       }
       b[i].style.fontSize = fs+"px";
    }
}
EOF
}

1;

// ==UserScript==
// @name           twitter-highlight-login
// @namespace      rjp
// @include        http://twitter.com/*
// ==/UserScript==

// <meta content="zimpenfish" name="session-user-screen_name" />

function insertAfter(newNode, node) {
  return node.parentNode.insertBefore(newNode, node.nextSibling);
}

var snapTextNodes = null;
var twitterUser = null;

snapTextNodes = document.evaluate("//meta[@name='session-user-screen_name']", document, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);

for (var i = snapTextNodes.snapshotLength - 1; i >= 0; i--) {
	var elm = snapTextNodes.snapshotItem(i);
	twitterUser = elm.getAttribute('content');
}

if (twitterUser) {
	document.getElementById('profile_link').innerHTML = "<small><em style='color: green'>"+twitterUser+"</em></small>";
	var iam = "<span style='color: green;font-size:x-small'>(I AM: "+twitterUser+")</span>";
	var stn = document.evaluate("//div[@class='screen-name']", document, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null).snapshotItem(0);
	stn.innerHTML = stn.innerHTML + " <small>" + iam + "</small>";
}

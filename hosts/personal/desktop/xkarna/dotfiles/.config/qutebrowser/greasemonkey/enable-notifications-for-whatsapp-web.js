// ==UserScript==
// @name        Fix Notifications
// @description Hits the notification button, once
// @version     1.0
// @namespace   https://web.whatsapp.com/
// @match       https://web.whatsapp.com/*
// @run-at document-idle
// @grant       none
// ==/UserScript==
(function() {
    'use strict';

    var waitForThatFrickingButton = setInterval(function() {
        let xpath = "//button[text()='Turn on']";
        let button = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
        if(button) {
            button.click();
            clearInterval(waitForThatFrickingButton);
        }
    }, 500)
})();

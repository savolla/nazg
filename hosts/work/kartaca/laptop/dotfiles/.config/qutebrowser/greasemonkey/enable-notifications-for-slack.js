// ==UserScript==
// @name        Fix Notifications
// @description Hits the notification button, once
// @version     1.0
// @namespace   https://app.slack.com/
// @match       https://*.slack.com/*
// @match       https://*.slack-edge.com/*
// @run-at document-idle
// @grant       none
// ==/UserScript==
(function() {
    'use strict';

    var waitForThatFrickingButton = setInterval(function() {
        let xpath = "//button[text()='Enable notifications']";
        let button = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
        if(button) {
            button.click();
            clearInterval(waitForThatFrickingButton);
        }
    }, 500)
})();

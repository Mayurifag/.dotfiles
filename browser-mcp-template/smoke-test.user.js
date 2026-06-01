// ==UserScript==
// @name         Browser MCP Smoke Test
// @namespace    browser-mcp-template
// @version      0.0.1
// @description  Verifies Tampermonkey injection on Wikipedia.
// @match        https://www.wikipedia.org/*
// @grant        none
// ==/UserScript==

console.log("browser-mcp wikipedia userscript smoke test");
document.documentElement.dataset.browserMcpWikipediaSmokeTest = "ok";

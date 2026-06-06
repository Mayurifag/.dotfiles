// ==UserScript==
// @name         Browser MCP Smoke Test
// @namespace    browser-mcp-template
// @version      0.0.2
// @description  Verifies Tampermonkey injection on Wikipedia.
// @match        https://www.wikipedia.org/*
// @grant        none
// ==/UserScript==

console.log("browser-mcp wikipedia userscript smoke test");
const markBrowserMcpSmokeTest = () =>
  document.documentElement.setAttribute(
    "data-browser-mcp-wikipedia-smoke-test",
    "ok",
  );
markBrowserMcpSmokeTest();
document.addEventListener("DOMContentLoaded", markBrowserMcpSmokeTest, {
  once: true,
});
setTimeout(markBrowserMcpSmokeTest, 1000);

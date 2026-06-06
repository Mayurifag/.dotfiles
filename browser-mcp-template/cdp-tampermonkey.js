#!/usr/bin/env node

const http = require("http");
const child = require("child_process");
const zlib = require("zlib");

const BASE_PORT = 9223;
const PORT_SPAN = 1000;
function repoRoot() {
  try {
    return (
      child
        .execFileSync("git", ["rev-parse", "--show-toplevel"], {
          cwd: process.cwd(),
          encoding: "utf8",
          stdio: ["ignore", "pipe", "ignore"],
        })
        .trim() || process.cwd()
    );
  } catch {
    return process.cwd();
  }
}
const PORT =
  process.env.OPENCODE_BROWSER_MCP_PORT ||
  process.env.BROWSER_MCP_PORT ||
  String(BASE_PORT + (zlib.crc32(Buffer.from(repoRoot())) % PORT_SPAN));
const BASE = `http://127.0.0.1:${PORT}`;
const TM = "dhdgffkkebhmkfjojejmpbldmpobfkfo";
const WEBSTORE_URLS = [
  "https://chromewebstore.google.com/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo",
  "https://chromewebstore.google.com/detail/stylus/clngdbkpkpeebahjckkjfobafhncgmne",
  "https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh",
  "https://chromewebstore.google.com/detail/stylebot/oiaejidbmkiecgbjeifoejpgmdaleoha",
];
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const getJson = (url) =>
  new Promise((resolve, reject) => {
    http
      .get(url, (res) => {
        let data = "";
        res.on("data", (chunk) => (data += chunk));
        res.on("end", () => {
          try {
            resolve(JSON.parse(data));
          } catch {
            resolve(data);
          }
        });
      })
      .on("error", reject);
  });

async function target(prefix) {
  const list = await getJson(`${BASE}/json/list`);
  const found = list.find((item) => item.url?.startsWith(prefix));
  if (!found) throw new Error(`target not found: ${prefix}`);
  return found;
}

async function cdp(webSocketDebuggerUrl) {
  const ws = new WebSocket(webSocketDebuggerUrl);
  await new Promise((resolve, reject) => {
    ws.onopen = resolve;
    ws.onerror = reject;
  });
  let id = 0;
  const send = (method, params = {}) =>
    new Promise((resolve, reject) => {
      const msg = ++id;
      const timer = setTimeout(
        () => reject(new Error(`${method} timeout`)),
        5000,
      );
      const onMsg = (event) => {
        const data = JSON.parse(event.data);
        if (data.method === "Page.javascriptDialogOpening") {
          ws.send(
            JSON.stringify({
              id: ++id,
              method: "Page.handleJavaScriptDialog",
              params: { accept: true },
            }),
          );
        }
        if (data.id !== msg) return;
        clearTimeout(timer);
        ws.removeEventListener("message", onMsg);
        resolve(data);
      };
      ws.addEventListener("message", onMsg);
      ws.send(JSON.stringify({ id: msg, method, params }));
    });
  return { ws, send };
}

async function evalTarget(prefix, expression) {
  const page = await target(prefix);
  const client = await cdp(page.webSocketDebuggerUrl);
  await client.send("Page.enable");
  const result = await client.send("Runtime.evaluate", {
    expression,
    returnByValue: true,
  });
  client.ws.close();
  return result.result.result.value;
}

const commands = {
  "open-webstore-tabs": async () => {
    const before = (await getJson(`${BASE}/json/list`)).filter(
      (page) => page.type === "page",
    );
    const version = await getJson(`${BASE}/json/version`);
    const browser = await cdp(version.webSocketDebuggerUrl);
    const keep = new Set();
    for (const url of WEBSTORE_URLS) {
      const created = await browser.send("Target.createTarget", {
        url,
        background: true,
      });
      keep.add(created.result.targetId);
    }
    for (const page of before) {
      if (!keep.has(page.id)) {
        await browser.send("Target.closeTarget", { targetId: page.id });
      }
    }
    let after = [];
    for (let i = 0; i < 50; i++) {
      after = (await getJson(`${BASE}/json/list`)).filter(
        (page) => page.type === "page",
      );
      if (
        after.length === WEBSTORE_URLS.length &&
        after.every(
          (page) =>
            keep.has(page.id) &&
            page.url.startsWith("https://chromewebstore.google.com/detail/"),
        )
      ) {
        break;
      }
      await delay(100);
    }
    browser.ws.close();
    return after.map((page) => page.url);
  },
  "webstore-urls": () => WEBSTORE_URLS,
  install: () =>
    evalTarget(
      `chrome-extension://${TM}/ask.html`,
      `(() => {
    const button = Array.from(document.querySelectorAll("input[type=button],button"))
      .find((el) => (el.value || el.innerText).trim() === "Install");
    if (!button) return { clicked: false, text: document.body.innerText.slice(0, 500) };
    button.click();
    return { clicked: true };
  })()`,
    ),
  "delete-smoke": () =>
    evalTarget(
      `chrome-extension://${TM}/options.html`,
      `(() => {
    const items = Array.from(document.querySelectorAll("i[title=Delete],.button,input,button"))
      .filter((el) => ["Delete", "Delete all"].includes((el.value || el.innerText || el.title || "").trim()) || el.title === "Delete");
    for (const item of items) item.click();
    return { clicked: items.length, text: document.body.innerText.slice(0, 1000) };
  })()`,
    ),
};

const command = process.argv[2];
if (!commands[command]) {
  console.error(
    `Usage: ${process.argv[1]} open-webstore-tabs|webstore-urls|install|delete-smoke`,
  );
  process.exit(2);
}

Promise.resolve(commands[command]())
  .then((value) => console.log(JSON.stringify(value)))
  .catch((error) => {
    console.error(error.stack || error);
    process.exit(1);
  });

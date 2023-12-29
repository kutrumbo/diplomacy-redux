#!/usr/bin/env node

const path = require('path')
const http = require('http')

const clients = []

require("esbuild").context({
  entryPoints: ["application.jsx"],
  bundle: true,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  sourcemap: true,
  loader: {
    ".jpg": "file",
    ".svg": "file",
    ".js": "jsx",
  },
  banner: {
    js: ' (() => new EventSource("http://localhost:8082").onmessage = () => location.reload())();',
  },
}).then(ctx => {
  ctx.watch();
}).catch(() => process.exit(1));

http.createServer((_, res) => {
  console.log('in here');
  return clients.push(
    res.writeHead(200, {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "Access-Control-Allow-Origin": "*",
      Connection: "keep-alive",
    }),
  );
}).listen(8082);
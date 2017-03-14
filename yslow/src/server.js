#!/usr/bin/env node

const http = require('http');
const { spawn } = require('child_process');
const url = require('url');

const PORT = 8080;

function getRequestQuery(request) {
  const urlParts = url.parse(request.url, true);
  return urlParts.query;
}

function runYslow(target) {
  return new Promise((resolve, reject) => {
    const yslowCommand = spawn('phantomjs', [ '/yslow/yslow.js', target ]);
    let result = '';
    yslowCommand.stdout.on('data', (data) => {
      result += data;
    });
    yslowCommand.stderr.on('data', (data) => {
      result += data;
    });
    yslowCommand.on('close', (code) => {
      if (code === 0) {
        try {
          resolve(JSON.parse(result));
        } catch (e) {
          reject(result);
        }
      } else {
        reject(result);
      }
    });
  });
}

function handleRequest(req, res) {
  const query = getRequestQuery(req);
  if (!query.url) {
    res.writeHead(400);
    res.end('URL query parameter is needed');
  } else {
    console.log('Request received for %s...', query.url);
    runYslow(query.url).then(result => {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(result));
      console.log('Request for %s processed successfully', query.url);
    }).catch(err => {
      res.writeHead(500);
      res.end(JSON.stringify(err));
      console.error('Request for %s processed with error: %s', query.url, err);
    });
  }
}

const server = http.createServer(handleRequest);

server.listen(PORT, function () {
  console.log('Server listening on port %s', PORT);
});

process.on('SIGINT', function () {
  console.log('SIGINT signal received');
  process.exit();
});

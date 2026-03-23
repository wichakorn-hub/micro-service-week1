import http from 'node:http';
import crypto from 'node:crypto';

const port = Number.parseInt(process.env.PORT ?? '', 10) || 8018;

const server = http.createServer((req, res) => {
  const traceId = req.headers['x-trace-id']?.toString() || crypto.randomUUID();
  const timestamp = new Date().toISOString();
  const path = (req.url || '/').split('?')[0];

  if (req.method !== 'GET' || path !== '/') {
    console.log(
      JSON.stringify({
        code: 404,
        message: 'Not Found',
        method: req.method,
        path,
        trace_id: traceId,
        timestamp,
      }),
    );
    res.statusCode = 404;
    res.end();
    return;
  }

  console.log(
    JSON.stringify({
      code: 200,
      message: 'OK',
      method: req.method,
      path,
      trace_id: traceId,
      timestamp,
    }),
  );
  res.setHeader('Content-Type', 'application/json');
  res.end(
    JSON.stringify({
      status: 'success',
      message: 'Hello JavaScript',
      timestamp: new Date().toISOString(),
    }),
  );
});

server.listen(port, '127.0.0.1', () => {
  console.log(`Starting server at http://127.0.0.1:${port}`);
});


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
      timestamp: new Date().toISOString(),
      level: 'info',
      service: 'javascript-api',
      message: `${req.method} ${path} success`,
      request: {
        method: req.method,
        url: path,
        headers: {
          'user-agent': req.headers['user-agent'] || '',
        },
        ip: req.socket.remoteAddress || '127.0.0.1',
      },
      response: {
        status_code: 200,
        response_time_ms: 12,
      },
      meta: {
        request_id: traceId,
        user_id: 42,
      }
    }),
  );
});

server.listen(port, '127.0.0.1', () => {
  console.log(`Starting server at http://127.0.0.1:${port}`);
});


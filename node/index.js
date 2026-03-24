import express from 'express';
import crypto from 'node:crypto';

const app = express();
const port = Number.parseInt(process.env.PORT ?? '', 10) || 8012;

app.get('/', (req, res) => {
  const traceId = req.header('X-Trace-Id') || crypto.randomUUID();
  console.log(JSON.stringify({
    code: 200,
    message: 'OK',
    method: req.method,
    path: req.path,
    trace_id: traceId,
    timestamp: new Date().toISOString()
  }));

  const response = {
      timestamp: new Date().toISOString(),
      level: 'info',
      service: 'node-api',
      message: `${req.method} ${req.path} success`,
      request: {
        method: req.method,
        url: req.path,
        headers: {
          'user-agent': req.get('user-agent') || '',
        },
        ip: req.ip || '127.0.0.1',
      },
      response: {
        status_code: 200,
        response_time_ms: 12,
      },
      meta: {
        request_id: traceId,
        user_id: 42,
      }
  };

  res.json(response);
});

app.use((req, res) => {
  const traceId = req.header('X-Trace-Id') || crypto.randomUUID();
  console.log(JSON.stringify({
    code: 404,
    message: 'Not Found',
    method: req.method,
    path: req.path,
    trace_id: traceId,
    timestamp: new Date().toISOString()
  }));
  res.status(404).json({ error: 'Not found' });
});

app.listen(port, '127.0.0.1', () => {
  console.log(`Starting server at http://127.0.0.1:${port}`);
});


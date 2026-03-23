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
    status: 'success',
    message: 'Hello node',
    timestamp: new Date().toISOString()
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


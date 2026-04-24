import json
import os
import uuid
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer


def _port() -> int:
    try:
        p = int(os.environ.get("PORT", "8017"))
        return p if 1 <= p <= 65535 else 8017
    except ValueError:
        return 8017


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):  # noqa: N802
        trace_id = self.headers.get("X-Trace-Id") or str(uuid.uuid4())
        timestamp = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

        if self.path != "/":
            print(
                json.dumps(
                    {
                        "code": 404,
                        "message": "Not Found",
                        "method": "GET",
                        "path": self.path,
                        "trace_id": trace_id,
                        "timestamp": timestamp,
                    }
                )
            )
            self.send_response(404)
            self.end_headers()
            return

        print(
            json.dumps(
                {
                    "code": 200,
                    "message": "OK",
                    "method": "GET",
                    "path": self.path,
                    "trace_id": trace_id,
                    "timestamp": timestamp,
                }
            )
        )
        body = json.dumps(
            {
                "timestamp": timestamp,
                "level": "info",
                "service": "python-api",
                "message": f"{self.command} {self.path} success",
                "request": {
                    "method": self.command,
                    "url": self.path,
                    "headers": {
                        "user-agent": self.headers.get("User-Agent", "")
                    },
                    "ip": self.client_address[0]
                },
                "response": {
                    "status_code": 200,
                    "response_time_ms": 12
                },
                "meta": {
                    "request_id": trace_id,
                    "user_id": 42
                }
            }
        ).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):  # noqa: A002
        return


def main() -> None:
    port = _port()
    server = HTTPServer(("0.0.0.0", port), Handler)
    print(f"Starting server at http://127.0.0.1:{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()


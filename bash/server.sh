#!/usr/bin/env bash

PORT="${PORT:-8019}"
echo "Starting Bash server at http://127.0.0.1:${PORT}"

while true; do
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
  TRACE_ID="bash-trace-"$RANDOM
  
  JSON_BODY="{\"timestamp\":\"$TIMESTAMP\",\"level\":\"info\",\"service\":\"bash-api\",\"message\":\"GET / success\",\"request\":{\"method\":\"GET\",\"url\":\"/\",\"headers\":{\"user-agent\":\"nc\"},\"ip\":\"127.0.0.1\"},\"response\":{\"status_code\":200,\"response_time_ms\":1},\"meta\":{\"request_id\":\"$TRACE_ID\",\"user_id\":42}}"
  
  CONTENT_LENGTH=${#JSON_BODY}
  
  RESPONSE="HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: $CONTENT_LENGTH\r\nConnection: close\r\n\r\n$JSON_BODY"
  
  # Pipe response to netcat. Note: macOS nc syntax uses 'nc -l <port>'
  echo -ne "$RESPONSE" | nc -l "$PORT" > /dev/null
  
  # Access log equivalent
  echo "{\"code\":200,\"message\":\"OK\",\"method\":\"GET\",\"path\":\"/\",\"trace_id\":\"$TRACE_ID\",\"timestamp\":\"$TIMESTAMP\"}"
done

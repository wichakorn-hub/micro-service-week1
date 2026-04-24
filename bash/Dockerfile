
FROM debian:bookworm as builder

RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN chmod +x server.sh && bash -n server.sh

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/server.sh .

EXPOSE 8019

ENTRYPOINT ["./server.sh"]

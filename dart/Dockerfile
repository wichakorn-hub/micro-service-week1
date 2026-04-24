
FROM dart:stable as builder

WORKDIR /app

COPY . .

RUN dart pub get

RUN dart compile exe bin/server.dart -o bin/server

FROM debian:bookworm-slim

WORKDIR /app

COPY --from=builder /app/bin/server .

EXPOSE 8014

ENTRYPOINT ["./server"]

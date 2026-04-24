
FROM golang:1.20 as builder

WORKDIR /app

COPY . .

RUN go build -o main .

FROM debian:bookworm-slim

WORKDIR /app

COPY --from=builder /app/main .

EXPOSE 8016

ENTRYPOINT ["./main"]


FROM rust:1.88 as builder

WORKDIR /app

COPY . .

RUN cargo build --release

FROM debian:bookworm-slim

WORKDIR /app

COPY --from=builder /app/target/release/rust-project .

EXPOSE 8011

ENTRYPOINT ["./rust-project"]
CMD ["--host", "0.0.0.0"]

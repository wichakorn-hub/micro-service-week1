
FROM composer:2 as builder

WORKDIR /app

COPY . .

RUN composer install --no-dev --optimize-autoloader 2>/dev/null || true

FROM php:8.2-cli

WORKDIR /app

COPY --from=builder /app .

EXPOSE 8013

ENTRYPOINT ["php", "-S", "0.0.0.0:8013", "index.php"]

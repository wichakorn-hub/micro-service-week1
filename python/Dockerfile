
FROM python:3.12 as builder

WORKDIR /app

COPY . .

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app .

ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 8017

ENTRYPOINT ["python3", "server.py"]

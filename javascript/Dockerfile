
FROM node:20 as builder

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev 2>/dev/null || true

COPY . .

FROM node:20-slim

WORKDIR /app

COPY --from=builder /app .

EXPOSE 8018

ENTRYPOINT ["node", "server.js"]

# 🚚 Bash Microservice

This directory contains a raw **Bash** implementation of our standardized JSON logging API using the native Unix `nc` (netcat) utility to serve HTTP responses.

## 🚀 Quick Start
You can easily spin up this individual service using the global run script from the root repository:

```bash
# From the root of the repository
./run.sh bash
```

## 🛠️ Tech Stack
- **Interpreter**: `/usr/bin/env bash`
- **Networking Utility**: Netcat (`nc`)
- **Default Port**: `8019`

## 📁 Source Details
- **Main Entrypoint**: `server.sh`
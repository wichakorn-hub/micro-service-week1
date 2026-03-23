#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./run.sh <service> [args]
  ./run.sh all

Services:
  cpp          Build + run C++ (CMake). Optional arg: port (default 8010)
  rust         Run rust-project (cargo)
  node         Run node (npm install if needed)
  php          Run PHP built-in server
  dart         Run dart (dart run)
  java         Run Java (mvn spring-boot:run)
  go           Run Go (go run)
  python       Run Python (python3)
  javascript   Run JavaScript (node, no deps)

Default ports (override by passing a port for that service):
  cpp=8010 rust=8011 node=8012 php=8013 dart=8014 java=8015 go=8016 python=8017 javascript=8018

Examples:
  ./run.sh cpp
  ./run.sh cpp 8082
  ./run.sh all
EOF
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

run_cpp() {
  need_cmd cmake
  local port="${1:-8010}"
  local dir="$ROOT_DIR/cpp"
  local build_dir="$dir/build"
  mkdir -p "$build_dir"
  cmake -S "$dir" -B "$build_dir"
  cmake --build "$build_dir"
  echo "Starting C++ server (http://127.0.0.1:$port)"
  PORT="$port" "$build_dir/hello_cpp"
}

run_rust() {
  need_cmd cargo
  local port="${1:-8011}"
  echo "Starting Rust server (http://127.0.0.1:$port)"
  (cd "$ROOT_DIR/rust-project" && PORT="$port" cargo run)
}

run_node() {
  need_cmd node
  need_cmd npm
  local port="${1:-8012}"
  echo "Starting Node server (http://127.0.0.1:$port)"
  (cd "$ROOT_DIR/node" && npm install && PORT="$port" node index.js)
}

run_php() {
  need_cmd php
  local port="${1:-8013}"
  echo "Starting PHP server (http://127.0.0.1:$port)"
  (cd "$ROOT_DIR/php" && php -S "127.0.0.1:$port" index.php)
}

run_dart() {
  need_cmd dart
  local port="${1:-8014}"
  echo "Starting Dart server (http://127.0.0.1:$port)"
  (cd "$ROOT_DIR/dart" && dart pub get && PORT="$port" dart run bin/server.dart)
}

run_java() {
  need_cmd mvn
  local port="${1:-8015}"
  echo "Starting Java server (http://127.0.0.1:$port)"
  (cd "$ROOT_DIR/java" && PORT="$port" mvn spring-boot:run)
}

run_go() {
  need_cmd go
  local port="${1:-8016}"
  echo "Starting Go server (http://127.0.0.1:$port)"
  (cd "$ROOT_DIR/go" && PORT="$port" go run .)
}

run_python() {
  need_cmd python3
  local port="${1:-8017}"
  echo "Starting Python server (http://127.0.0.1:$port)"
  (cd "$ROOT_DIR/python" && PORT="$port" python3 server.py)
}

run_javascript() {
  need_cmd node
  local port="${1:-8018}"
  echo "Starting JavaScript server (http://127.0.0.1:$port)"
  (cd "$ROOT_DIR/javascript" && PORT="$port" node server.js)
}

run_all() {
  echo "Starting all services in background. Stop with: kill 0"
  run_cpp 8010 &
  run_rust 8011 &
  run_node 8012 &
  run_php 8013 &
  run_dart 8014 &
  run_java 8015 &
  run_go 8016 &
  run_python 8017 &
  run_javascript 8018 &
  wait
}

main() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi

  case "$1" in
    cpp) shift; run_cpp "${1:-8010}" ;;
    rust) shift; run_rust "${1:-8011}" ;;
    node) shift; run_node "${1:-8012}" ;;
    php) shift; run_php "${1:-8013}" ;;
    dart) shift; run_dart "${1:-8014}" ;;
    java) shift; run_java "${1:-8015}" ;;
    go) shift; run_go "${1:-8016}" ;;
    python) shift; run_python "${1:-8017}" ;;
    javascript) shift; run_javascript "${1:-8018}" ;;
    all) run_all ;;
    -h|--help|help) usage ;;
    *)
      echo "Unknown service: $1" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"


package main

import (
	"crypto/rand"
	"encoding/json"
	"encoding/hex"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"time"
)

type ApiResponse struct {
	Status    string `json:"status"`
	Message   string `json:"message"`
	Timestamp string `json:"timestamp"`
}

type LogLine struct {
	Code      int    `json:"code"`
	Message   string `json:"message"`
	Method    string `json:"method"`
	Path      string `json:"path"`
	TraceID   string `json:"trace_id"`
	Timestamp string `json:"timestamp"`
}

func traceID(r *http.Request) string {
	if v := r.Header.Get("X-Trace-Id"); v != "" {
		return v
	}
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return fmt.Sprintf("%d", time.Now().UnixNano())
	}
	return hex.EncodeToString(b)
}

func logJSON(line LogLine) {
	_ = json.NewEncoder(os.Stdout).Encode(line)
}

func main() {
	port := 8016
	if v := os.Getenv("PORT"); v != "" {
		if p, err := strconv.Atoi(v); err == nil && p > 0 && p <= 65535 {
			port = p
		}
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		timestamp := time.Now().UTC().Format(time.RFC3339)
		tid := traceID(r)

		if r.Method != http.MethodGet || r.URL.Path != "/" {
			logJSON(LogLine{
				Code:      404,
				Message:   "Not Found",
				Method:    r.Method,
				Path:      r.URL.Path,
				TraceID:   tid,
				Timestamp: timestamp,
			})
			http.NotFound(w, r)
			return
		}

		logJSON(LogLine{
			Code:      200,
			Message:   "OK",
			Method:    r.Method,
			Path:      r.URL.Path,
			TraceID:   tid,
			Timestamp: timestamp,
		})
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(ApiResponse{
			Status:    "success",
			Message:   "Hello Go",
			Timestamp: timestamp,
		})
	})

	addr := fmt.Sprintf("127.0.0.1:%d", port)
	fmt.Printf("Starting server at http://%s\n", addr)
	_ = http.ListenAndServe(addr, nil)
}


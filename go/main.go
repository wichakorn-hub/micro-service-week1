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

type RequestInfo struct {
	Method  string            `json:"method"`
	URL     string            `json:"url"`
	Headers map[string]string `json:"headers"`
	IP      string            `json:"ip"`
}

type ResponseInfo struct {
	StatusCode     int `json:"status_code"`
	ResponseTimeMs int `json:"response_time_ms"`
}

type MetaInfo struct {
	RequestID string `json:"request_id"`
	UserID    int    `json:"user_id"`
}

type StructuredResponse struct {
	Timestamp string       `json:"timestamp"`
	Level     string       `json:"level"`
	Service   string       `json:"service"`
	Message   string       `json:"message"`
	Request   RequestInfo  `json:"request"`
	Response  ResponseInfo `json:"response"`
	Meta      MetaInfo     `json:"meta"`
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
		_ = json.NewEncoder(w).Encode(StructuredResponse{
			Timestamp: timestamp,
			Level:     "info",
			Service:   "go-api",
			Message:   "GET / success",
			Request: RequestInfo{
				Method: r.Method,
				URL:    r.URL.Path,
				Headers: map[string]string{
					"user-agent": r.Header.Get("User-Agent"),
				},
				IP: r.RemoteAddr,
			},
			Response: ResponseInfo{
				StatusCode:     200,
				ResponseTimeMs: 12,
			},
			Meta: MetaInfo{
				RequestID: tid,
				UserID:    42,
			},
		})
	})

	addr := fmt.Sprintf("0.0.0.0:%d", port)
	fmt.Printf("Starting server at http://%s\n", addr)
	_ = http.ListenAndServe(addr, nil)
}


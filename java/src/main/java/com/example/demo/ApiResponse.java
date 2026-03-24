package com.example.demo;

import java.util.Map;

public class ApiResponse {
    private int code;
    private String method;
    private String message;
    private String timestamp;
    private Map<String, Object> metadata;

    public ApiResponse(int code, String method, String message, String timestamp, Map<String, Object> metadata) {
        this.code = code;
        this.method = method;
        this.message = message;
        this.timestamp = timestamp;
        this.metadata = metadata;
    }

    public int getCode() {
        return code;
    }

    public String getMethod() {
        return method;
    }

    public String getMessage() {
        return message;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public Map<String, Object> getMetadata() {
        return metadata;
    }
}


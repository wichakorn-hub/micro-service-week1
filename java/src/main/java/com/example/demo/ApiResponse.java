package com.example.demo;

public class ApiResponse {
    private String status;
    private String message;
    private String timestamp;

    public ApiResponse(String status, String message, String timestamp) {
        this.status = status;
        this.message = message;
        this.timestamp = timestamp;
    }

    public String getStatus() {
        return status;
    }

    public String getMessage() {
        return message;
    }

    public String getTimestamp() {
        return timestamp;
    }
}


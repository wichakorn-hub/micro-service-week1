package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@RestController
public class HelloController {

    @GetMapping("/")
    public ApiResponse hello(HttpServletRequest request) {
        String traceId = request.getHeader("X-Trace-Id");
        if (traceId == null || traceId.isBlank()) {
            traceId = UUID.randomUUID().toString();
        }
        String timestamp = OffsetDateTime.now().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);
        String logLine = String.format(
                "{\"code\":200,\"message\":\"OK\",\"method\":\"%s\",\"path\":\"%s\",\"trace_id\":\"%s\",\"timestamp\":\"%s\"}",
                request.getMethod(),
                request.getRequestURI(),
                traceId,
                timestamp
        );
        System.out.println(logLine);
        return new ApiResponse("success", "Hello Java", timestamp);
    }
}


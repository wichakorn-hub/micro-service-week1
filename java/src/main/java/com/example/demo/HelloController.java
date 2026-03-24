package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@RestController
public class HelloController {

    @GetMapping("/")
    public Map<String, Object> hello(HttpServletRequest request) {
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
        
        Map<String, Object> reqInfo = new HashMap<>();
        reqInfo.put("method", request.getMethod());
        reqInfo.put("url", request.getRequestURI());
        Map<String, String> headers = new HashMap<>();
        headers.put("user-agent", request.getHeader("User-Agent"));
        reqInfo.put("headers", headers);
        reqInfo.put("ip", request.getRemoteAddr());

        Map<String, Object> resInfo = new HashMap<>();
        resInfo.put("status_code", 200);
        resInfo.put("response_time_ms", 12);

        Map<String, Object> metaInfo = new HashMap<>();
        metaInfo.put("request_id", traceId);
        metaInfo.put("user_id", 42);

        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", timestamp);
        response.put("level", "info");
        response.put("service", "java-api");
        response.put("message", request.getMethod() + " " + request.getRequestURI() + " success");
        response.put("request", reqInfo);
        response.put("response", resInfo);
        response.put("meta", metaInfo);

        return response;
    }
}


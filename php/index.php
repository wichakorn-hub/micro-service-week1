<?php

if ($_SERVER['REQUEST_METHOD'] === 'GET' && $_SERVER['REQUEST_URI'] === '/') {
    $headers = function_exists('getallheaders') ? getallheaders() : [];
    $traceId = $headers['X-Trace-Id'] ?? bin2hex(random_bytes(16));
    $timestamp = gmdate('c');
    error_log(json_encode([
        'code' => 200,
        'message' => 'OK',
        'method' => $_SERVER['REQUEST_METHOD'],
        'path' => $_SERVER['REQUEST_URI'],
        'trace_id' => $traceId,
        'timestamp' => $timestamp,
    ]));

    $response = [
        'timestamp' => $timestamp,
        'level' => 'info',
        'service' => 'php-api',
        'message' => $_SERVER['REQUEST_METHOD'] . ' ' . $_SERVER['REQUEST_URI'] . ' success',
        'request' => [
            'method' => $_SERVER['REQUEST_METHOD'],
            'url' => $_SERVER['REQUEST_URI'],
            'headers' => [
                'user-agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            ],
            'ip' => $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1'
        ],
        'response' => [
            'status_code' => 200,
            'response_time_ms' => 12,
        ],
        'meta' => [
            'request_id' => $traceId,
            'user_id' => 42,
        ]
    ];

    header('Content-Type: application/json');
    echo json_encode($response);
    exit;
}

$headers = function_exists('getallheaders') ? getallheaders() : [];
$traceId = $headers['X-Trace-Id'] ?? bin2hex(random_bytes(16));
error_log(json_encode([
    'code' => 404,
    'message' => 'Not Found',
    'method' => $_SERVER['REQUEST_METHOD'] ?? '',
    'path' => $_SERVER['REQUEST_URI'] ?? '',
    'trace_id' => $traceId,
    'timestamp' => gmdate('c'),
]));
http_response_code(404);
header('Content-Type: application/json');
echo json_encode(['error' => 'Not found']);


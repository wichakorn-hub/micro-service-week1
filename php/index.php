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
        'status' => 'success',
        'message' => 'Hello PHP',
        'timestamp' => $timestamp,
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


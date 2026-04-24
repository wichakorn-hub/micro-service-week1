import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

String _generateTraceId() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return hex;
}

void main(List<String> args) async {
  final router = Router();

  router.get('/', (Request request) {
    final response = {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'level': 'info',
      'service': 'dart-api',
      'message': 'GET / success',
      'request': {
        'method': request.method,
        'url': request.requestedUri.path,
        'headers': {
          'user-agent': request.headers['user-agent'] ?? '',
        },
        'ip': '127.0.0.1',
      },
      'response': {
        'status_code': 200,
        'response_time_ms': 12,
      },
      'meta': {
        'request_id': request.headers['X-Trace-Id'] ?? 'abc12345',
        'user_id': 42,
      }
    };

    return Response.ok(
      jsonEncode(response),
      headers: {'Content-Type': 'application/json'},
    );
  });

  final handler = const Pipeline()
      .addMiddleware((inner) {
        return (request) async {
          final traceId =
              request.headers['X-Trace-Id'] ?? _generateTraceId();
          final timestamp = DateTime.now().toUtc().toIso8601String();

          final response = await inner(request);

          final logLine = {
            'code': response.statusCode,
            'message': response.statusCode == 200 ? 'OK' : 'Not Found',
            'method': request.method,
            'path': request.requestedUri.path,
            'trace_id': traceId,
            'timestamp': timestamp,
          };
          print(jsonEncode(logLine));

          return response;
        };
      })
      .addHandler(router);

  final ip = InternetAddress.anyIPv4;
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8014;

  final server = await io.serve(handler, ip, port);
  print('Starting server at http://${server.address.host}:${server.port}');
}

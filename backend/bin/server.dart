import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'package:biteplate_backend/src/api/server.dart';
import 'package:biteplate_backend/src/services/restaurant_service.dart';

Future<void> main() async {
  final service = RestaurantService();
  final apiHandler = buildHandler(service);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(apiHandler);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  print('BitePlate backend running on http://${server.address.host}:${server.port}');
}

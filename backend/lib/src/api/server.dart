library;

import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/restaurant_service.dart';

Response _json(Object? data, {int status = 200}) => Response(
      status,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );

Middleware errorMiddleware() => (Handler inner) {
      return (Request request) async {
        try {
          return await inner(request);
        } on ArgumentError catch (e) {
          return _json({'error': e.message ?? e.toString()}, status: 400);
        } on StateError catch (e) {
          return _json({'error': e.message}, status: 409);
        } on FormatException catch (e) {
          return _json({'error': 'Malformed JSON: ${e.message}'}, status: 400);
        }
      };
    };

Future<Map<String, dynamic>> _body(Request request) async {
  final raw = await request.readAsString();
  if (raw.isEmpty) return {};
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('expected a JSON object');
  }
  return decoded;
}

Map<String, dynamic> _menuJson(Object component) =>
    Map<String, dynamic>.from((component as dynamic).toJson() as Map);

Handler buildHandler(RestaurantService service) {
  final router = Router();

  router.get('/health', (Request r) => _json({'status': 'ok'}));

  router.get('/menu', (Request r) => _json(service.menu.map(_menuJson).toList()));

  router.get('/tables', (Request r) => _json(service.tables.map((t) => t.toJson()).toList()));

  router.get('/staff', (Request r) => _json(service.staff.map((s) => s.toJson()).toList()));

  router.get('/orders', (Request r) => _json(service.orders.map((o) => o.toJson()).toList()));

  router.post('/tables/<n>/seat', (Request r, String n) async {
    final body = await _body(r);
    final table = service.seatCustomer(
      int.parse(n),
      (body['customer'] ?? '').toString(),
      (body['staffId'] ?? '').toString(),
    );
    return _json(table.toJson());
  });

  router.post('/orders', (Request r) async {
    final body = await _body(r);
    if (body['tableNumber'] is! num) {
      throw ArgumentError('tableNumber (number) is required');
    }
    final order = service.createOrder(
      (body['tableNumber'] as num).toInt(),
      (body['staffId'] ?? '').toString(),
    );
    return _json(order.toJson(), status: 201);
  });

  router.post('/orders/<id>/items', (Request r, String id) async {
    final body = await _body(r);
    final extras = (body['extras'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        const <Map<String, dynamic>>[];
    final order = service.addItem(
      id,
      (body['menuItemId'] ?? '').toString(),
      (body['quantity'] as num?)?.toInt() ?? 1,
      extras: extras,
    );
    return _json(order.toJson());
  });

  router.post('/orders/<id>/send', (Request r, String id) async =>
      _json(service.sendToKitchen(id).toJson()));

  router.post('/orders/<id>/prepare', (Request r, String id) async {
    service.prepare(id);
    return _json(service.orders.firstWhere((o) => o.id == id).toJson());
  });

  router.post('/orders/<id>/ready', (Request r, String id) async {
    service.markReady(id);
    return _json(service.orders.firstWhere((o) => o.id == id).toJson());
  });

  router.post('/orders/<id>/cancel', (Request r, String id) async {
    service.cancel(id);
    return _json(service.orders.firstWhere((o) => o.id == id).toJson());
  });

  router.post('/kitchen/undo', (Request r) async =>
      _json({'undone': service.undoLastKitchenAction()}));

  router.get('/kitchen/queue', (Request r) =>
      _json(service.kitchen.queue.pending.map((o) => o.toJson()).toList()));

  router.post('/orders/<id>/bill', (Request r, String id) async {
    final body = await _body(r);
    final bill = service.generateBill(
      id,
      strategyKey: (body['strategy'] ?? 'standard').toString(),
      tip: (body['tip'] as num?)?.toDouble() ?? 0,
      splitBetween: (body['splitBetween'] as num?)?.toInt() ?? 1,
    );
    return _json(bill.toJson());
  });

  router.get('/dashboard', (Request r) => _json(service.dashboard()));

  router.get('/notifications', (Request r) =>
      _json(service.notifications().map((n) => n.toJson()).toList()));

  return const Pipeline()
      .addMiddleware(errorMiddleware())
      .addHandler(router.call);
}

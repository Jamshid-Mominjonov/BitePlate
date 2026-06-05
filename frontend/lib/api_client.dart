library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {

  final String baseUrl;
  ApiClient({this.baseUrl = 'http://localhost:8080'});

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> _decode(http.Response res) async {
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = (body is Map && body['error'] != null) ? body['error'].toString() : 'HTTP ${res.statusCode}';
    throw ApiException(msg);
  }

  Future<dynamic> _get(String path) async => _decode(await http.get(_u(path)));

  Future<dynamic> _post(String path, [Map<String, dynamic>? body]) async => _decode(
        await http.post(
          _u(path),
          headers: {'content-type': 'application/json'},
          body: body == null ? null : jsonEncode(body),
        ),
      );

  Future<List<MenuItemDto>> menu() async =>
      ((await _get('/menu')) as List).map((e) => MenuItemDto.fromJson(Map<String, dynamic>.from(e))).toList();

  Future<List<TableDto>> tables() async =>
      ((await _get('/tables')) as List).map((e) => TableDto.fromJson(Map<String, dynamic>.from(e))).toList();

  Future<List<StaffDto>> staff() async =>
      ((await _get('/staff')) as List).map((e) => StaffDto.fromJson(Map<String, dynamic>.from(e))).toList();

  Future<List<OrderDto>> orders() async =>
      ((await _get('/orders')) as List).map((e) => OrderDto.fromJson(Map<String, dynamic>.from(e))).toList();

  Future<TableDto> seat(int table, String customer, String staffId) async => TableDto.fromJson(
      Map<String, dynamic>.from(await _post('/tables/$table/seat', {'customer': customer, 'staffId': staffId})));

  Future<OrderDto> createOrder(int table, String staffId) async => OrderDto.fromJson(
      Map<String, dynamic>.from(await _post('/orders', {'tableNumber': table, 'staffId': staffId})));

  Future<OrderDto> addItem(String orderId, String menuItemId, int quantity,
          {List<Map<String, dynamic>> extras = const []}) async =>
      OrderDto.fromJson(Map<String, dynamic>.from(
          await _post('/orders/$orderId/items', {'menuItemId': menuItemId, 'quantity': quantity, 'extras': extras})));

  Future<OrderDto> send(String orderId) async =>
      OrderDto.fromJson(Map<String, dynamic>.from(await _post('/orders/$orderId/send')));

  Future<OrderDto> prepare(String orderId) async =>
      OrderDto.fromJson(Map<String, dynamic>.from(await _post('/orders/$orderId/prepare')));

  Future<OrderDto> markReady(String orderId) async =>
      OrderDto.fromJson(Map<String, dynamic>.from(await _post('/orders/$orderId/ready')));

  Future<OrderDto> cancel(String orderId) async =>
      OrderDto.fromJson(Map<String, dynamic>.from(await _post('/orders/$orderId/cancel')));

  Future<String?> undoKitchen() async => ((await _post('/kitchen/undo')) as Map)['undone'] as String?;

  Future<BillDto> bill(String orderId, {required String strategy, double tip = 0, int splitBetween = 1}) async =>
      BillDto.fromJson(Map<String, dynamic>.from(
          await _post('/orders/$orderId/bill', {'strategy': strategy, 'tip': tip, 'splitBetween': splitBetween})));

  Future<Map<String, dynamic>> dashboard() async => Map<String, dynamic>.from(await _get('/dashboard'));

  Future<List<NotificationDto>> notifications() async => ((await _get('/notifications')) as List)
      .map((e) => NotificationDto.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

library;

import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  final ApiClient api;
  AppState({ApiClient? client}) : api = client ?? ApiClient();

  bool loading = false;
  String? error;

  List<MenuItemDto> menu = [];
  List<TableDto> tables = [];
  List<StaffDto> staff = [];
  List<OrderDto> orders = [];
  List<NotificationDto> notifications = [];
  Map<String, dynamic> dashboard = {};

  String? selectedStaffId;
  OrderDto? currentOrder;
  BillDto? currentBill;

  StaffDto? get selectedStaff {
    for (final s in staff) {
      if (s.id == selectedStaffId) return s;
    }
    return null;
  }

  void setStaff(String? id) {
    selectedStaffId = id;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } on ApiException catch (e) {
      error = e.message;
    } catch (e) {
      error = 'Could not reach the backend. Is it running on :8080?  ($e)';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> bootstrap() => _run(() async {
        menu = await api.menu();
        staff = await api.staff();
        selectedStaffId ??= staff.isNotEmpty ? staff.first.id : null;
        await _refreshLive();
      });

  Future<void> _refreshLive() async {
    tables = await api.tables();
    orders = await api.orders();
    notifications = await api.notifications();
    dashboard = await api.dashboard();
  }

  Future<void> refresh() => _run(_refreshLive);

  Future<void> seat(int table, String customer) => _run(() async {
        await api.seat(table, customer, selectedStaffId ?? '');
        await _refreshLive();
      });

  Future<void> startOrder(int table) => _run(() async {
        currentOrder = await api.createOrder(table, selectedStaffId ?? '');
        await _refreshLive();
      });

  Future<void> addItem(String menuItemId, int qty, {List<Map<String, dynamic>> extras = const []}) => _run(() async {
        if (currentOrder == null) throw ApiException('Start an order first.');
        currentOrder = await api.addItem(currentOrder!.id, menuItemId, qty, extras: extras);
        await _refreshLive();
      });

  Future<void> sendCurrentOrder() => _run(() async {
        if (currentOrder == null) throw ApiException('No order to send.');
        currentOrder = await api.send(currentOrder!.id);
        await _refreshLive();
      });

  Future<void> kitchenPrepare(String id) => _run(() async {
        await api.prepare(id);
        await _refreshLive();
      });

  Future<void> kitchenReady(String id) => _run(() async {
        await api.markReady(id);
        await _refreshLive();
      });

  Future<void> kitchenCancel(String id) => _run(() async {
        await api.cancel(id);
        await _refreshLive();
      });

  Future<void> kitchenUndo() => _run(() async {
        await api.undoKitchen();
        await _refreshLive();
      });

  Future<void> generateBill(String orderId, {required String strategy, double tip = 0, int split = 1}) => _run(() async {
        currentBill = await api.bill(orderId, strategy: strategy, tip: tip, splitBetween: split);
        await _refreshLive();
      });
}

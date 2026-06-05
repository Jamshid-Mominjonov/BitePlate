library;

import 'menu.dart';

enum OrderStatus { pending, sentToKitchen, preparing, ready, served, cancelled }

class OrderItem {
  final MenuComponent component;
  final int quantity;

  OrderItem(this.component, {this.quantity = 1}) {
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'must be positive');
    }
  }

  double get lineTotal => component.price() * quantity;

  Map<String, dynamic> toJson() => {
        'description': component.describe(),
        'quantity': quantity,
        'unitPrice': component.price(),
        'lineTotal': lineTotal,
      };
}

class Order {
  final String id;
  final int tableNumber;
  final String staffId;
  final DateTime placedAt;
  final List<OrderItem> _items = [];
  OrderStatus _status = OrderStatus.pending;

  Order({
    required this.id,
    required this.tableNumber,
    required this.staffId,
    DateTime? placedAt,
  }) : placedAt = placedAt ?? DateTime.now();

  List<OrderItem> get items => List.unmodifiable(_items);
  OrderStatus get status => _status;

  bool get isEditable => _status == OrderStatus.pending;

  void addItem(OrderItem item) {
    if (!isEditable) {
      throw StateError('Order $id can no longer be modified (status: ${_status.name}).');
    }
    _items.add(item);
  }

  void removeItem(OrderItem item) {
    if (!isEditable) {
      throw StateError('Order $id can no longer be modified (status: ${_status.name}).');
    }
    _items.remove(item);
  }

  void transitionTo(OrderStatus next) {
    const allowed = {
      OrderStatus.pending: [OrderStatus.sentToKitchen, OrderStatus.cancelled],
      OrderStatus.sentToKitchen: [OrderStatus.preparing, OrderStatus.cancelled],
      OrderStatus.preparing: [OrderStatus.ready, OrderStatus.cancelled],
      OrderStatus.ready: [OrderStatus.served],
      OrderStatus.served: <OrderStatus>[],
      OrderStatus.cancelled: <OrderStatus>[],
    };
    if (!allowed[_status]!.contains(next)) {
      throw StateError('Illegal order transition: ${_status.name} → ${next.name}.');
    }
    _status = next;
  }

  void restore(OrderStatus previous) => _status = previous;

  double get subtotal => _items.fold(0, (sum, i) => sum + i.lineTotal);

  Map<String, dynamic> toJson() => {
        'id': id,
        'tableNumber': tableNumber,
        'staffId': staffId,
        'status': _status.name,
        'placedAt': placedAt.toIso8601String(),
        'items': _items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
      };
}

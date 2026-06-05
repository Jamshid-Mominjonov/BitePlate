library;

import '../domain/order.dart';

abstract interface class OrderObserver {
  void onOrderStatusChanged(Order order, OrderStatus newStatus);
}

mixin OrderSubject {
  final List<OrderObserver> _observers = [];

  void subscribe(OrderObserver o) {
    if (!_observers.contains(o)) _observers.add(o);
  }

  void unsubscribe(OrderObserver o) => _observers.remove(o);

  void notifyStatusChanged(Order order, OrderStatus status) {
    for (final o in List<OrderObserver>.from(_observers)) {
      o.onOrderStatusChanged(order, status);
    }
  }
}

class Notification {
  final String channel;
  final String message;
  final DateTime at;
  Notification(this.channel, this.message) : at = DateTime.now();

  Map<String, dynamic> toJson() =>
      {'channel': channel, 'message': message, 'at': at.toIso8601String()};
}

abstract class RecordingObserver implements OrderObserver {
  final List<Notification> log = [];
}

class WaiterNotifier extends RecordingObserver {
  @override
  void onOrderStatusChanged(Order order, OrderStatus newStatus) {
    if (newStatus == OrderStatus.ready) {
      log.add(Notification('Waiter',
          'Order ${order.id} for table ${order.tableNumber} is READY to serve.'));
    }
  }
}

class ManagerDashboard extends RecordingObserver {
  @override
  void onOrderStatusChanged(Order order, OrderStatus newStatus) {
    log.add(Notification('Manager',
        'Order ${order.id} (table ${order.tableNumber}) → ${newStatus.name}.'));
  }
}

class KitchenDisplay extends RecordingObserver {
  @override
  void onOrderStatusChanged(Order order, OrderStatus newStatus) {
    if (newStatus == OrderStatus.sentToKitchen || newStatus == OrderStatus.preparing) {
      log.add(Notification('KitchenDisplay',
          'Order ${order.id}: ${order.items.map((i) => i.component.describe()).join(', ')}'));
    }
  }
}

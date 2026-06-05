library;

import '../domain/order.dart';

abstract interface class KitchenReceiver {

  void advance(Order order, OrderStatus to);
}

abstract interface class KitchenCommand {
  String get label;
  void execute();
  void undo();
}

class PrepareOrderCommand implements KitchenCommand {
  final Order order;
  final KitchenReceiver receiver;
  OrderStatus? _previous;

  PrepareOrderCommand(this.order, this.receiver);

  @override
  String get label => 'Prepare order ${order.id}';

  @override
  void execute() {
    _previous = order.status;
    receiver.advance(order, OrderStatus.preparing);
  }

  @override
  void undo() {
    if (_previous != null) {
      order.restore(_previous!);
      receiver.advance(order, _previous!);
    }
  }
}

class CancelOrderCommand implements KitchenCommand {
  final Order order;
  final KitchenReceiver receiver;
  OrderStatus? _previous;

  CancelOrderCommand(this.order, this.receiver);

  @override
  String get label => 'Cancel order ${order.id}';

  @override
  void execute() {
    _previous = order.status;
    order.restore(OrderStatus.cancelled);
    receiver.advance(order, OrderStatus.cancelled);
  }

  @override
  void undo() {
    if (_previous != null) {
      order.restore(_previous!);
      receiver.advance(order, _previous!);
    }
  }
}

class ServeReadyCommand implements KitchenCommand {
  final Order order;
  final KitchenReceiver receiver;
  OrderStatus? _previous;

  ServeReadyCommand(this.order, this.receiver);

  @override
  String get label => 'Mark order ${order.id} ready';

  @override
  void execute() {
    _previous = order.status;
    receiver.advance(order, OrderStatus.ready);
  }

  @override
  void undo() {
    if (_previous != null) {
      order.restore(_previous!);
      receiver.advance(order, _previous!);
    }
  }
}

class KitchenQueue {
  final List<KitchenCommand> _history = [];
  final List<Order> _pending = [];

  List<Order> get pending => List.unmodifiable(_pending);

  List<String> get history => _history.map((c) => c.label).toList();

  void enqueue(Order order) => _pending.add(order);

  void expedite(Order order) {
    if (_pending.remove(order)) _pending.insert(0, order);
  }

  void run(KitchenCommand command) {
    command.execute();
    _history.add(command);
  }

  String? undoLast() {
    if (_history.isEmpty) return null;
    final last = _history.removeLast();
    last.undo();
    return last.label;
  }
}

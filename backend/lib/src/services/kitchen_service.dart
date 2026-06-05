library;

import '../domain/order.dart';
import '../patterns/command.dart';
import '../patterns/observer.dart';

class KitchenService with OrderSubject implements KitchenReceiver {
  final KitchenQueue queue = KitchenQueue();

  @override
  void advance(Order order, OrderStatus to) {

    try {
      order.transitionTo(to);
    } on StateError {
      order.restore(to);
    }
    notifyStatusChanged(order, to);
  }
}

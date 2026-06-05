import 'package:biteplate_backend/biteplate_backend.dart';
import 'package:test/test.dart';

void main() {
  group('Decorator', () {
    test('stacks extras and adds their charges', () {
      final burger = MainCourse(id: 'x', name: 'Burger', basePrice: 10);
      final customised = AllergenNote(
        ExtraTopping(burger, toppingName: 'Cheese', extraCharge: 1.5),
        note: 'No sesame',
      );
      expect(customised.price(), 11.5);
      expect(customised.describe(), contains('Cheese'));
      expect(customised.describe(), contains('No sesame'));
    });
  });

  group('Composite', () {
    test('combo sums children and applies discount', () {
      final combo = ComboMeal(id: 'c', name: 'Deal', comboDiscount: 0.10)
        ..add(MainCourse(id: 'a', name: 'Burger', basePrice: 10))
        ..add(Beverage(id: 'b', name: 'Cola', basePrice: 2.5));
      expect(combo.price(), closeTo(11.25, 0.001));
    });
  });

  group('Strategy', () {
    test('happy hour applies 20% off', () {
      final order = Order(id: 'O1', tableNumber: 1, staffId: 'w1')
        ..addItem(OrderItem(MainCourse(id: 'a', name: 'Burger', basePrice: 10)));
      expect(HappyHourPricing().calculateTotal(order).total, 8.0);
      expect(StandardPricing().calculateTotal(order).total, 10.0);
    });
  });

  group('Command', () {
    test('undo reverts the last kitchen action', () {
      final svc = RestaurantService();
      svc.history.resetForTesting();
      final order = svc.createOrder(1, 'w1');
      svc.addItem(order.id, 'm3', 1);
      svc.sendToKitchen(order.id);
      svc.prepare(order.id);
      expect(order.status, OrderStatus.preparing);
      svc.undoLastKitchenAction();
      expect(order.status, OrderStatus.sentToKitchen);
    });
  });

  group('Singleton', () {
    test('OrderHistoryLog is a single shared instance', () {
      expect(identical(OrderHistoryLog(), OrderHistoryLog.instance), isTrue);
    });
  });

  group('Permissions', () {
    test('a waiter cannot close a bill but a cashier can', () {
      expect(Waiter(id: 'w', name: 'A').can(Permission.closeBill), isFalse);
      expect(Cashier(id: 'c', name: 'B').can(Permission.closeBill), isTrue);
      expect(Manager(id: 'm', name: 'C').can(Permission.manageStaff), isTrue);
    });
  });
}

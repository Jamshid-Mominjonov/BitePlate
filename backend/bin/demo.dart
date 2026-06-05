import 'package:biteplate_backend/biteplate_backend.dart';

void _line([String s = '']) => print(s);

void main() {
  final svc = RestaurantService();

  _line('=== BitePlate Smart Restaurant Management System ===\n');

  final table = svc.seatCustomer(2, 'Karimov family', 'w1');
  _line('Seated "${table.seatedCustomer}" at table ${table.number} (${table.state.name}).');

  final order = svc.createOrder(2, 'w1');
  svc.addItem(order.id, 'm3', 1, extras: [
    {'type': 'topping', 'name': 'Extra cheese', 'charge': 1.50},
    {'type': 'allergen', 'note': 'No sesame seeds'},
  ]);
  svc.addItem(order.id, 'c1', 1);
  svc.addItem(order.id, 'm6', 2);
  _line('\nOrder ${order.id} taken:');
  for (final item in order.items) {
    _line('  • ${item.quantity}x ${item.component.describe()}  '
        '(\$${item.component.price().toStringAsFixed(2)})');
  }
  _line('  Subtotal: \$${order.subtotal.toStringAsFixed(2)}');

  svc.sendToKitchen(order.id);
  _line('\nOrder sent to kitchen. Status: ${order.status.name}');

  svc.prepare(order.id);
  _line('Kitchen: preparing. Status: ${order.status.name}');
  svc.markReady(order.id);
  _line('Kitchen: ready. Status: ${order.status.name}');
  final undone = svc.undoLastKitchenAction();
  _line('Undo last command -> "$undone". Status now: ${order.status.name}');
  svc.markReady(order.id);

  _line('\nNotifications:');
  for (final n in svc.notifications()) {
    _line('  [${n.channel}] ${n.message}');
  }

  for (final key in ['standard', 'happyHour', 'loyalty']) {
    final bill = svc.generateBill(order.id, strategyKey: key, tip: 3.00, splitBetween: 2);
    _line('\nBill (${bill.pricingLabel}):');
    _line('  Subtotal \$${bill.discountedSubtotal.toStringAsFixed(2)} | '
        'Tax \$${bill.tax.toStringAsFixed(2)} | Tip \$${bill.tip.toStringAsFixed(2)}');
    _line('  Grand total \$${bill.grandTotal.toStringAsFixed(2)} '
        '(\$${bill.perGuest.toStringAsFixed(2)} per guest)');
  }

  final dash = svc.dashboard();
  _line('\nManager dashboard:');
  _line('  Orders logged: ${dash['totalOrders']}');
  _line('  Revenue:       \$${dash['totalRevenue']}');
  _line('  Top item:      ${dash['mostFrequentItem']}');

  _line('\n=== Demo complete ===');
}

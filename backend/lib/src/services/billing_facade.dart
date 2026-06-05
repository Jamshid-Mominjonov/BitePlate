library;

import '../domain/bill.dart';
import '../domain/order.dart';
import '../patterns/strategy.dart';

class BillingFacade {
  final double taxRate;
  BillingFacade({this.taxRate = 0.12});

  Bill generateBill(
    Order order, {
    required PricingStrategy strategy,
    double tip = 0,
    int splitBetween = 1,
  }) {
    if (order.items.isEmpty) {
      throw StateError('Cannot bill an empty order (${order.id}).');
    }

    final priced = strategy.calculateTotal(order);

    final bill = Bill(
      orderId: order.id,
      tableNumber: order.tableNumber,
      discountedSubtotal: priced.total,
      pricingLabel: priced.label,
      taxRate: taxRate,
      tip: tip,
      splitBetween: splitBetween,
    );

    for (final item in order.items) {
      bill.addLine(BillLineItem(
        description: item.component.describe(),
        quantity: item.quantity,
        unitPrice: item.component.price(),
      ));
    }
    for (final freebie in priced.freeItems) {
      bill.addLine(BillLineItem(description: '$freebie (free)', quantity: 1, unitPrice: 0));
    }
    return bill;
  }
}

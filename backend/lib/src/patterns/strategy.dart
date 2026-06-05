library;

import '../domain/order.dart';

class PriceResult {
  final double total;
  final List<String> freeItems;
  final String label;

  PriceResult({required this.total, required this.label, this.freeItems = const []});
}

abstract interface class PricingStrategy {
  String get name;
  PriceResult calculateTotal(Order order);
}

class StandardPricing implements PricingStrategy {
  @override
  String get name => 'Standard';
  @override
  PriceResult calculateTotal(Order order) =>
      PriceResult(total: order.subtotal, label: name);
}

class HappyHourPricing implements PricingStrategy {
  static const double discount = 0.20;
  @override
  String get name => 'Happy Hour (-20%)';
  @override
  PriceResult calculateTotal(Order order) =>
      PriceResult(total: order.subtotal * (1 - discount), label: name);
}

class LoyaltyCardPricing implements PricingStrategy {
  static const double discount = 0.10;
  @override
  String get name => 'Loyalty Card (-10% + free drink)';
  @override
  PriceResult calculateTotal(Order order) => PriceResult(
        total: order.subtotal * (1 - discount),
        label: name,
        freeItems: const ['House soft drink'],
      );
}

class WeekendSurchargePricing implements PricingStrategy {
  static const double surcharge = 0.10;
  @override
  String get name => 'Weekend Surcharge (+10%)';
  @override
  PriceResult calculateTotal(Order order) =>
      PriceResult(total: order.subtotal * (1 + surcharge), label: name);
}

PricingStrategy pickStrategyForTime(DateTime now) {
  final isWeekendEvening = (now.weekday == DateTime.saturday) && now.hour >= 18;
  final isQuietHours = now.hour >= 15 && now.hour < 17;
  if (isQuietHours) return HappyHourPricing();
  if (isWeekendEvening) return WeekendSurchargePricing();
  return StandardPricing();
}

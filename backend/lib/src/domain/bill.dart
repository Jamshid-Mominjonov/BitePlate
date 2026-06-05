library;

class BillLineItem {
  final String description;
  final int quantity;
  final double unitPrice;

  BillLineItem({required this.description, required this.quantity, required this.unitPrice});

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toJson() =>
      {'description': description, 'quantity': quantity, 'unitPrice': unitPrice, 'lineTotal': lineTotal};
}

class Bill {
  final String orderId;
  final int tableNumber;
  final List<BillLineItem> _lines = [];
  final double taxRate;
  final String pricingLabel;
  final double discountedSubtotal;
  double tip;
  int splitBetween;

  Bill({
    required this.orderId,
    required this.tableNumber,
    required this.discountedSubtotal,
    required this.pricingLabel,
    this.taxRate = 0.12,
    this.tip = 0,
    this.splitBetween = 1,
  }) {
    if (taxRate < 0) throw ArgumentError.value(taxRate, 'taxRate', 'must not be negative');
    if (tip < 0) throw ArgumentError.value(tip, 'tip', 'must not be negative');
    if (splitBetween < 1) throw ArgumentError.value(splitBetween, 'splitBetween', 'must be at least 1');
  }

  void addLine(BillLineItem line) => _lines.add(line);
  List<BillLineItem> get lines => List.unmodifiable(_lines);

  double get tax => discountedSubtotal * taxRate;
  double get grandTotal => discountedSubtotal + tax + tip;
  double get perGuest => grandTotal / splitBetween;

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'tableNumber': tableNumber,
        'pricing': pricingLabel,
        'lines': _lines.map((l) => l.toJson()).toList(),
        'subtotal': double.parse(discountedSubtotal.toStringAsFixed(2)),
        'tax': double.parse(tax.toStringAsFixed(2)),
        'tip': double.parse(tip.toStringAsFixed(2)),
        'grandTotal': double.parse(grandTotal.toStringAsFixed(2)),
        'splitBetween': splitBetween,
        'perGuest': double.parse(perGuest.toStringAsFixed(2)),
      };
}

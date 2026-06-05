library;

class OrderRecord {
  final String orderId;
  final int tableNumber;
  final String staffId;
  final List<String> itemDescriptions;
  final double total;
  final DateTime timestamp;
  final bool cancelledAfterPrep;

  OrderRecord({
    required this.orderId,
    required this.tableNumber,
    required this.staffId,
    required this.itemDescriptions,
    required this.total,
    required this.timestamp,
    this.cancelledAfterPrep = false,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'tableNumber': tableNumber,
        'staffId': staffId,
        'items': itemDescriptions,
        'total': total,
        'timestamp': timestamp.toIso8601String(),
        'cancelledAfterPrep': cancelledAfterPrep,
      };
}

class OrderHistoryLog {
  OrderHistoryLog._internal();
  static final OrderHistoryLog _instance = OrderHistoryLog._internal();

  factory OrderHistoryLog() => _instance;
  static OrderHistoryLog get instance => _instance;

  final List<OrderRecord> _records = [];

  int get length => _records.length;

  void append(OrderRecord record) => _records.add(record);

  Iterator<OrderRecord> get iterator => _RecordIterator(List.of(_records));

  List<OrderRecord> inDateRange(DateTime from, DateTime to) {
    final result = <OrderRecord>[];
    final it = iterator;
    while (it.moveNext()) {
      final r = it.current;
      if (!r.timestamp.isBefore(from) && !r.timestamp.isAfter(to)) {
        result.add(r);
      }
    }
    return result;
  }

  List<OrderRecord> forTable(int tableNumber) {
    final result = <OrderRecord>[];
    final it = iterator;
    while (it.moveNext()) {
      if (it.current.tableNumber == tableNumber) result.add(it.current);
    }
    return result;
  }

  String? mostFrequentItem() {
    final counts = <String, int>{};
    final it = iterator;
    while (it.moveNext()) {
      for (final desc in it.current.itemDescriptions) {
        counts[desc] = (counts[desc] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  double get totalRevenue {
    var sum = 0.0;
    final it = iterator;
    while (it.moveNext()) {
      sum += it.current.total;
    }
    return sum;
  }

  void resetForTesting() => _records.clear();
}

class _RecordIterator implements Iterator<OrderRecord> {
  final List<OrderRecord> _data;
  int _index = -1;
  _RecordIterator(this._data);

  @override
  OrderRecord get current => _data[_index];

  @override
  bool moveNext() {
    if (_index + 1 < _data.length) {
      _index++;
      return true;
    }
    return false;
  }
}

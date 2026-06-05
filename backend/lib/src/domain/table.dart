library;

enum TableState { free, reserved, occupied, awaitingBill, cleared }

class RestaurantTable {
  final int number;
  final int seats;
  TableState _state = TableState.free;
  String? _seatedCustomer;

  RestaurantTable({required this.number, required this.seats}) {
    if (seats <= 0) {
      throw ArgumentError.value(seats, 'seats', 'must be positive');
    }
  }

  TableState get state => _state;
  String? get seatedCustomer => _seatedCustomer;

  void reserve() => _transition(TableState.reserved);

  void seat(String customer) {
    if (customer.trim().isEmpty) {
      throw ArgumentError.value(customer, 'customer', 'must not be empty');
    }
    _transition(TableState.occupied);
    _seatedCustomer = customer;
  }

  void requestBill() => _transition(TableState.awaitingBill);

  void clear() {
    _transition(TableState.cleared);
    _seatedCustomer = null;
    _state = TableState.free;
  }

  void _transition(TableState next) {
    const allowed = {
      TableState.free: [TableState.reserved, TableState.occupied],
      TableState.reserved: [TableState.occupied, TableState.free],
      TableState.occupied: [TableState.awaitingBill],
      TableState.awaitingBill: [TableState.cleared],
      TableState.cleared: [TableState.free],
    };
    if (!allowed[_state]!.contains(next)) {
      throw StateError('Illegal table transition: ${_state.name} → ${next.name}.');
    }
    _state = next;
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'seats': seats,
        'state': _state.name,
        'seatedCustomer': _seatedCustomer,
      };
}

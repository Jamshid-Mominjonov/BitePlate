library;

class MenuItemDto {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool containsAllergen;

  MenuItemDto({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.containsAllergen = false,
  });

  factory MenuItemDto.fromJson(Map<String, dynamic> j) => MenuItemDto(
        id: j['id'] as String,
        name: j['name'] as String,
        price: (j['price'] as num).toDouble(),
        category: j['category'] as String,
        containsAllergen: j['containsAllergen'] as bool? ?? false,
      );
}

class TableDto {
  final int number;
  final int seats;
  final String state;
  final String? seatedCustomer;

  TableDto({required this.number, required this.seats, required this.state, this.seatedCustomer});

  factory TableDto.fromJson(Map<String, dynamic> j) => TableDto(
        number: j['number'] as int,
        seats: j['seats'] as int,
        state: j['state'] as String,
        seatedCustomer: j['seatedCustomer'] as String?,
      );
}

class StaffDto {
  final String id;
  final String name;
  final String role;
  final List<String> permissions;

  StaffDto({required this.id, required this.name, required this.role, required this.permissions});

  factory StaffDto.fromJson(Map<String, dynamic> j) => StaffDto(
        id: j['id'] as String,
        name: j['name'] as String,
        role: j['role'] as String,
        permissions: (j['permissions'] as List).cast<String>(),
      );
}

class OrderItemDto {
  final String description;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  OrderItemDto({required this.description, required this.quantity, required this.unitPrice, required this.lineTotal});

  factory OrderItemDto.fromJson(Map<String, dynamic> j) => OrderItemDto(
        description: j['description'] as String,
        quantity: j['quantity'] as int,
        unitPrice: (j['unitPrice'] as num).toDouble(),
        lineTotal: (j['lineTotal'] as num).toDouble(),
      );
}

class OrderDto {
  final String id;
  final int tableNumber;
  final String staffId;
  final String status;
  final List<OrderItemDto> items;
  final double subtotal;

  OrderDto({
    required this.id,
    required this.tableNumber,
    required this.staffId,
    required this.status,
    required this.items,
    required this.subtotal,
  });

  factory OrderDto.fromJson(Map<String, dynamic> j) => OrderDto(
        id: j['id'] as String,
        tableNumber: j['tableNumber'] as int,
        staffId: j['staffId'] as String,
        status: j['status'] as String,
        items: (j['items'] as List).map((e) => OrderItemDto.fromJson(Map<String, dynamic>.from(e))).toList(),
        subtotal: (j['subtotal'] as num).toDouble(),
      );
}

class BillLineDto {
  final String description;
  final int quantity;
  final double lineTotal;
  BillLineDto({required this.description, required this.quantity, required this.lineTotal});
  factory BillLineDto.fromJson(Map<String, dynamic> j) => BillLineDto(
        description: j['description'] as String,
        quantity: j['quantity'] as int,
        lineTotal: (j['lineTotal'] as num).toDouble(),
      );
}

class BillDto {
  final String orderId;
  final int tableNumber;
  final String pricing;
  final List<BillLineDto> lines;
  final double subtotal;
  final double tax;
  final double tip;
  final double grandTotal;
  final int splitBetween;
  final double perGuest;

  BillDto({
    required this.orderId,
    required this.tableNumber,
    required this.pricing,
    required this.lines,
    required this.subtotal,
    required this.tax,
    required this.tip,
    required this.grandTotal,
    required this.splitBetween,
    required this.perGuest,
  });

  factory BillDto.fromJson(Map<String, dynamic> j) => BillDto(
        orderId: j['orderId'] as String,
        tableNumber: j['tableNumber'] as int,
        pricing: j['pricing'] as String,
        lines: (j['lines'] as List).map((e) => BillLineDto.fromJson(Map<String, dynamic>.from(e))).toList(),
        subtotal: (j['subtotal'] as num).toDouble(),
        tax: (j['tax'] as num).toDouble(),
        tip: (j['tip'] as num).toDouble(),
        grandTotal: (j['grandTotal'] as num).toDouble(),
        splitBetween: j['splitBetween'] as int,
        perGuest: (j['perGuest'] as num).toDouble(),
      );
}

class NotificationDto {
  final String channel;
  final String message;
  NotificationDto({required this.channel, required this.message});
  factory NotificationDto.fromJson(Map<String, dynamic> j) =>
      NotificationDto(channel: j['channel'] as String, message: j['message'] as String);
}

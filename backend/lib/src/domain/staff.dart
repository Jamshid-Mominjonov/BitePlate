library;

enum Permission { takeOrder, manageKitchen, closeBill, viewReports, manageStaff }

abstract class Staff {
  final String id;
  final String name;

  Staff({required this.id, required this.name});

  Set<Permission> get permissions;

  String get role;

  bool can(Permission p) => permissions.contains(p);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'permissions': permissions.map((p) => p.name).toList(),
      };
}

class Waiter extends Staff {
  Waiter({required super.id, required super.name});
  @override
  String get role => 'Waiter';
  @override
  Set<Permission> get permissions => {Permission.takeOrder};
}

class Chef extends Staff {
  Chef({required super.id, required super.name});
  @override
  String get role => 'Head Chef';
  @override
  Set<Permission> get permissions => {Permission.manageKitchen};
}

class Cashier extends Staff {
  Cashier({required super.id, required super.name});
  @override
  String get role => 'Cashier';
  @override
  Set<Permission> get permissions => {Permission.closeBill};
}

class Manager extends Staff {
  Manager({required super.id, required super.name});
  @override
  String get role => 'Manager';
  @override
  Set<Permission> get permissions => Permission.values.toSet();
}

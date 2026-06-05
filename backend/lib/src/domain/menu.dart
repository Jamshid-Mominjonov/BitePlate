library;

abstract interface class MenuComponent {
  String get id;
  String get name;

  double price();

  String describe();
}

enum MenuCategory { starter, main, dessert, beverage, combo }

abstract class MenuItem implements MenuComponent {
  final String _id;
  final String _name;
  final double _basePrice;
  final MenuCategory _category;
  final bool containsAllergen;

  MenuItem({
    required String id,
    required String name,
    required double basePrice,
    required MenuCategory category,
    this.containsAllergen = false,
  })  : _id = id,
        _name = name,
        _basePrice = basePrice,
        _category = category {
    if (basePrice < 0) {
      throw ArgumentError.value(basePrice, 'basePrice', 'must not be negative');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
  }

  @override
  String get id => _id;

  @override
  String get name => _name;

  double get basePrice => _basePrice;

  MenuCategory get category => _category;

  String get station;

  @override
  double price() => _basePrice;

  @override
  String describe() => name;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price(),
        'category': category.name,
        'station': station,
        'containsAllergen': containsAllergen,
      };
}

class Starter extends MenuItem {
  Starter({required super.id, required super.name, required super.basePrice, super.containsAllergen})
      : super(category: MenuCategory.starter);
  @override
  String get station => 'cold';
}

class MainCourse extends MenuItem {
  MainCourse({required super.id, required super.name, required super.basePrice, super.containsAllergen})
      : super(category: MenuCategory.main);
  @override
  String get station => 'hot';
}

class Dessert extends MenuItem {
  Dessert({required super.id, required super.name, required super.basePrice, super.containsAllergen})
      : super(category: MenuCategory.dessert);
  @override
  String get station => 'dessert';
}

class Beverage extends MenuItem {
  Beverage({required super.id, required super.name, required super.basePrice, super.containsAllergen})
      : super(category: MenuCategory.beverage);
  @override
  String get station => 'cold';
}

class ComboMeal implements MenuComponent {
  @override
  final String id;
  @override
  final String name;

  final List<MenuComponent> _items = [];

  final double comboDiscount;

  ComboMeal({required this.id, required this.name, this.comboDiscount = 0}) {
    if (comboDiscount < 0 || comboDiscount > 1) {
      throw ArgumentError.value(comboDiscount, 'comboDiscount', 'must be between 0 and 1');
    }
  }

  void add(MenuComponent item) => _items.add(item);
  void remove(MenuComponent item) => _items.remove(item);
  List<MenuComponent> get items => List.unmodifiable(_items);

  @override
  double price() {
    final subtotal = _items.fold<double>(0, (sum, item) => sum + item.price());
    return subtotal * (1 - comboDiscount);
  }

  @override
  String describe() =>
      '$name [${_items.map((i) => i.describe()).join(' + ')}]';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price(),
        'category': MenuCategory.combo.name,
        'items': _items.map((i) => i.describe()).toList(),
      };
}

library;

import '../domain/menu.dart';

abstract class MenuItemFactory {
  MenuItem createItem({
    required String id,
    required String name,
    required double basePrice,
    bool containsAllergen = false,
  });
}

class StarterFactory extends MenuItemFactory {
  @override
  MenuItem createItem({required String id, required String name, required double basePrice, bool containsAllergen = false}) =>
      Starter(id: id, name: name, basePrice: basePrice, containsAllergen: containsAllergen);
}

class MainCourseFactory extends MenuItemFactory {
  @override
  MenuItem createItem({required String id, required String name, required double basePrice, bool containsAllergen = false}) =>
      MainCourse(id: id, name: name, basePrice: basePrice, containsAllergen: containsAllergen);
}

class DessertFactory extends MenuItemFactory {
  @override
  MenuItem createItem({required String id, required String name, required double basePrice, bool containsAllergen = false}) =>
      Dessert(id: id, name: name, basePrice: basePrice, containsAllergen: containsAllergen);
}

class BeverageFactory extends MenuItemFactory {
  @override
  MenuItem createItem({required String id, required String name, required double basePrice, bool containsAllergen = false}) =>
      Beverage(id: id, name: name, basePrice: basePrice, containsAllergen: containsAllergen);
}

class MenuFactoryRegistry {
  final Map<MenuCategory, MenuItemFactory> _factories = {
    MenuCategory.starter: StarterFactory(),
    MenuCategory.main: MainCourseFactory(),
    MenuCategory.dessert: DessertFactory(),
    MenuCategory.beverage: BeverageFactory(),
  };

  MenuItem create(
    MenuCategory category, {
    required String id,
    required String name,
    required double basePrice,
    bool containsAllergen = false,
  }) {
    final factory = _factories[category];
    if (factory == null) {
      throw ArgumentError.value(category, 'category', 'no factory registered');
    }
    return factory.createItem(
      id: id,
      name: name,
      basePrice: basePrice,
      containsAllergen: containsAllergen,
    );
  }
}

library;

import '../domain/bill.dart';
import '../domain/menu.dart';
import '../domain/order.dart';
import '../domain/staff.dart';
import '../domain/table.dart';
import '../patterns/command.dart';
import '../patterns/decorator.dart';
import '../patterns/factory.dart';
import '../patterns/observer.dart';
import '../patterns/singleton.dart';
import '../patterns/strategy.dart';
import 'billing_facade.dart';
import 'kitchen_service.dart';

class RestaurantService {
  final MenuFactoryRegistry _factory = MenuFactoryRegistry();
  final BillingFacade _billing = BillingFacade();
  final KitchenService kitchen = KitchenService();
  final OrderHistoryLog history = OrderHistoryLog.instance;

  final Map<String, MenuComponent> _menu = {};
  final Map<int, RestaurantTable> _tables = {};
  final Map<String, Staff> _staff = {};
  final Map<String, Order> _orders = {};

  final WaiterNotifier waiterNotifier = WaiterNotifier();
  final ManagerDashboard managerDashboard = ManagerDashboard();
  final KitchenDisplay kitchenDisplay = KitchenDisplay();

  int _orderCounter = 0;

  RestaurantService() {
    _seed();
    kitchen
      ..subscribe(waiterNotifier)
      ..subscribe(managerDashboard)
      ..subscribe(kitchenDisplay);
  }

  void _seed() {

    _menu['m1'] = _factory.create(MenuCategory.starter, id: 'm1', name: 'Garlic Bread', basePrice: 4.50, containsAllergen: true);
    _menu['m2'] = _factory.create(MenuCategory.starter, id: 'm2', name: 'Soup of the Day', basePrice: 5.00);
    _menu['m3'] = _factory.create(MenuCategory.main, id: 'm3', name: 'Classic Burger', basePrice: 11.00);
    _menu['m4'] = _factory.create(MenuCategory.main, id: 'm4', name: 'Margherita Pizza', basePrice: 10.50, containsAllergen: true);
    _menu['m5'] = _factory.create(MenuCategory.dessert, id: 'm5', name: 'Cheesecake', basePrice: 6.00, containsAllergen: true);
    _menu['m6'] = _factory.create(MenuCategory.beverage, id: 'm6', name: 'Soft Drink', basePrice: 2.50);

    final combo = ComboMeal(id: 'c1', name: 'Burger Combo', comboDiscount: 0.10)
      ..add(_menu['m3']!)
      ..add(_menu['m6']!);
    _menu['c1'] = combo;

    for (var i = 1; i <= 6; i++) {
      _tables[i] = RestaurantTable(number: i, seats: i.isEven ? 4 : 2);
    }

    _staff['w1'] = Waiter(id: 'w1', name: 'Aziza');
    _staff['ch1'] = Chef(id: 'ch1', name: 'Bekzod');
    _staff['ca1'] = Cashier(id: 'ca1', name: 'Dilnoza');
    _staff['mg1'] = Manager(id: 'mg1', name: 'Sardor');
  }

  List<MenuComponent> get menu => _menu.values.toList();
  List<RestaurantTable> get tables => _tables.values.toList()..sort((a, b) => a.number.compareTo(b.number));
  List<Staff> get staff => _staff.values.toList();
  List<Order> get orders => _orders.values.toList();

  Staff _requireStaff(String staffId) {
    final s = _staff[staffId];
    if (s == null) throw ArgumentError('Unknown staff id: $staffId');
    return s;
  }

  Order _requireOrder(String orderId) {
    final o = _orders[orderId];
    if (o == null) throw ArgumentError('Unknown order id: $orderId');
    return o;
  }

  void _require(Staff s, Permission p) {
    if (!s.can(p)) {
      throw StateError('${s.role} ${s.name} is not permitted to ${p.name}.');
    }
  }

  RestaurantTable seatCustomer(int tableNumber, String customer, String staffId) {
    final staff = _requireStaff(staffId);
    _require(staff, Permission.takeOrder);
    final table = _tables[tableNumber];
    if (table == null) throw ArgumentError('Unknown table: $tableNumber');
    table.seat(customer);
    return table;
  }

  Order createOrder(int tableNumber, String staffId) {
    final staff = _requireStaff(staffId);
    _require(staff, Permission.takeOrder);
    if (!_tables.containsKey(tableNumber)) throw ArgumentError('Unknown table: $tableNumber');
    final id = 'O${(++_orderCounter).toString().padLeft(3, '0')}';
    final order = Order(id: id, tableNumber: tableNumber, staffId: staffId);
    _orders[id] = order;
    return order;
  }

  Order addItem(String orderId, String menuItemId, int quantity, {List<Map<String, dynamic>> extras = const []}) {
    final order = _requireOrder(orderId);
    final base = _menu[menuItemId];
    if (base == null) throw ArgumentError('Unknown menu item: $menuItemId');

    MenuComponent component = base;
    for (final e in extras) {
      switch (e['type']) {
        case 'topping':
          component = ExtraTopping(component,
              toppingName: (e['name'] ?? 'extra').toString(),
              extraCharge: (e['charge'] as num?)?.toDouble() ?? 0);
          break;
        case 'substitution':
          component = SideSubstitution(component,
              from: (e['from'] ?? '').toString(),
              to: (e['to'] ?? '').toString(),
              surcharge: (e['charge'] as num?)?.toDouble() ?? 0);
          break;
        case 'allergen':
          component = AllergenNote(component, note: (e['note'] ?? 'allergen').toString());
          break;
      }
    }
    order.addItem(OrderItem(component, quantity: quantity));
    return order;
  }

  Order sendToKitchen(String orderId) {
    final order = _requireOrder(orderId);
    kitchen.advance(order, OrderStatus.sentToKitchen);
    kitchen.queue.enqueue(order);
    history.append(OrderRecord(
      orderId: order.id,
      tableNumber: order.tableNumber,
      staffId: order.staffId,
      itemDescriptions: order.items.map((i) => i.component.describe()).toList(),
      total: order.subtotal,
      timestamp: DateTime.now(),
    ));
    return order;
  }

  void prepare(String orderId) => kitchen.queue.run(PrepareOrderCommand(_requireOrder(orderId), kitchen));
  void markReady(String orderId) => kitchen.queue.run(ServeReadyCommand(_requireOrder(orderId), kitchen));
  void cancel(String orderId) => kitchen.queue.run(CancelOrderCommand(_requireOrder(orderId), kitchen));
  void expedite(String orderId) => kitchen.queue.expedite(_requireOrder(orderId));
  String? undoLastKitchenAction() => kitchen.queue.undoLast();

  Bill generateBill(String orderId, {required String strategyKey, double tip = 0, int splitBetween = 1}) {
    final order = _requireOrder(orderId);
    final strategy = _strategyFor(strategyKey);
    return _billing.generateBill(order, strategy: strategy, tip: tip, splitBetween: splitBetween);
  }

  PricingStrategy _strategyFor(String key) {
    switch (key) {
      case 'happyHour':
        return HappyHourPricing();
      case 'loyalty':
        return LoyaltyCardPricing();
      case 'weekend':
        return WeekendSurchargePricing();
      case 'auto':
        return pickStrategyForTime(DateTime.now());
      case 'standard':
      default:
        return StandardPricing();
    }
  }

  Map<String, dynamic> dashboard() => {
        'totalOrders': history.length,
        'totalRevenue': double.parse(history.totalRevenue.toStringAsFixed(2)),
        'mostFrequentItem': history.mostFrequentItem(),
      };

  List<Notification> notifications() => [
        ...waiterNotifier.log,
        ...managerDashboard.log,
        ...kitchenDisplay.log,
      ]..sort((a, b) => a.at.compareTo(b.at));
}

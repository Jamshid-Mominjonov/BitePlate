import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'app_state.dart';
import 'screens/billing_screen.dart';
import 'screens/floor_screen.dart';
import 'screens/kitchen_screen.dart';
import 'screens/order_screen.dart';
import 'screens/reports_screen.dart';
import 'theme.dart';

void main() => runApp(const BitePlateApp());

class BitePlateApp extends StatefulWidget {
  const BitePlateApp({super.key});

  @override
  State<BitePlateApp> createState() => _BitePlateAppState();
}

class _BitePlateAppState extends State<BitePlateApp> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.bootstrap();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'BitePlate SRMS',
        debugShowCheckedModeBanner: false,
        theme: BiteTheme.build(),
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    FloorScreen(),
    OrderScreen(),
    KitchenScreen(),
    BillingScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BitePlate  ·  Smart Restaurant Management'),
        actions: [
          if (state.loading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
          IconButton(onPressed: () => state.refresh(), icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
        ],
      ),
      body: Column(
        children: [
          if (state.error != null)
            Container(
              width: double.infinity,
              color: BiteTheme.terracotta.withValues(alpha: 0.18),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18, color: BiteTheme.terracotta),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.error!, style: const TextStyle(color: BiteTheme.terracotta))),
                ],
              ),
            ),
          Expanded(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: BiteTheme.surface,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.table_restaurant_outlined), selectedIcon: Icon(Icons.table_restaurant), label: Text('Floor')),
                    NavigationRailDestination(icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu), label: Text('Order')),
                    NavigationRailDestination(icon: Icon(Icons.soup_kitchen_outlined), selectedIcon: Icon(Icons.soup_kitchen), label: Text('Kitchen')),
                    NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: Text('Billing')),
                    NavigationRailDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: Text('Reports')),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: IndexedStack(index: _index, children: _screens)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

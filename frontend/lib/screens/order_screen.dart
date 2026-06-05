import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models.dart';
import '../theme.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final order = state.currentOrder;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Menu', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: state.menu.map((m) => _MenuTile(item: m, state: state, hasOrder: order != null)).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          Expanded(flex: 2, child: _OrderPanel(order: order, state: state)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final MenuItemDto item;
  final dynamic state;
  final bool hasOrder;
  const _MenuTile({required this.item, required this.state, required this.hasOrder});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(item.name),
            if (item.containsAllergen)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Tooltip(message: 'Contains a common allergen', child: Text('⚠')),
              ),
          ],
        ),
        subtitle: Text('${item.category} · \$${item.price.toStringAsFixed(2)}'),
        trailing: hasOrder
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Customise & add',
                    icon: const Icon(Icons.tune),
                    onPressed: () => _customiseDialog(context, state, item),
                  ),
                  IconButton(
                    tooltip: 'Add',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => state.addItem(item.id, 1),
                  ),
                ],
              )
            : const Text('Start an order →', style: TextStyle(color: Colors.white38, fontSize: 12)),
      ),
    );
  }

  void _customiseDialog(BuildContext context, dynamic state, MenuItemDto item) {
    bool extraCheese = false;
    bool noAllergen = false;
    bool subSalad = false;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text('Customise ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                value: extraCheese,
                title: const Text('Extra cheese (+\$1.50)'),
                onChanged: (v) => setLocal(() => extraCheese = v ?? false),
              ),
              CheckboxListTile(
                value: subSalad,
                title: const Text('Substitute fries → salad'),
                onChanged: (v) => setLocal(() => subSalad = v ?? false),
              ),
              CheckboxListTile(
                value: noAllergen,
                title: const Text('Allergen note: no nuts'),
                onChanged: (v) => setLocal(() => noAllergen = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final extras = <Map<String, dynamic>>[
                  if (extraCheese) {'type': 'topping', 'name': 'Extra cheese', 'charge': 1.5},
                  if (subSalad) {'type': 'substitution', 'from': 'fries', 'to': 'salad', 'charge': 0},
                  if (noAllergen) {'type': 'allergen', 'note': 'No nuts'},
                ];
                state.addItem(item.id, 1, extras: extras);
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  final OrderDto? order;
  final dynamic state;
  const _OrderPanel({required this.order, required this.state});

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return Card(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: const Text('No active order.\nSeat a guest and tap "New order" on the Floor tab.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
        ),
      );
    }
    final color = BiteTheme.stateColor(order!.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Order ${order!.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Chip(label: Text(order!.status, style: TextStyle(color: color)), backgroundColor: color.withValues(alpha: 0.12)),
              ],
            ),
            Text('Table ${order!.tableNumber}', style: const TextStyle(color: Colors.white54)),
            const Divider(height: 24),
            Expanded(
              child: order!.items.isEmpty
                  ? const Center(child: Text('No items yet.', style: TextStyle(color: Colors.white38)))
                  : ListView(
                      children: order!.items
                          .map((i) => ListTile(
                                dense: true,
                                title: Text('${i.quantity}× ${i.description}'),
                                trailing: Text('\$${i.lineTotal.toStringAsFixed(2)}'),
                              ))
                          .toList(),
                    ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('\$${order!.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: order!.status == 'pending' && order!.items.isNotEmpty ? () => state.sendCurrentOrder() : null,
                icon: const Icon(Icons.send),
                label: const Text('Send to kitchen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

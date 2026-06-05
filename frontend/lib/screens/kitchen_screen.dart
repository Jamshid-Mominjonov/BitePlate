import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models.dart';
import '../theme.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final active = state.orders
        .where((o) => o.status != 'pending' && o.status != 'served')
        .toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Kitchen Queue', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => state.kitchenUndo(),
                icon: const Icon(Icons.undo),
                label: const Text('Undo last action'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: active.isEmpty
                ? const Center(child: Text('Queue is empty.', style: TextStyle(color: Colors.white38)))
                : ListView(children: active.map((o) => _KitchenCard(order: o, state: state)).toList()),
          ),
        ],
      ),
    );
  }
}

class _KitchenCard extends StatelessWidget {
  final OrderDto order;
  final dynamic state;
  const _KitchenCard({required this.order, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = BiteTheme.stateColor(order.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Order ${order.id} · Table ${order.tableNumber}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Chip(label: Text(order.status, style: TextStyle(color: color)), backgroundColor: color.withValues(alpha: 0.12)),
              ],
            ),
            const SizedBox(height: 8),
            ...order.items.map((i) => Text('• ${i.quantity}× ${i.description}', style: const TextStyle(color: Colors.white70))),
            const SizedBox(height: 12),
            Row(
              children: [
                if (order.status == 'sentToKitchen')
                  FilledButton(onPressed: () => state.kitchenPrepare(order.id), child: const Text('Start preparing')),
                if (order.status == 'preparing')
                  FilledButton(onPressed: () => state.kitchenReady(order.id), child: const Text('Mark ready')),
                const SizedBox(width: 8),
                if (order.status != 'cancelled' && order.status != 'ready')
                  OutlinedButton(onPressed: () => state.kitchenCancel(order.id), child: const Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

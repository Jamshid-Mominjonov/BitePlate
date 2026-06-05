import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final d = state.dashboard;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manager Dashboard', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              _metric('Orders logged', '${d['totalOrders'] ?? 0}'),
              const SizedBox(width: 16),
              _metric('Revenue', '\$${(d['totalRevenue'] ?? 0).toString()}'),
              const SizedBox(width: 16),
              _metric('Top item', (d['mostFrequentItem'] ?? '—').toString()),
            ],
          ),
          const SizedBox(height: 24),
          Text('Notifications (Observer feed)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: state.notifications.isEmpty
                ? const Center(child: Text('No notifications yet.', style: TextStyle(color: Colors.white38)))
                : ListView(
                    children: state.notifications.reversed
                        .map((n) => Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: BiteTheme.amber.withValues(alpha: 0.15),
                                  child: Text(n.channel.substring(0, 1), style: const TextStyle(color: BiteTheme.amber)),
                                ),
                                title: Text(n.message),
                                subtitle: Text(n.channel),
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white54)),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: BiteTheme.amber)),
              ],
            ),
          ),
        ),
      );
}

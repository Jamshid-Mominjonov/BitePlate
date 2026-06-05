import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models.dart';
import '../theme.dart';

class FloorScreen extends StatelessWidget {
  const FloorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Floor Plan', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              _StaffSelector(state: state),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: state.tables.map((t) => _TableCard(table: t, state: state)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffSelector extends StatelessWidget {
  final dynamic state;
  const _StaffSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final List<StaffDto> staff = state.staff;
    return Row(
      children: [
        const Text('Acting as: '),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: state.selectedStaffId,
          items: staff
              .map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} · ${s.role}')))
              .toList(),
          onChanged: (v) => state.setStaff(v),
        ),
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  final TableDto table;
  final dynamic state;
  const _TableCard({required this.table, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = BiteTheme.stateColor(table.state);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Table ${table.number}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Chip(
                  label: Text(table.state, style: TextStyle(color: color, fontSize: 12)),
                  backgroundColor: color.withValues(alpha: 0.12),
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${table.seats} seats', style: const TextStyle(color: Colors.white54)),
            if (table.seatedCustomer != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('👤 ${table.seatedCustomer}', style: const TextStyle(color: Colors.white70)),
              ),
            const Spacer(),
            Row(
              children: [
                if (table.state == 'free')
                  FilledButton.tonal(
                    onPressed: () => _seatDialog(context, state, table.number),
                    child: const Text('Seat'),
                  ),
                if (table.state == 'occupied')
                  FilledButton(
                    onPressed: () => state.startOrder(table.number),
                    child: const Text('New order'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _seatDialog(BuildContext context, dynamic state, int tableNumber) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Seat a customer at table $tableNumber'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Customer name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                state.seat(tableNumber, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Seat'),
          ),
        ],
      ),
    );
  }
}

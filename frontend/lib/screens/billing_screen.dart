import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  String? _orderId;
  String _strategy = 'standard';
  final _tipController = TextEditingController(text: '0');
  int _split = 1;

  static const _strategies = {
    'standard': 'Standard',
    'happyHour': 'Happy Hour (-20%)',
    'loyalty': 'Loyalty (-10% + free drink)',
    'weekend': 'Weekend Surcharge (+10%)',
    'auto': 'Auto (by time of day)',
  };

  @override
  void dispose() {
    _tipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final billable = state.orders.where((o) => o.items.isNotEmpty && o.status != 'cancelled').toList();
    _orderId ??= billable.isNotEmpty ? billable.first.id : null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Billing & POS', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                _label('Order'),
                DropdownButton<String>(
                  isExpanded: true,
                  value: billable.any((o) => o.id == _orderId) ? _orderId : null,
                  items: billable
                      .map((o) => DropdownMenuItem(value: o.id, child: Text('${o.id} · Table ${o.tableNumber} · \$${o.subtotal.toStringAsFixed(2)}')))
                      .toList(),
                  onChanged: (v) => setState(() => _orderId = v),
                ),
                const SizedBox(height: 12),
                _label('Pricing strategy'),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _strategy,
                  items: _strategies.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (v) => setState(() => _strategy = v ?? 'standard'),
                ),
                const SizedBox(height: 12),
                _label('Tip (\$)'),
                TextField(
                  controller: _tipController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                _label('Split between'),
                Row(
                  children: [
                    IconButton(onPressed: () => setState(() => _split = (_split - 1).clamp(1, 20)), icon: const Icon(Icons.remove)),
                    Text('$_split guest(s)'),
                    IconButton(onPressed: () => setState(() => _split = (_split + 1).clamp(1, 20)), icon: const Icon(Icons.add)),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _orderId == null
                      ? null
                      : () => state.generateBill(
                            _orderId!,
                            strategy: _strategy,
                            tip: double.tryParse(_tipController.text) ?? 0,
                            split: _split,
                          ),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Generate bill'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: _BillView(bill: state.currentBill)),
        ],
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(s, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      );
}

class _BillView extends StatelessWidget {
  final BillDto? bill;
  const _BillView({required this.bill});

  @override
  Widget build(BuildContext context) {
    if (bill == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No bill generated yet.', style: TextStyle(color: Colors.white38))),
        ),
      );
    }
    final b = bill!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BitePlate — Bill', style: Theme.of(context).textTheme.titleLarge),
            Text('Order ${b.orderId} · Table ${b.tableNumber}', style: const TextStyle(color: Colors.white54)),
            Text('Pricing: ${b.pricing}', style: const TextStyle(color: Colors.white54)),
            const Divider(height: 24),
            ...b.lines.map((l) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Text('${l.quantity}× ${l.description}')),
                      Text('\$${l.lineTotal.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
            const Divider(height: 24),
            _row('Subtotal', b.subtotal),
            _row('Tax', b.tax),
            _row('Tip', b.tip),
            const SizedBox(height: 6),
            _row('Grand total', b.grandTotal, bold: true),
            if (b.splitBetween > 1) _row('Per guest (÷${b.splitBetween})', b.perGuest),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 18 : 14)),
            const Spacer(),
            Text('\$${value.toStringAsFixed(2)}', style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 18 : 14)),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/phone.dart';

class PhoneCard extends StatelessWidget {
  final Phone phone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSell;

  const PhoneCard({
    super.key,
    required this.phone,
    required this.onEdit,
    required this.onDelete,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final profit = phone.sellingPrice - phone.purchasePrice;
    final isProfit = profit >= 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Brand + Model + Condition badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${phone.brand} ${phone.model}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (phone.color != null || phone.storage != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          [phone.color, phone.storage]
                              .where((e) => e != null)
                              .join(' • '),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                _conditionBadge(context),
              ],
            ),
            const SizedBox(height: 10),

            // IMEI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fingerprint, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    phone.imei1,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (phone.imei2 != null) ...[
                    Text(' / ', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    Text(
                      phone.imei2!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Battery health (iPhone only)
            if (phone.batteryHealth != null && (phone.brand.toLowerCase().contains('apple') || phone.brand.toLowerCase().contains('iphone'))) ...[
              Row(
                children: [
                  Icon(Icons.battery_full, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Battery: ${phone.batteryHealth}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Pricing row
            Row(
              children: [
                // Selling price
                Text(
                  '${NumberFormat('#,##0', 'en_US').format(phone.sellingPrice)} PKR',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(width: 12),
                // Profit badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isProfit
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${isProfit ? '+' : ''}${NumberFormat('#,##0', 'en_US').format(profit)} PKR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isProfit ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    foregroundColor: Colors.blue,
                  ),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: onSell,
                  icon: const Icon(Icons.sell, size: 16),
                  label: const Text('Sell'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _conditionBadge(BuildContext context) {
    final isNew = phone.condition == 'New';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNew ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        phone.condition,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isNew ? Colors.blue[700] : Colors.orange[700],
        ),
      ),
    );
  }
}

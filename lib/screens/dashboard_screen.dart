// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/phone_provider.dart';
import '../providers/sales_provider.dart';
import '../services/export_service.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onAddPhonePressed;

  const DashboardScreen({super.key, this.onAddPhonePressed});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Key Metrics Row
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _MetricCard(
                        title: "Today's Sales",
                        value:
                            '${NumberFormat('#,##0', 'en_US').format(context.watch<SalesProvider>().todayTotalSales)} PKR',
                        icon: Icons.attach_money,
                        color: Colors.green,
                        width: constraints.maxWidth > 600
                            ? (constraints.maxWidth - 40) / 3
                            : constraints.maxWidth,
                      ),
                      _MetricCard(
                        title: 'Total Inventory',
                        value:
                            '${context.watch<PhoneProvider>().phones.length} Models',
                        icon: Icons.inventory_2,
                        color: Colors.blue,
                        width: constraints.maxWidth > 600
                            ? (constraints.maxWidth - 40) / 3
                            : constraints.maxWidth,
                      ),
                      _MetricCard(
                        title: 'Low Stock Items',
                        value:
                            '${context.watch<PhoneProvider>().phones.where((p) => p.stock <= 5).length}',
                        icon: Icons.warning_amber_rounded,
                        color: Colors.orange,
                        width: constraints.maxWidth > 600
                            ? (constraints.maxWidth - 40) / 3
                            : constraints.maxWidth,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ElevatedButton.icon(
                    onPressed: onAddPhonePressed,
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Phone'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final phones = context.read<PhoneProvider>().phones;
                      if (phones.isNotEmpty) {
                        await PdfExportService.exportInventory(phones);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Inventory exported successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No inventory to export'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export Inventory'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

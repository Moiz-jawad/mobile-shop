// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/phone_provider.dart';
import '../providers/sales_provider.dart';
import '../providers/sync_provider.dart';
import '../services/export_service.dart';
import '../providers/theme_provider.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onAddPhonePressed;

  const DashboardScreen({super.key, this.onAddPhonePressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Sync status indicator
          Consumer<SyncProvider>(
            builder: (context, sync, _) {
              return IconButton(
                icon: Icon(sync.statusIcon, color: sync.statusColor),
                tooltip: sync.statusText,
                onPressed: () => sync.manualSync(),
              );
            },
          ),
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),

                // Key Metrics Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final salesProvider = context.watch<SalesProvider>();
                    final phoneProvider = context.watch<PhoneProvider>();
                    final todayProfit = salesProvider.sales
                        .where((s) =>
                            s.timestamp.year == DateTime.now().year &&
                            s.timestamp.month == DateTime.now().month &&
                            s.timestamp.day == DateTime.now().day)
                        .fold<double>(0, (sum, s) => sum + s.profit);
                    final phoneSoldToday = salesProvider.sales
                        .where((s) =>
                            s.timestamp.year == DateTime.now().year &&
                            s.timestamp.month == DateTime.now().month &&
                            s.timestamp.day == DateTime.now().day)
                        .length;

                    // Calculate number of columns based on width
                    int crossAxisCount;
                    if (constraints.maxWidth > 1000) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 2; // Keep 2 for tablets to allow cards to be wider
                    } else {
                      crossAxisCount = 2; // Mobile also 2
                    }

                    // Calculate width for each card considering spacing
                    final double spacing = 20;
                    final double availableWidth =
                        constraints.maxWidth - (spacing * (crossAxisCount - 1));
                    final double itemWidth = availableWidth / crossAxisCount;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        _MetricCard(
                          title: "Today's Revenue",
                          value:
                              '${NumberFormat('#,##0', 'en_US').format(salesProvider.todayTotalSales)} PKR',
                          icon: Icons.attach_money,
                          color: Colors.green,
                          width: itemWidth,
                        ),
                        _MetricCard(
                          title: "Today's Profit",
                          value:
                              '${NumberFormat('#,##0', 'en_US').format(todayProfit)} PKR',
                          icon: Icons.trending_up,
                          color: todayProfit >= 0 ? Colors.teal : Colors.red,
                          width: itemWidth,
                        ),
                        _MetricCard(
                          title: 'Available Stock',
                          value:
                              '${phoneProvider.availablePhones.length} Phones',
                          icon: Icons.inventory_2,
                          color: Colors.blue,
                          width: itemWidth,
                        ),
                        _MetricCard(
                          title: 'Sold Today',
                          value: '$phoneSoldToday',
                          icon: Icons.sell,
                          color: Colors.purple,
                          width: itemWidth,
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 40),

              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final phones = context.read<PhoneProvider>().availablePhones;
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
                          const SnackBar(content: Text('No inventory to export')),
                        );
                      }
                    },
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export Inventory'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Recent Sales section
              Text(
                'Recent Sales',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer<SalesProvider>(
                builder: (context, provider, child) {
                  final recentSales = provider.sales.take(5).toList();

                  if (recentSales.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('No sales recorded yet.'),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: recentSales.map((sale) {
                      final isProfit = sale.profit >= 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isProfit
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            child: Icon(
                              isProfit ? Icons.trending_up : Icons.trending_down,
                              color: isProfit ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                          title: Text('${sale.phoneBrand} ${sale.phoneModel}'),
                          subtitle: Text(
                            '${DateFormat('MMM dd, hh:mm a').format(sale.timestamp)} • ${sale.paymentMethod ?? 'Cash'}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${NumberFormat('#,##0', 'en_US').format(sale.sellingPrice)} PKR',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${isProfit ? '+' : ''}${NumberFormat('#,##0', 'en_US').format(sale.profit)} PKR',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isProfit ? Colors.green[700] : Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

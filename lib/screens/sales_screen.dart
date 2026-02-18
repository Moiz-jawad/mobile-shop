import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_shop/models/sale.dart';
import 'package:mobile_shop/providers/sales_provider.dart';
import 'package:mobile_shop/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import '../services/export_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export PDF',
            onPressed: () async {
              final sales = context.read<SalesProvider>().sales;
              if (sales.isNotEmpty) {
                await PdfExportService.exportSales(sales);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No sales to export')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SalesProvider>().loadSales(),
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
      body: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sales recorded yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Column(
                  children: [
                    Text(
                      "Today's Total Sales",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${NumberFormat('#,##0', 'en_US').format(provider.todayTotalSales)} PKR',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.sales.length,
                  itemBuilder: (context, index) {
                    final sale = provider.sales[index];
                    return _SaleListItem(sale: sale);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SaleListItem extends StatelessWidget {
  final Sale sale;

  const _SaleListItem({required this.sale});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');
    final isProfit = sale.profit >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isProfit ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isProfit ? Icons.trending_up : Icons.trending_down,
            color: isProfit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          '${sale.phoneBrand} ${sale.phoneModel}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${dateFormat.format(sale.timestamp)} • ${sale.paymentMethod ?? "Cash"}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${NumberFormat('#,##0', 'en_US').format(sale.sellingPrice)} PKR',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            Text(
              '${isProfit ? "+" : ""}${NumberFormat('#,##0', 'en_US').format(sale.profit)} PKR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isProfit ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

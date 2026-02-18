import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/sale.dart';
import '../models/phone.dart';

class PdfExportService {
  static final _dateFormatter = DateFormat('MMM dd, yyyy');
  static final _timeFormatter = DateFormat('HH:mm');

  static Future<void> exportSales(List<Sale> sales) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildHeader('SALES REPORT'),
          footer: (context) => _buildFooter(context),
          build: (context) => [pw.SizedBox(height: 10), _salesTable(sales)],
        ),
      );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'sales_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    } catch (e) {
      debugPrint('Export Error: $e');
      rethrow;
    }
  }

  static String _formatPKR(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount)} PKR';
  }

  static Future<void> exportInventory(List<Phone> phones) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildHeader('INVENTORY REPORT'),
          footer: (context) => _buildFooter(context),
          build: (context) => [
            pw.SizedBox(height: 10),
            _inventoryTable(phones),
          ],
        ),
      );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'inventory_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    } catch (e) {
      debugPrint('Export Error: $e');
      rethrow;
    }
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              'Mobile Shop Management',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
        pw.SizedBox(height: 5),
        pw.Text(
          'Generated: ${_dateFormatter.format(DateTime.now())} at ${_timeFormatter.format(DateTime.now())}',
        ),
        pw.SizedBox(height: 15),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      // margin: const pw.EdgeInsets.top(20),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  static pw.Widget _salesTable(List<Sale> sales) {
    final headers = ['Date', 'Brand', 'Model', 'Qty', 'Unit', 'Total'];
    final data = sales
        .map(
          (s) => [
            _dateFormatter.format(s.timestamp),
            s.phoneBrand,
            s.phoneModel,
            s.quantity.toString(),
            _formatPKR(s.unitPrice),
            _formatPKR(s.totalPrice),
          ],
        )
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _inventoryTable(List<Phone> phones) {
    final headers = ['Brand', 'Model', 'Price', 'Stock', 'IMEI 1', 'IMEI 2'];
    final data = phones
        .map(
          (p) => [
            p.brand,
            p.model,
            _formatPKR(p.price),
            p.stock.toString(),
            p.imei1 ?? '-',
            p.imei2 ?? '-',
          ],
        )
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellHeight: 25,
      cellAlignments: {
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.centerLeft,
      },
    );
  }

  static Future<void> exportReceipt(Sale sale, Phone phone) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(20),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'SALE RECEIPT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Mobile Shop Management',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Date: ${_dateFormatter.format(sale.timestamp)}'),
                    pw.Text('Time: ${_timeFormatter.format(sale.timestamp)}'),
                  ],
                ),
                pw.SizedBox(height: 10),
                if (sale.customerName != null || sale.customerContact != null) ...[
                  pw.Text(
                    'CUSTOMER DETAILS:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                  pw.Text('Name: ${sale.customerName ?? "N/A"}'),
                  pw.Text('Contact: ${sale.customerContact ?? "N/A"}'),
                  pw.SizedBox(height: 10),
                ],
                pw.Text(
                  'ITEM DETAILS:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text('Item Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
                pw.Divider(thickness: 0.5),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('${sale.phoneBrand} ${sale.phoneModel}'),
                          if (phone.imei1 != null) pw.Text('IMEI 1: ${phone.imei1}', style: const pw.TextStyle(fontSize: 8)),
                          if (phone.imei2 != null) pw.Text('IMEI 2: ${phone.imei2}', style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(sale.quantity.toString(), textAlign: pw.TextAlign.center),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(_formatPKR(sale.totalPrice), textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
                pw.Divider(thickness: 1),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL AMOUNT:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                    pw.Text(
                      _formatPKR(sale.totalPrice),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'receipt_${sale.timestamp.millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      debugPrint('Export Error: $e');
      rethrow;
    }
  }
}

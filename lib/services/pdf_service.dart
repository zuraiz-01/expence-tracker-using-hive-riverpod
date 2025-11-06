import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/expense.dart';

class PdfService {
  static Future<File> generateExpenseReport(
    List<Expense> expenses,
    double totalThisWeek,
    double currentBalance, // current balance before expenses
  ) async {
    final pdf = pw.Document();

    // 🧮 Calculate remaining balance
    final remainingBalance = currentBalance - totalThisWeek;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          // 🏷 Title
          pw.Center(
            child: pw.Text(
              'Expense Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 20),

          // 📋 Expense Table
          pw.Table.fromTextArray(
            headers: ['Title', 'Amount (Rs.)', 'Date'],
            data: expenses.map((e) {
              return [
                e.title,
                'Rs. ${e.amount.toStringAsFixed(2)}',
                e.date.toLocal().toString().split('.')[0],
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 12),
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 4,
            ),
          ),

          pw.SizedBox(height: 20),
          pw.Divider(),

          // 💰 Totals Section
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Total This Week: Rs. ${totalThisWeek.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Previous Balance: Rs. ${currentBalance.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Remaining Balance: Rs. ${remainingBalance.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: remainingBalance >= 0
                        ? PdfColors.green800
                        : PdfColors.red800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // 💾 Save PDF
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/expense_report.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

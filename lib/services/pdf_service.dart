import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/catering_models.dart';

class PdfService {
  // 1. PREMIUM MONTHLY FINANCE & WORK REPORT GENERATOR
  // The report uses the existing monthly values and records without changing
  // any application calculations or stored data.
  static Future<void> exportMonthlyReport({
    required String monthLabel,
    required double totalIncome,
    required double totalExpenses,
    required double netSavings,
    required List<WorkItem> works,
    required List<ExpenseItem> expenses,
  }) async {
    final pdf = pw.Document();
    final logoBytes = (await rootBundle.load('assets/branding/caterpro_mark.png')).buffer.asUint8List();
    final logo = pw.MemoryImage(logoBytes);
    const navy = PdfColor.fromInt(0xFF071B33);
    const navyLight = PdfColor.fromInt(0xFF102B49);
    const gold = PdfColor.fromInt(0xFFE7B84F);
    const ink = PdfColor.fromInt(0xFF172638);
    const muted = PdfColor.fromInt(0xFF718096);
    const line = PdfColor.fromInt(0xFFE2E8F0);
    const pale = PdfColor.fromInt(0xFFF5F7FA);
    const green = PdfColor.fromInt(0xFF16834A);
    const red = PdfColor.fromInt(0xFFD94141);
    const amber = PdfColor.fromInt(0xFFD97706);
    final generatedAt = DateTime.now();
    final generatedLabel = '${generatedAt.day.toString().padLeft(2, '0')}/'
        '${generatedAt.month.toString().padLeft(2, '0')}/${generatedAt.year}';
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    final categories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    String money(num value) => 'Rs. ${value.toStringAsFixed(0)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(27, 25, 27, 34),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 9),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: line, width: 0.8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(children: [
                pw.Container(width: 24, height: 24, child: pw.Image(logo, fit: pw.BoxFit.contain)),
                pw.SizedBox(width: 7),
                pw.Text('CATERPRO', style: pw.TextStyle(
                fontSize: 9, fontWeight: pw.FontWeight.bold,
                letterSpacing: 2, color: navy)),
              ]),
              pw.Text('MONTHLY BUSINESS REPORT', style: const pw.TextStyle(
                fontSize: 7.5, letterSpacing: 1.1, color: muted)),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: line, width: 0.8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('POWERED BY CATERPRO', style: pw.TextStyle(
                fontSize: 7, fontWeight: pw.FontWeight.bold,
                letterSpacing: 1, color: muted)),
              pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 7, color: muted)),
            ],
          ),
        ),
        build: (context) => [
          // Cover-style report heading.
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(20, 18, 20, 17),
            decoration: pw.BoxDecoration(
              color: navy,
              borderRadius: pw.BorderRadius.circular(13),
              border: const pw.Border(bottom: pw.BorderSide(color: gold, width: 3)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(width: 43, height: 43, child: pw.Image(logo)),
                pw.SizedBox(width: 13),
                pw.Expanded(child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CaterPro', style: pw.TextStyle(
                      color: PdfColors.white, fontSize: 21,
                      fontWeight: pw.FontWeight.bold, letterSpacing: -0.4)),
                    pw.SizedBox(height: 3),
                    pw.Text('CATERING WORK & MONTHLY FINANCE REPORT',
                      style: const pw.TextStyle(color: PdfColor.fromInt(0xFFD5DFEA), fontSize: 7.5, letterSpacing: 0.8)),
                  ],
                )),
                pw.Container(width: 1, height: 40, color: PdfColor.fromInt(0xFF496078)),
                pw.SizedBox(width: 13),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  pw.Text(monthLabel, style: pw.TextStyle(
                    color: gold, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('GENERATED  $generatedLabel', style: const pw.TextStyle(
                    color: PdfColor.fromInt(0xFFD5DFEA), fontSize: 7)),
                ]),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(children: [
            pw.Expanded(child: _premiumMetric('TOTAL INCOME', money(totalIncome), green, const PdfColor.fromInt(0xFFEAF7EF))),
            pw.SizedBox(width: 7),
            pw.Expanded(child: _premiumMetric('TOTAL EXPENSES', money(totalExpenses), red, const PdfColor.fromInt(0xFFFFEEEE))),
            pw.SizedBox(width: 7),
            pw.Expanded(child: _premiumMetric('NET SAVINGS', money(netSavings), navyLight, const PdfColor.fromInt(0xFFEDF3FA))),
            pw.SizedBox(width: 7),
            pw.Expanded(child: _premiumMetric('TOTAL WORKS', '${works.length.toString().padLeft(2, '0')}', navy, const PdfColor.fromInt(0xFFF0F0FA))),
          ]),
          pw.SizedBox(height: 19),
          _premiumSectionTitle('01', 'Catering Works', monthLabel),
          pw.SizedBox(height: 8),
          if (works.isEmpty)
            _emptyReportState('No catering works recorded for this month.')
          else
            _premiumTable(
              headers: ['#', 'DATE', 'VENUE & LOCATION', 'EVENT', 'AMOUNT', 'STATUS'],
              widths: [0.42, 0.85, 2.55, 0.85, 0.88, 0.82],
              rows: works.map((w) => [
                w.number, w.dateText, '${w.venue} (${w.location})',
                w.eventType, money(w.amount), w.status,
              ]).toList(),
              statusColumn: 5,
            ),
          pw.SizedBox(height: 18),
          _premiumSectionTitle('02', 'Monthly Expenses', monthLabel),
          pw.SizedBox(height: 8),
          if (expenses.isEmpty)
            _emptyReportState('No expenses recorded for this month.')
          else
            _premiumTable(
              headers: ['#', 'DATE', 'DESCRIPTION / SHOP', 'CATEGORY', 'AMOUNT'],
              widths: [0.42, 0.85, 2.85, 1.05, 0.95],
              rows: expenses.map((e) => [
                e.number, e.dateText,
                e.subNote.trim().isEmpty ? e.title : '${e.title} (${e.subNote})',
                e.category, money(e.amount),
              ]).toList(),
            ),
          pw.SizedBox(height: 18),
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Expanded(
              flex: 5,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: pale, borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: line),
                ),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('EXPENSE BREAKDOWN', style: pw.TextStyle(
                    color: navy, fontSize: 9, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
                  pw.SizedBox(height: 9),
                  if (categories.isEmpty)
                    pw.Text('No expense data available.', style: const pw.TextStyle(fontSize: 8, color: muted))
                  else ...categories.map((entry) {
                    final percent = totalExpenses > 0 ? (entry.value / totalExpenses * 100) : 0.0;
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 7),
                      child: pw.Column(children: [
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                          pw.Expanded(child: pw.Text(entry.key, style: const pw.TextStyle(fontSize: 8, color: ink))),
                          pw.Text('${money(entry.value)}  ${percent.toStringAsFixed(1)}%',
                            style: pw.TextStyle(fontSize: 7.5, color: navy, fontWeight: pw.FontWeight.bold)),
                        ]),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          height: 5, width: 150,
                          decoration: pw.BoxDecoration(color: line, borderRadius: pw.BorderRadius.circular(3)),
                          child: pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Container(
                              height: 5, width: 150 * (percent / 100).clamp(0.0, 1.0).toDouble(),
                              decoration: pw.BoxDecoration(color: gold, borderRadius: pw.BorderRadius.circular(3)),
                            ),
                          ),
                        ),
                      ]),
                    );
                  }),
                ]),
              ),
            ),
            pw.SizedBox(width: 9),
            pw.Expanded(
              flex: 6,
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.white, borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: line),
                ),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: pw.BoxDecoration(color: navy, borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(9))),
                    child: pw.Text('MONTHLY FINANCIAL SUMMARY', style: pw.TextStyle(
                      color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(11),
                    child: pw.Column(children: [
                      _financialLine('Total Revenue', money(totalIncome), green),
                      _financialLine('Total Expenses', money(totalExpenses), red),
                      _financialLine('Net Savings', money(netSavings), navy),
                      _financialLine('Total Works', '${works.length}', ink, last: true),
                    ]),
                  ),
                ]),
              ),
            ),
          ]),
          pw.SizedBox(height: 15),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 9, horizontal: 12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF9F6ED),
              borderRadius: pw.BorderRadius.circular(8),
              border: const pw.Border(left: pw.BorderSide(color: gold, width: 3)),
            ),
            child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('CATERPRO  •  CATERING MANAGEMENT MADE EASY',
                style: pw.TextStyle(fontSize: 7, color: navy, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
              pw.Text('Efficient Planning. Successful Events.',
                style: pw.TextStyle(fontSize: 7, color: muted, fontStyle: pw.FontStyle.italic)),
            ]),
          ),
        ],
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'CaterPro_${monthLabel.replaceAll(' ', '_')}_Report.pdf',
    );
  }

  static pw.Widget _premiumMetric(String title, String value, PdfColor valueColor, PdfColor background) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(8, 11, 7, 10),
      decoration: pw.BoxDecoration(
        color: background, borderRadius: pw.BorderRadius.circular(9),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE6EAF0)),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 6.2, color: PdfColor.fromInt(0xFF64748B), letterSpacing: 0.35)),
        pw.SizedBox(height: 6),
        pw.Text(value, maxLines: 1, style: pw.TextStyle(
          fontSize: 11.5, fontWeight: pw.FontWeight.bold, color: valueColor)),
      ]),
    );
  }

  static pw.Widget _premiumSectionTitle(String number, String title, String subtitle) {
    return pw.Row(children: [
      pw.Container(
        width: 23, height: 23, alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0xFFF7EED9), borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Text(number, style: pw.TextStyle(fontSize: 8, color: const PdfColor.fromInt(0xFF9A6A12), fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(width: 8),
      pw.Expanded(child: pw.Text(title, style: pw.TextStyle(
        fontSize: 12, color: const PdfColor.fromInt(0xFF10243A), fontWeight: pw.FontWeight.bold))),
      pw.Text(subtitle.toUpperCase(), style: const pw.TextStyle(
        fontSize: 6.5, color: PdfColor.fromInt(0xFF8491A2), letterSpacing: 0.5)),
    ]);
  }

  static pw.Widget _premiumTable({
    required List<String> headers,
    required List<double> widths,
    required List<List<String>> rows,
    int? statusColumn,
  }) {
    const navy = PdfColor.fromInt(0xFF10243A);
    const border = PdfColor.fromInt(0xFFE1E7EF);
    final tableRows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: navy),
        children: headers.map((header) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: pw.Text(header, style: pw.TextStyle(
            fontSize: 6.5, color: PdfColors.white, fontWeight: pw.FontWeight.bold, letterSpacing: 0.25)),
        )).toList(),
      ),
      ...List.generate(rows.length, (rowIndex) {
        final row = rows[rowIndex];
        return pw.TableRow(
          decoration: pw.BoxDecoration(color: rowIndex.isEven ? PdfColors.white : const PdfColor.fromInt(0xFFF5F7FA)),
          children: List.generate(row.length, (columnIndex) {
            final value = row[columnIndex];
            if (statusColumn == columnIndex) {
              final paid = value.toLowerCase().contains('paid');
              final color = paid ? const PdfColor.fromInt(0xFF16834A) : const PdfColor.fromInt(0xFFB96A0B);
              final bg = paid ? const PdfColor.fromInt(0xFFE7F6ED) : const PdfColor.fromInt(0xFFFFF2DE);
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                child: pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                  decoration: pw.BoxDecoration(color: bg, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Text(value, style: pw.TextStyle(fontSize: 6.5, color: color, fontWeight: pw.FontWeight.bold)),
                ),
              );
            }
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 7),
              child: pw.Text(value, maxLines: 5, style: pw.TextStyle(
                fontSize: 6.8, color: const PdfColor.fromInt(0xFF243447),
                fontWeight: columnIndex == row.length - 1 ? pw.FontWeight.bold : pw.FontWeight.normal)),
            );
          }),
        );
      }),
    ];
    return pw.Table(
      columnWidths: {for (var i = 0; i < widths.length; i++) i: pw.FlexColumnWidth(widths[i])},
      border: pw.TableBorder(
        horizontalInside: const pw.BorderSide(color: border, width: 0.55),
        verticalInside: const pw.BorderSide(color: border, width: 0.45),
        top: const pw.BorderSide(color: border, width: 0.7),
        bottom: const pw.BorderSide(color: border, width: 0.7),
        left: const pw.BorderSide(color: border, width: 0.7),
        right: const pw.BorderSide(color: border, width: 0.7),
      ),
      children: tableRows,
    );
  }

  static pw.Widget _emptyReportState(String message) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: const PdfColor.fromInt(0xFFF7F9FC),
      border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Text(message, style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF718096))),
  );

  static pw.Widget _financialLine(String label, String value, PdfColor color, {bool last = false}) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        decoration: last ? null : const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFEDF0F4), width: 0.6))),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF64748B))),
          pw.Text(value, style: pw.TextStyle(fontSize: 8.5, color: color, fontWeight: pw.FontWeight.bold)),
        ]),
      );

  // Complete lifetime work history report. It uses the same stored records and
  // derives totals from the existing WorkItem / ExpenseItem fields.
  static Future<void> exportAllWorksReport({
    required List<WorkItem> works,
    required List<ExpenseItem> expenses,
  }) async {
    final pdf = pw.Document();
    const navy = PdfColor.fromInt(0xFF071B33);
    const gold = PdfColor.fromInt(0xFFE7B84F);
    const ink = PdfColor.fromInt(0xFF172638);
    const muted = PdfColor.fromInt(0xFF718096);
    const line = PdfColor.fromInt(0xFFE2E8F0);
    const green = PdfColor.fromInt(0xFF16834A);
    const red = PdfColor.fromInt(0xFFD94141);
    final sortedWorks = List<WorkItem>.from(works)
      ..sort((a, b) => b.date.compareTo(a.date));
    final sortedExpenses = List<ExpenseItem>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    final income = works.fold<double>(0, (sum, w) => sum + w.amount);
    final pending = works.fold<double>(0, (sum, w) => sum + (w.isPaid ? 0.0 : w.balance));
    final received = income - pending;
    final expenseTotal = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final savings = received - expenseTotal;
    final paidCount = works.where((w) => w.isPaid).length;
    final pendingCount = works.length - paidCount;
    final generated = DateTime.now();
    final generatedLabel = '${generated.day.toString().padLeft(2, '0')}/'
        '${generated.month.toString().padLeft(2, '0')}/${generated.year}';
    final logoBytes = (await rootBundle.load('assets/branding/caterpro_mark.png'))
        .buffer.asUint8List();
    final logo = pw.MemoryImage(logoBytes);
    String money(num value) => 'Rs. ${value.toStringAsFixed(0)}';

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(26, 24, 26, 34),
      header: (context) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: line, width: .7))),
        child: pw.Row(children: [
          pw.Container(width: 25, height: 25, child: pw.Image(logo)),
          pw.SizedBox(width: 7),
          pw.Text('CATERPRO', style: pw.TextStyle(fontSize: 9,
            fontWeight: pw.FontWeight.bold, letterSpacing: 1.5, color: navy)),
          pw.Spacer(),
          pw.Text('COMPLETE WORK HISTORY', style: const pw.TextStyle(
            fontSize: 7, letterSpacing: .8, color: muted)),
        ]),
      ),
      footer: (context) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 7),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: line, width: .7))),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('POWERED BY CATERPRO', style: pw.TextStyle(fontSize: 7,
            fontWeight: pw.FontWeight.bold, letterSpacing: .8, color: muted)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7, color: muted)),
        ]),
      ),
      build: (context) => [
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: pw.BoxDecoration(color: navy,
            borderRadius: pw.BorderRadius.circular(11),
            border: const pw.Border(bottom: pw.BorderSide(color: gold, width: 2.5))),
          child: pw.Row(children: [
            pw.Container(width: 43, height: 43, child: pw.Image(logo)),
            pw.SizedBox(width: 11),
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('All Works Report', style: pw.TextStyle(color: PdfColors.white,
                fontSize: 19, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 3),
              pw.Text('COMPLETE CATERING WORK & FINANCE HISTORY',
                style: const pw.TextStyle(color: PdfColor.fromInt(0xFFD5DFEA), fontSize: 7, letterSpacing: .5)),
            ])),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text('${works.length} WORKS', style: pw.TextStyle(color: gold,
                fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('GENERATED $generatedLabel', style: const pw.TextStyle(
                color: PdfColor.fromInt(0xFFD5DFEA), fontSize: 6.5)),
            ]),
          ]),
        ),
        pw.SizedBox(height: 13),
        pw.Row(children: [
          pw.Expanded(child: _premiumMetric('TOTAL WORK VALUE', money(income), green, const PdfColor.fromInt(0xFFEAF7EF))),
          pw.SizedBox(width: 6),
          pw.Expanded(child: _premiumMetric('RECEIVED', money(received), green, const PdfColor.fromInt(0xFFEAF7EF))),
          pw.SizedBox(width: 6),
          pw.Expanded(child: _premiumMetric('PENDING', money(pending), const PdfColor.fromInt(0xFFB96A0B), const PdfColor.fromInt(0xFFFFF4E5))),
          pw.SizedBox(width: 6),
          pw.Expanded(child: _premiumMetric('TOTAL WORKS', '${works.length}', navy, const PdfColor.fromInt(0xFFF0F3F8))),
        ]),
        pw.SizedBox(height: 7),
        pw.Row(children: [
          pw.Expanded(child: _premiumMetric('TOTAL EXPENSES', money(expenseTotal), red, const PdfColor.fromInt(0xFFFFEEEE))),
          pw.SizedBox(width: 6),
          pw.Expanded(child: _premiumMetric('NET SAVINGS', money(savings), navy, const PdfColor.fromInt(0xFFEDF3FA))),
          pw.SizedBox(width: 6),
          pw.Expanded(child: _premiumMetric('PAID WORKS', '$paidCount', green, const PdfColor.fromInt(0xFFEAF7EF))),
          pw.SizedBox(width: 6),
          pw.Expanded(child: _premiumMetric('PENDING WORKS', '$pendingCount', const PdfColor.fromInt(0xFFB96A0B), const PdfColor.fromInt(0xFFFFF4E5))),
        ]),
        pw.SizedBox(height: 17),
        _premiumSectionTitle('01', 'Complete Catering Work History', 'ALL DATES'),
        pw.SizedBox(height: 7),
        if (sortedWorks.isEmpty)
          _emptyReportState('No catering works have been recorded yet.')
        else
          _premiumTable(
            headers: ['#', 'DATE', 'VENUE / EVENT DETAILS', 'AMOUNT', 'BALANCE', 'STATUS'],
            widths: [0.42, 0.83, 3.05, 0.82, 0.82, 0.78],
            rows: sortedWorks.map((w) => [
              w.number, w.dateText,
              '${w.venue}\n${w.location} • ${w.eventType}\n${w.reportingTime} • ${w.paxCount}${w.note.trim().isEmpty ? '' : '\n${w.note}'}',
              money(w.amount), money(w.balance), w.isPaid ? 'Paid' : 'Pending',
            ]).toList(), statusColumn: 5),
        pw.SizedBox(height: 16),
        _premiumSectionTitle('02', 'Complete Expense History', 'ALL DATES'),
        pw.SizedBox(height: 7),
        if (sortedExpenses.isEmpty)
          _emptyReportState('No expenses have been recorded yet.')
        else
          _premiumTable(
            headers: ['#', 'DATE', 'DESCRIPTION / SHOP', 'CATEGORY', 'AMOUNT'],
            widths: [0.42, 0.83, 2.85, 1.05, 0.9],
            rows: sortedExpenses.map((e) => [
              e.number, e.dateText,
              e.subNote.trim().isEmpty ? e.title : '${e.title} (${e.subNote})',
              e.category, money(e.amount),
            ]).toList()),
        pw.SizedBox(height: 14),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0xFFF5F7FA),
            borderRadius: pw.BorderRadius.circular(9), border: pw.Border.all(color: line)),
          child: pw.Column(children: [
            _financialLine('Total work value', money(income), navy),
            _financialLine('Payments received', money(received), green),
            _financialLine('Pending balance', money(pending), const PdfColor.fromInt(0xFFB96A0B)),
            _financialLine('Total expenses', money(expenseTotal), red),
            _financialLine('Net savings (received − expenses)', money(savings), navy, last: true),
          ]),
        ),
        pw.SizedBox(height: 12),
        pw.Align(alignment: pw.Alignment.center,
          child: pw.Text('Efficient Planning. Successful Events.',
            style: pw.TextStyle(fontSize: 7, color: muted, fontStyle: pw.FontStyle.italic))),
      ],
    ));

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'CaterPro_All_Works_Report.pdf');
  }

  // 2. SINGLE WORK RECEIPT / INVOICE GENERATOR (For individual work sharing)
  static Future<void> exportWorkInvoice(WorkItem work) async {
    final pdf = pw.Document();
    final logoBytes = (await rootBundle.load('assets/branding/caterpro_mark.png')).buffer.asUint8List();
    final logo = pw.MemoryImage(logoBytes);
    const navy = PdfColor.fromInt(0xFF071B33);
    const gold = PdfColor.fromInt(0xFFE7B84F);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(color: navy, borderRadius: pw.BorderRadius.circular(12),
                  border: const pw.Border(bottom: pw.BorderSide(color: gold, width: 3))),
                child: pw.Row(children: [
                  pw.Container(width: 54, height: 54, child: pw.Image(logo, fit: pw.BoxFit.contain)),
                  pw.SizedBox(width: 12),
                  pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('CATERPRO', style: pw.TextStyle(fontSize: 19, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 1.2)),
                    pw.SizedBox(height: 3),
                    pw.Text('CATERING INVOICE  •  BOOKING CONFIRMATION', style: const pw.TextStyle(fontSize: 7, color: PdfColor.fromInt(0xFFD5DFEA), letterSpacing: .5)),
                  ])),
                  pw.Text('WORK #${work.number}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: gold)),
                ]),
              ),
              pw.SizedBox(height: 22),
              pw.SizedBox(height: 10),

              pw.Text('Event Details', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildInvoiceRow('Venue / Auditorium:', work.venue),
              _buildInvoiceRow('Location:', work.location),
              _buildInvoiceRow('Event Date:', work.dateText),
              _buildInvoiceRow('Reporting Time:', work.reportingTime),
              _buildInvoiceRow('Event Type:', work.eventType),
              _buildInvoiceRow('Plates / Pax:', work.paxCount),
              if (work.note.isNotEmpty) _buildInvoiceRow('Note / Contact:', work.note),

              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              pw.Text('Payment Summary', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildInvoiceRow('Total Amount:', 'Rs ${work.amount.toStringAsFixed(0)}'),
              _buildInvoiceRow('Advance Received:', 'Rs ${(work.amount - work.balance).toStringAsFixed(0)}'),
              _buildInvoiceRow('Balance Pending:', 'Rs ${work.balance.toStringAsFixed(0)}'),
              _buildInvoiceRow('Payment Status:', work.status),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Work_${work.number}_${work.venue.replaceAll(" ", "_")}.pdf',
    );
  }

  static pw.Widget _buildSummaryItem(String title, String val, PdfColor valColor) {
    return pw.Column(
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(val, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: valColor)),
      ],
    );
  }

  static pw.Widget _buildInvoiceRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
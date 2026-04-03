import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// IRDN-compliant VAT Return PDF Generator for Nepal
class VatPdfGenerator {
  static const String _irdnHeader = 'Inland Revenue Department Nepal';
  static const String _formName = 'VAT Return Form';

  /// Generate VAT Return PDF report
  static Future<Uint8List> generateVatReturnPdf({
    required int month,
    required int year,
    required Map<String, dynamic> summary,
    required List<dynamic> records,
    String? companyName,
    String? panNumber,
  }) async {
    final pdf = pw.Document();

    // Load fonts
    final regularFont = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final boldFont = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(context, month, year),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildCompanyInfo(companyName, panNumber),
          pw.SizedBox(height: 20),
          _buildSummarySection(summary),
          pw.SizedBox(height: 20),
          _buildTransactionsTable(records),
          pw.SizedBox(height: 20),
          _buildDeclarationSection(),
        ],
      ),
    );

    return pdf.save();
  }

  /// Build PDF Header with IRDN branding
  static pw.Widget _buildHeader(pw.Context context, int month, int year) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Column(
              children: [
                pw.Text(
                  _irdnHeader,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  'वित्त विभाग, अन्तःशुल्क विभाग',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  _formName,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'For Period: ${_getMonthName(month)} $year',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue800),
        pw.SizedBox(height: 10),
      ],
    );
  }

  /// Build company information section
  static pw.Widget _buildCompanyInfo(String? companyName, String? panNumber) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Taxpayer Information',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Business Name:', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(companyName ?? 'VedantaTrade Pharmaceuticals', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('PAN Number:', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(panNumber ?? '123456789', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build VAT summary section
  static pw.Widget _buildSummarySection(Map<String, dynamic> summary) {
    final totalTaxable = summary['totalTaxable'] ?? 0;
    final totalVat = summary['totalVat'] ?? 0;
    final totalVatSales = summary['totalVatSales'] ?? 0;
    final totalVatPurchases = summary['totalVatPurchases'] ?? 0;
    final netVatPayable = summary['netVatPayable'] ?? 0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'VAT Summary',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            children: [
              _buildSummaryRow('Total Taxable Amount', 'NPR $totalTaxable'),
              _buildSummaryRow('Total VAT Collected (Sales)', 'NPR $totalVatSales', isPositive: true),
              _buildSummaryRow('Total VAT Paid (Purchases)', 'NPR $totalVatPurchases', isPositive: false),
              _buildSummaryRow('Net VAT Payable', 'NPR $netVatPayable', isBold: true, 
                color: (netVatPayable as num) > 0 ? PdfColors.red : PdfColors.green),
            ],
          ),
        ],
      ),
    );
  }

  /// Build summary table row
  static pw.TableRow _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isPositive = false,
    PdfColor? color,
  }) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isBold ? pw.FontWeight.bold : null,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isBold ? pw.FontWeight.bold : null,
              color: color,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Build transactions table
  static pw.Widget _buildTransactionsTable(List<dynamic> records) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Transaction Details',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue100),
              children: [
                _buildTableHeader('Invoice Number'),
                _buildTableHeader('Taxable Amount'),
                _buildTableHeader('VAT Amount'),
                _buildTableHeader('Rate'),
              ],
            ),
            // Data rows
            ...records.map((record) {
              final invoice = record['invoice']?['invoiceNumber'] ?? 'N/A';
              final taxable = record['taxableAmount'] ?? 0;
              final vat = record['totalVat'] ?? 0;
              final rate = record['vatRate'] ?? 13;

              return pw.TableRow(
                children: [
                  _buildTableCell(invoice),
                  _buildTableCell('NPR $taxable', alignRight: true),
                  _buildTableCell('NPR $vat', alignRight: true),
                  _buildTableCell('$rate%', alignRight: true),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  /// Build table header cell
  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  /// Build table data cell
  static pw.Widget _buildTableCell(String text, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
        textAlign: alignRight ? pw.TextAlign.right : null,
      ),
    );
  }

  /// Build declaration section
  static pw.Widget _buildDeclarationSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Declaration',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'I hereby declare that the information furnished in this VAT return is true and correct to the best of my knowledge and belief.',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(width: 150, height: 1, color: PdfColors.black),
                  pw.SizedBox(height: 4),
                  pw.Text('Signature of Taxpayer', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(width: 150, height: 1, color: PdfColors.black),
                  pw.SizedBox(height: 4),
                  pw.Text('Date', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build footer with page numbers
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by VedantaTrade System',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  /// Export and share PDF
  static Future<void> exportAndShare({
    required int month,
    required int year,
    required Map<String, dynamic> summary,
    required List<dynamic> records,
    String? companyName,
    String? panNumber,
  }) async {
    try {
      final pdfBytes = await generateVatReturnPdf(
        month: month,
        year: year,
        summary: summary,
        records: records,
        companyName: companyName,
        panNumber: panNumber,
      );

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'VAT_Return_${year}_${month.toString().padLeft(2, '0')}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'VAT Return Report - ${VatPdfGenerator._getMonthName(month)} $year',
        text: 'IRDN-compliant VAT Return Report for ${VatPdfGenerator._getMonthName(month)} $year',
      );
    } catch (e) {
      throw Exception('Failed to export VAT PDF: $e');
    }
  }

  /// Get month name from number
  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

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

    try {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) => [
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
    } catch (e) {
      // Using print instead of debugPrint for web compatibility
      
      rethrow;
    }
  }

  /// Build company information section
  static pw.Widget _buildCompanyInfo(String? companyName, String? panNumber) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Company Information',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          if (companyName != null)
            pw.Text('Name: $companyName', style: const pw.TextStyle(fontSize: 8)),
          if (panNumber != null)
            pw.Text('PAN: $panNumber', style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  /// Build summary section
  static pw.Widget _buildSummarySection(Map<String, dynamic> summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Total Sales: ${summary['totalSales'] ?? 0}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'VAT Amount: ${summary['vatAmount'] ?? 0}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build transactions table
  static pw.Widget _buildTransactionsTable(List<dynamic> records) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Transactions',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          // Table header
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Date',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'Description',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'Amount',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          // Table rows
          ...records.map((record) {
            return pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    record['date'] ?? '',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    record['description'] ?? '',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    record['amount']?.toString() ?? '0',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
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
            'I hereby declare that information furnished in this VAT return is true and correct to best of my knowledge and belief.',
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

  /// Save and share PDF
  static Future<void> saveAndSharePdf(Uint8List pdfBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      
      // Share file
      final xFile = XFile.fromData(pdfBytes, name: fileName);
      await Share.shareXFiles([xFile]);
    } catch (e) {
      
      throw Exception('Failed to save PDF: $e');
    }
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

      final tempDir = await getTemporaryDirectory();
      final fileName = 'VAT_Return_${year}_${month.toString().padLeft(2, '0')}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      // Share file
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        subject: 'VAT Return Report - ${_getMonthName(month)} $year',
        text: 'IRDN-compliant VAT Return Report for ${_getMonthName(month)} $year',
      );
    } catch (e) {
      
      throw Exception('Failed to export PDF: $e');
    }
  }

  /// Get month name
  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

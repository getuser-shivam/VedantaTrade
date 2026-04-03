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

    // Load fonts
    final regularFont = await PdfGoogleFonts.notoSans();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(context, month, year, regularFont, boldFont),
        footer: (context) => _buildFooter(context, regularFont),
        build: (context) => [
          _buildCompanyInfo(companyName, panNumber, regularFont, boldFont),
          pw.SizedBox(height: 20),
          _buildSummarySection(summary, regularFont, boldFont),
          pw.SizedBox(height: 20),
          _buildTransactionsTable(records, regularFont, boldFont),
          pw.SizedBox(height: 20),
          _buildDeclarationSection(regularFont, boldFont),
        ],
      ),
    );

    return pdf.save();
  }

  /// Build PDF header
  static pw.Widget _buildHeader(
    pw.Context context,
    int month,
    int year,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            _irdnHeader,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            font: boldFont,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            _formName,
            style: const pw.TextStyle(fontSize: 9),
            font: regularFont,
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Tax Period',
                    style: const pw.TextStyle(fontSize: 8),
                    font: regularFont,
                  ),
                  pw.Container(width: 150, height: 1, color: PdfColors.black),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Signature of Taxpayer',
                    style: const pw.TextStyle(fontSize: 8),
                    font: regularFont,
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Date',
                    style: const pw.TextStyle(fontSize: 8),
                    font: regularFont,
                  ),
                  pw.Container(width: 150, height: 1, color: PdfColors.black),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Signature of Officer',
                    style: const pw.TextStyle(fontSize: 8),
                    font: regularFont,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build company information section
  static pw.Widget _buildCompanyInfo(
    String? companyName,
    String? panNumber,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
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
            font: boldFont,
          ),
          pw.SizedBox(height: 10),
          if (companyName != null)
            pw.Text('Name: $companyName', style: const pw.TextStyle(fontSize: 8), font: regularFont),
          if (panNumber != null)
            pw.Text('PAN: $panNumber', style: const pw.TextStyle(fontSize: 8), font: regularFont),
        ],
      ),
    );
  }

  /// Build summary section
  static pw.Widget _buildSummarySection(
    Map<String, dynamic> summary,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
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
            font: boldFont,
          ),
          pw.SizedBox(height: 10),
          ...summary.entries.map((entry) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(entry.key, style: const pw.TextStyle(fontSize: 8), font: regularFont),
                pw.Text(entry.value.toString(), style: const pw.TextStyle(fontSize: 8), font: regularFont),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Build transactions table
  static pw.Widget _buildTransactionsTable(
    List<dynamic> records,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
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

      // Share file
      await Share.shareFiles(
        [file.path],
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

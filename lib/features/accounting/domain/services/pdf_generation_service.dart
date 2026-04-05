import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../entities/vat_return_entity.dart';

/// PDF Generation Service for VAT/Tax Returns
/// Generates compliant PDF documents with IRDN formatting

class PdfGenerationService {
  static const String _fontFamily = 'Helvetica';
  static const double _fontSize = 10;
  static const double _headerFontSize = 14;
  static const double _titleFontSize = 18;
  static const double _padding = 16.0;
  static const double _margin = 20.0;
  
  /// Generate VAT Return PDF
  static Future<Uint8List> generateVatReturnPdf(VatReturnEntity vatReturn) async {
    final pdf = PdfDocument();
    
    // Add title page
    pdf.addPage(await _buildTitlePage(vatReturn));
    
    // Add business information page
    pdf.addPage(await _buildBusinessInfoPage(vatReturn));
    
    // Add summary page
    pdf.addPage(await _buildSummaryPage(vatReturn));
    
    // Add sales details page
    if (vatReturn.salesItems.isNotEmpty) {
      pdf.addPage(await _buildSalesDetailsPage(vatReturn));
    }
    
    // Add purchase details page
    if (vatReturn.purchaseItems.isNotEmpty) {
      pdf.addPage(await _buildPurchaseDetailsPage(vatReturn));
    }
    
    // Add tax details page
    if (vatReturn.taxDetails.isNotEmpty) {
      pdf.addPage(await _buildTaxDetailsPage(vatReturn));
    }
    
    // Add IRDN compliance page
    pdf.addPage(await _buildIrdnCompliancePage(vatReturn));
    
    // Add signature page
    pdf.addPage(await _buildSignaturePage(vatReturn));
    
    return pdf.save();
  }
  
  /// Build title page
  static Future<Page> _buildTitlePage(VatReturnEntity vatReturn) async {
    return Page(
      margin: const EdgeInsets.all(_margin),
      build: (Context context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Nepal Government Logo placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.black),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  'GOV\nNEP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: _fontFamily,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Main title
            Text(
              'VAT RETURN',
              style: TextStyle(
                fontSize: _titleFontSize,
                fontWeight: FontWeight.bold,
                fontFamily: _fontFamily,
              ),
            ),
            SizedBox(height: 10),
            
            // Subtitle
            Text(
              'Inland Revenue Department of Nepal',
              style: TextStyle(
                fontSize: _fontSize + 2,
                fontWeight: FontWeight.bold,
                fontFamily: _fontFamily,
              ),
            ),
            SizedBox(height: 5),
            
            Text(
              'Government of Nepal',
              style: TextStyle(
                fontSize: _fontSize,
                fontFamily: _fontFamily,
              ),
            ),
            SizedBox(height: 30),
            
            // Business information
            Container(
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Business Name:', vatReturn.businessName),
                  _buildInfoRow('Business Address:', vatReturn.businessAddress),
                  _buildInfoRow('PAN Number:', vatReturn.businessPan),
                  _buildInfoRow('IRDN Number:', vatReturn.businessIrdn),
                ],
              ),
            ),
            SizedBox(height: 30),
            
            // Tax period information
            Container(
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Tax Period:', vatReturn.taxPeriod),
                  _buildInfoRow('Start Date:', _formatDate(vatReturn.startDate)),
                  _buildInfoRow('End Date:', _formatDate(vatReturn.endDate)),
                  _buildInfoRow('Filing Date:', _formatDate(vatReturn.filingDate)),
                  _buildInfoRow('Return Type:', _formatReturnType(vatReturn.returnType)),
                  _buildInfoRow('Status:', _formatStatus(vatReturn.status)),
                ],
              ),
            ),
            Spacer(),
            
            // Reference numbers
            if (vatReturn.submissionReference != null)
              _buildInfoRow('Submission Reference:', vatReturn.submissionReference!),
            if (vatReturn.irdnReference != null)
              _buildInfoRow('IRDN Reference:', vatReturn.irdnReference!),
            
            SizedBox(height: 20),
            
            // Generation date
            Text(
              'Generated on: ${_formatDate(DateTime.now())}',
              style: TextStyle(
                fontSize: _fontSize - 2,
                fontFamily: _fontFamily,
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Build business information page
  static Future<Page> _buildBusinessInfoPage(VatReturnEntity vatReturn) async {
    return Page(
      margin: const EdgeInsets.all(_margin),
      build: (Context context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header
            _buildPageHeader('Business Information'),
            SizedBox(height: 20),
            
            // Business details
            Container(
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Business Details'),
                  SizedBox(height: 10),
                  _buildInfoRow('Business Name:', vatReturn.businessName),
                  _buildInfoRow('Business Address:', vatReturn.businessAddress),
                  _buildInfoRow('PAN Number:', vatReturn.businessPan),
                  _buildInfoRow('IRDN Number:', vatReturn.businessIrdn),
                  _buildInfoRow('Tax Period:', vatReturn.taxPeriod),
                  SizedBox(height: 15),
                  
                  _buildSectionTitle('Contact Information'),
                  SizedBox(height: 10),
                  _buildInfoRow('Phone:', '+977-1-XXXXXXX'),
                  _buildInfoRow('Email:', 'business@example.com'),
                  _buildInfoRow('Website:', 'www.example.com'),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Tax summary
            Container(
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Tax Summary'),
                  SizedBox(height: 10),
                  _buildInfoRow('Total Sales:', _formatCurrency(vatReturn.totalSales)),
                  _buildInfoRow('Total Purchases:', _formatCurrency(vatReturn.totalPurchases)),
                  _buildInfoRow('Taxable Sales:', _formatCurrency(vatReturn.taxableSales)),
                  _buildInfoRow('Exempt Sales:', _formatCurrency(vatReturn.exemptSales)),
                  _buildInfoRow('Zero-Rated Sales:', _formatCurrency(vatReturn.zeroRatedSales)),
                  _buildInfoRow('Input Tax:', _formatCurrency(vatReturn.inputTax)),
                  _buildInfoRow('Output Tax:', _formatCurrency(vatReturn.outputTax)),
                  _buildInfoRow('Net Tax Payable:', _formatCurrency(vatReturn.netTaxPayable)),
                  _buildInfoRow('Tax Paid:', _formatCurrency(vatReturn.taxPaid)),
                  _buildInfoRow('Tax Refundable:', _formatCurrency(vatReturn.taxRefundable)),
                  _buildInfoRow('Penalty:', _formatCurrency(vatReturn.penalty)),
                  _buildInfoRow('Interest:', _formatCurrency(vatReturn.interest)),
                  _buildInfoRow('Total Amount Due:', _formatCurrency(vatReturn.totalAmountDue)),
                ],
              ),
            ),
            Spacer(),
            
            // Page footer
            _buildPageFooter(1),
          ],
        );
      },
    );
  }
  
  /// Build summary page
  static Future<Page> _buildSummaryPage(VatReturnEntity vatReturn) async {
    return Page(
      margin: const EdgeInsets.all(_margin),
      orientation: PageOrientation.landscape,
      build: (Context context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header
            _buildPageHeader('VAT Return Summary'),
            SizedBox(height: 20),
            
            // Summary table
            Container(
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sales summary
                  _buildSectionTitle('Sales Summary'),
                  SizedBox(height: 10),
                  _buildSummaryTable([
                    ['Description', 'Amount (NPR)', 'VAT Rate', 'VAT Amount'],
                    ['Total Sales', _formatCurrency(vatReturn.totalSales), '-', '-'],
                    ['Taxable Sales', _formatCurrency(vatReturn.taxableSales), '-', '-'],
                    ['Exempt Sales', _formatCurrency(vatReturn.exemptSales), 'Exempt', '-'],
                    ['Zero-Rated Sales', _formatCurrency(vatReturn.zeroRatedSales), '0%', '-'],
                    ['Output Tax', '-', '-', _formatCurrency(vatReturn.outputTax)],
                  ]),
                  SizedBox(height: 20),
                  
                  // Purchase summary
                  _buildSectionTitle('Purchase Summary'),
                  SizedBox(height: 10),
                  _buildSummaryTable([
                    ['Description', 'Amount (NPR)', 'VAT Rate', 'VAT Amount'],
                    ['Total Purchases', _formatCurrency(vatReturn.totalPurchases), '-', '-'],
                    ['Input Tax', '-', '-', _formatCurrency(vatReturn.inputTax)],
                  ]),
                  SizedBox(height: 20),
                  
                  // Tax calculation
                  _buildSectionTitle('Tax Calculation'),
                  SizedBox(height: 10),
                  _buildSummaryTable([
                    ['Description', 'Amount (NPR)'],
                    ['Output Tax', _formatCurrency(vatReturn.outputTax)],
                    ['Input Tax', _formatCurrency(vatReturn.inputTax)],
                    ['Net Tax Payable', _formatCurrency(vatReturn.netTaxPayable)],
                    ['Tax Paid', _formatCurrency(vatReturn.taxPaid)],
                    ['Tax Refundable', _formatCurrency(vatReturn.taxRefundable)],
                    ['Penalty', _formatCurrency(vatReturn.penalty)],
                    ['Interest', _formatCurrency(vatReturn.interest)],
                    ['Total Amount Due', _formatCurrency(vatReturn.totalAmountDue)],
                  ]),
                ],
              ),
            ),
            Spacer(),
            
            // Page footer
            _buildPageFooter(2),
          ],
        );
      },
    );
  }
  
  /// Build sales details page
  static Future<Page> _buildSalesDetailsPage(VatReturnEntity vatReturn) async {
    return Page(
      margin: const EdgeInsets.all(_margin),
      orientation: PageOrientation.landscape,
      build: (Context context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header
            _buildPageHeader('Sales Details'),
            SizedBox(height: 20),
            
            // Sales table
            Container(
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Sales Transactions'),
                  SizedBox(height: 10),
                  _buildSalesTable(vatReturn.salesItems),
                ],
              ),
            ),
            Spacer(),
            
            // Page footer
            _buildPageFooter(3),
          ],
        );
      },
    );
  }
  
  /// Build purchase details page
  static Future<Page> _buildPurchaseDetailsPage(VatReturnEntity vatReturn) async {
    return Page(
      margin: const EdgeInsets.all(_margin),
      orientation: PageOrientation.landscape,
      build: (Context context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header
            _buildPageHeader('Purchase Details'),
            SizedBox(height: 20),
            
            // Purchase table
            Container(
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Purchase Transactions'),
                  SizedBox(height: 10),
                  _buildPurchaseTable(vatReturn.purchaseItems),
                ],
              ),
            ),
            Spacer(),
            
            // Page footer
            _buildPageFooter(4),
          ],
        );
      },
    );
  }
  
  /// Build tax details page
  static Future<Page> _buildTaxDetailsPage(VatReturnEntity vatReturn) async {
    return Page(
      margin: const EdgeInsets.all(_margin),
      build: (Context context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header
            _buildPageHeader('Tax Details'),
            SizedBox(height: 20),
            
            // Tax details table
            Container(
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Tax Breakdown by Rate'),
                  SizedBox(height: 10),
                  _buildTaxDetailsTable(vatReturn.taxDetails),
                ],
              ),
            ),
            Spacer(),
            
            // Page footer
            _buildPageFooter(5),
          ],
        );
      },
    );
  }
  
  /// Build IRDN compliance page
  static Future<Page> _buildIrdnCompliancePage(VatReturnEntity vatReturn) async {
    return Page(
      margin: const EdgeInsets.all(_margin),
      build: (Context context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header
            _buildPageHeader('IRDN Compliance Declaration'),
            SizedBox(height: 20),
            
            // Compliance declaration
            Container(
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Declaration'),
                  SizedBox(height: 10),
                  
                  Text(
                    'I, the undersigned, hereby declare that the information furnished in this VAT return is true, '
                    'correct, and complete in all respects to the best of my knowledge and belief. '
                    'I understand that any false or misleading information may result in penalties under '
                    'the applicable tax laws of Nepal.',
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  _buildSectionTitle('IRDN Compliance'),
                  SizedBox(height: 10),
                  
                  Text(
                    'This VAT return has been prepared in accordance with the guidelines and requirements '
                    'of the Inland Revenue Department (IRDN) of Nepal. All calculations have been made '
                    'according to the prevailing VAT rates and regulations.',
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // IRDN status
                  if (vatReturn.irdnStatus != null) ...[
                    _buildSectionTitle('IRDN Submission Status'),
                    SizedBox(height: 10),
                    _buildInfoRow('IRDN Reference:', vatReturn.irdnReference ?? 'Not submitted'),
                    _buildInfoRow('IRDN Status:', vatReturn.irdnStatus!),
                    if (vatReturn.irdnProcessedDate != null)
                      _buildInfoRow('Processed Date:', _formatDate(vatReturn.irdnProcessedDate!)),
                    SizedBox(height: 20),
                  ],
                  
                  // Compliance checklist
                  _buildSectionTitle('Compliance Checklist'),
                  SizedBox(height: 10),
                  _buildComplianceChecklist(),
                ],
              ),
            ),
            Spacer(),
            
            // Page footer
            _buildPageFooter(6),
          ],
        );
      },
    );
  }
  
  /// Build signature page
  static Future<Page> _buildSignaturePage(VatReturnEntity vatReturn) async {
    return Page(
      margin: const EdgeInsets.all(_margin),
      build: (Context context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header
            _buildPageHeader('Signatures and Verification'),
            SizedBox(height: 40),
            
            // Signature sections
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Prepared by
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(_padding),
                    decoration: BoxDecoration(
                      border: Border.all(color: PdfColors.black),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Prepared By'),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: PdfColors.black)),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          vatReturn.generatedBy ?? '_________________',
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontFamily: _fontFamily,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Name & Signature',
                          style: TextStyle(
                            fontSize: _fontSize - 2,
                            fontFamily: _fontFamily,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Date: ${_formatDate(DateTime.now())}',
                          style: TextStyle(
                            fontSize: _fontSize - 2,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                
                // Approved by
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(_padding),
                    decoration: BoxDecoration(
                      border: Border.all(color: PdfColors.black),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Approved By'),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: PdfColors.black)),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          vatReturn.approvedBy ?? '_________________',
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontFamily: _fontFamily,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Name & Signature',
                          style: TextStyle(
                            fontSize: _fontSize - 2,
                            fontFamily: _fontFamily,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Date: _______________',
                          style: TextStyle(
                            fontSize: _fontSize - 2,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            
            // Additional verification
            if (vatReturn.submittedTo != null) ...[
              Container(
                padding: const EdgeInsets.all(_padding),
                decoration: BoxDecoration(
                  border: Border.all(color: PdfColors.black),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Submitted To'),
                    SizedBox(height: 10),
                    _buildInfoRow('Submitted To:', vatReturn.submittedTo!),
                    if (vatReturn.submittedDate != null)
                      _buildInfoRow('Submission Date:', _formatDate(vatReturn.submittedDate!)),
                    if (vatReturn.submissionReference != null)
                      _buildInfoRow('Submission Reference:', vatReturn.submissionReference!),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
            
            // Comments
            if (vatReturn.comments != null && vatReturn.comments!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(_padding),
                decoration: BoxDecoration(
                  border: Border.all(color: PdfColors.black),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Comments'),
                    SizedBox(height: 10),
                    Text(
                      vatReturn.comments!,
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontFamily: _fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
            
            Spacer(),
            
            // Page footer
            _buildPageFooter(7),
          ],
        );
      },
    );
  }
  
  /// Build page header
  static Widget _buildPageHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        border: Border.all(color: PdfColors.black),
        color: PdfColors.grey200,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: _headerFontSize,
          fontWeight: FontWeight.bold,
          fontFamily: _fontFamily,
        ),
      ),
    );
  }
  
  /// Build page footer
  static Widget _buildPageFooter(int pageNumber) {
    return Container(
      padding: const EdgeInsets.all(_padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'VedantaTrade - VAT Return System',
            style: TextStyle(
              fontSize: _fontSize - 2,
              fontFamily: _fontFamily,
            ),
          ),
          Text(
            'Page $pageNumber',
            style: TextStyle(
              fontSize: _fontSize - 2,
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build section title
  static Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: _fontSize + 2,
        fontWeight: FontWeight.bold,
        fontFamily: _fontFamily,
      ),
    );
  }
  
  /// Build info row
  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: _fontFamily,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: _fontSize,
                fontFamily: _fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build summary table
  static Widget _buildSummaryTable(List<List<String>> data) {
    return Table(
      border: TableBorder.all(color: PdfColors.black),
      columnWidths: {
        0: const FlexColumnWidth(2),
        1: const FlexColumnWidth(1.5),
        2: const FlexColumnWidth(1),
        3: const FlexColumnWidth(1.5),
      },
      children: data.map((row) {
        return TableRow(
          children: row.map((cell) {
            return Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                cell,
                style: TextStyle(
                  fontSize: _fontSize - 1,
                  fontWeight: data.indexOf(row) == 0 ? FontWeight.bold : FontWeight.normal,
                  fontFamily: _fontFamily,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
  
  /// Build sales table
  static Widget _buildSalesTable(List<VatReturnItem> items) {
    return Table(
      border: TableBorder.all(color: PdfColors.black),
      columnWidths: {
        0: const FlexColumnWidth(0.5),
        1: const FlexColumnWidth(2),
        2: const FlexColumnWidth(2),
        3: const FlexColumnWidth(1),
        4: const FlexColumnWidth(1),
        5: const FlexColumnWidth(1),
        6: const FlexColumnWidth(1),
        7: const FlexColumnWidth(1.5),
      },
      children: [
        // Header
        TableRow(
          children: [
            _buildTableCell('S.No', isHeader: true),
            _buildTableCell('Description', isHeader: true),
            _buildTableCell('Customer', isHeader: true),
            _buildTableCell('Invoice', isHeader: true),
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
            _buildTableCell('VAT Rate', isHeader: true),
            _buildTableCell('VAT Amount', isHeader: true),
          ],
        ),
        // Data rows
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return TableRow(
            children: [
              _buildTableCell('${index + 1}'),
              _buildTableCell(item.description),
              _buildTableCell(item.customerName ?? ''),
              _buildTableCell(item.invoiceNumber ?? ''),
              _buildTableCell(item.invoiceDate != null 
                  ? _formatDate(item.invoiceDate!) 
                  : ''),
              _buildTableCell(_formatCurrency(item.amount)),
              _buildTableCell('${item.vatRate.value}%'),
              _buildTableCell(_formatCurrency(item.vatAmount)),
            ],
          );
        }),
      ],
    );
  }
  
  /// Build purchase table
  static Widget _buildPurchaseTable(List<VatReturnItem> items) {
    return Table(
      border: TableBorder.all(color: PdfColors.black),
      columnWidths: {
        0: const FlexColumnWidth(0.5),
        1: const FlexColumnWidth(2),
        2: const FlexColumnWidth(2),
        3: const FlexColumnWidth(1),
        4: const FlexColumnWidth(1),
        5: const FlexColumnWidth(1),
        6: const FlexColumnWidth(1),
        7: const FlexColumnWidth(1.5),
      },
      children: [
        // Header
        TableRow(
          children: [
            _buildTableCell('S.No', isHeader: true),
            _buildTableCell('Description', isHeader: true),
            _buildTableCell('Supplier', isHeader: true),
            _buildTableCell('Invoice', isHeader: true),
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
            _buildTableCell('VAT Rate', isHeader: true),
            _buildTableCell('VAT Amount', isHeader: true),
          ],
        ),
        // Data rows
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return TableRow(
            children: [
              _buildTableCell('${index + 1}'),
              _buildTableCell(item.description),
              _buildTableCell(item.supplierName ?? ''),
              _buildTableCell(item.invoiceNumber ?? ''),
              _buildTableCell(item.invoiceDate != null 
                  ? _formatDate(item.invoiceDate!) 
                  : ''),
              _buildTableCell(_formatCurrency(item.amount)),
              _buildTableCell('${item.vatRate.value}%'),
              _buildTableCell(_formatCurrency(item.vatAmount)),
            ],
          );
        }),
      ],
    );
  }
  
  /// Build tax details table
  static Widget _buildTaxDetailsTable(List<VatTaxDetail> taxDetails) {
    return Table(
      border: TableBorder.all(color: PdfColors.black),
      columnWidths: {
        0: const FlexColumnWidth(1),
        1: const FlexColumnWidth(2),
        2: const FlexColumnWidth(1.5),
        3: const FlexColumnWidth(1.5),
        4: const FlexColumnWidth(1),
      },
      children: [
        // Header
        TableRow(
          children: [
            _buildTableCell('VAT Rate', isHeader: true),
            _buildTableCell('Description', isHeader: true),
            _buildTableCell('Taxable Amount', isHeader: true),
            _buildTableCell('VAT Amount', isHeader: true),
            _buildTableCell('Item Count', isHeader: true),
          ],
        ),
        // Data rows
        ...taxDetails.map((detail) {
          return TableRow(
            children: [
              _buildTableCell('${detail.vatRate.value}%'),
              _buildTableCell(detail.description),
              _buildTableCell(_formatCurrency(detail.taxableAmount)),
              _buildTableCell(_formatCurrency(detail.vatAmount)),
              _buildTableCell('${detail.itemCount}'),
            ],
          );
        }),
      ],
    );
  }
  
  /// Build table cell
  static Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _fontSize - 1,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontFamily: _fontFamily,
        ),
      ),
    );
  }
  
  /// Build compliance checklist
  static Widget _buildComplianceChecklist() {
    final checklistItems = [
      'All sales and purchases are properly recorded',
      'VAT rates applied correctly according to IRDN guidelines',
      'Input tax credit claimed only for eligible purchases',
      'Exempt and zero-rated supplies properly identified',
      'Tax calculations verified and accurate',
      'Required supporting documents attached',
      'Return filed within prescribed time limit',
      'All mandatory fields completed',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: checklistItems.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  border: Border.all(color: PdfColors.black),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: PdfColors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: _fontSize - 1,
                    fontFamily: _fontFamily,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  /// Format date
  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// Format currency
  static String _formatCurrency(double amount) {
    return 'NPR ${amount.toStringAsFixed(2)}';
  }
  
  /// Format return type
  static String _formatReturnType(VatReturnType type) {
    switch (type) {
      case VatReturnType.monthly:
        return 'Monthly';
      case VatReturnType.quarterly:
        return 'Quarterly';
      case VatReturnType.halfYearly:
        return 'Half-Yearly';
      case VatReturnType.yearly:
        return 'Yearly';
      case VatReturnType.adHoc:
        return 'Ad-Hoc';
    }
  }
  
  /// Format status
  static String _formatStatus(VatReturnStatus status) {
    switch (status) {
      case VatReturnStatus.draft:
        return 'Draft';
      case VatReturnStatus.pending:
        return 'Pending';
      case VatReturnStatus.submitted:
        return 'Submitted';
      case VatReturnStatus.processing:
        return 'Processing';
      case VatReturnStatus.approved:
        return 'Approved';
      case VatReturnStatus.rejected:
        return 'Rejected';
      case VatReturnStatus.paid:
        return 'Paid';
      case VatReturnStatus.refunded:
        return 'Refunded';
      case VatReturnStatus.cancelled:
        return 'Cancelled';
      case VatReturnStatus.archived:
        return 'Archived';
    }
  }
  
  /// Save PDF to file
  static Future<String> savePdfToFile(Uint8List pdfData, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfData);
    return file.path;
  }
  
  /// Share PDF
  static Future<void> sharePdf(String filePath) async {
    await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), fileName: filePath);
  }
  
  /// Print PDF
  static Future<void> printPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'VAT Return',
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../models/sales_model.dart';
import '../models/inventory_model.dart';
import '../models/marketing_model.dart';
import '../models/crm_model.dart';

class ReportService {
  static const String _baseUrl = 'https://api.vedantatrade.com';
  static const String _apiKey = 'your-api-key-here';

  // Generate Sales Report
  Future<void> generateSalesReport({
    required String format,
    required List<SalesOrder> orders,
    required Map<String, dynamic> metrics,
    required String period,
    required String region,
  }) async {
    switch (format.toLowerCase()) {
      case 'pdf':
        await _generateSalesPDF(orders, metrics, period, region);
        break;
      case 'excel':
        await _generateSalesExcel(orders, metrics, period, region);
        break;
      case 'csv':
        await _generateSalesCSV(orders, metrics, period, region);
        break;
      default:
        throw ArgumentError('Unsupported format: $format');
    }
  }

  // Generate Inventory Report
  Future<void> generateInventoryReport({
    required String format,
    required List<Inventory> inventory,
    required Map<String, dynamic> metrics,
    required String warehouseId,
  }) async {
    switch (format.toLowerCase()) {
      case 'pdf':
        await _generateInventoryPDF(inventory, metrics, warehouseId);
        break;
      case 'excel':
        await _generateInventoryExcel(inventory, metrics, warehouseId);
        break;
      case 'csv':
        await _generateInventoryCSV(inventory, metrics, warehouseId);
        break;
      default:
        throw ArgumentError('Unsupported format: $format');
    }
  }

  // Generate Marketing Report
  Future<void> generateMarketingReport({
    required String format,
    required List<MarketingCampaign> campaigns,
    required List<MarketingAnalytics> analytics,
    required Map<String, dynamic> metrics,
  }) async {
    switch (format.toLowerCase()) {
      case 'pdf':
        await _generateMarketingPDF(campaigns, analytics, metrics);
        break;
      case 'excel':
        await _generateMarketingExcel(campaigns, analytics, metrics);
        break;
      case 'csv':
        await _generateMarketingCSV(campaigns, analytics, metrics);
        break;
      default:
        throw ArgumentError('Unsupported format: $format');
    }
  }

  // Generate Customer Report
  Future<void> generateCustomerReport({
    required String format,
    required List<Customer> customers,
    required List<Lead> leads,
    required Map<String, dynamic> metrics,
  }) async {
    switch (format.toLowerCase()) {
      case 'pdf':
        await _generateCustomerPDF(customers, leads, metrics);
        break;
      case 'excel':
        await _generateCustomerExcel(customers, leads, metrics);
        break;
      case 'csv':
        await _generateCustomerCSV(customers, leads, metrics);
        break;
      default:
        throw ArgumentError('Unsupported format: $format');
    }
  }

  // Generate Distribution Report
  Future<void> generateDistributionReport({
    required String format,
    required List<DistributionNetwork> networks,
    required List<StockMovement> movements,
    required Map<String, dynamic> metrics,
  }) async {
    switch (format.toLowerCase()) {
      case 'pdf':
        await _generateDistributionPDF(networks, movements, metrics);
        break;
      case 'excel':
        await _generateDistributionExcel(networks, movements, metrics);
        break;
      case 'csv':
        await _generateDistributionCSV(networks, movements, metrics);
        break;
      default:
        throw ArgumentError('Unsupported format: $format');
    }
  }

  // PDF Generation Methods
  Future<void> _generateSalesPDF(
    List<SalesOrder> orders,
    Map<String, dynamic> metrics,
    String period,
    String region,
  ) async {
    final pdf = pw.Document();

    // Add title page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'VedantaTrade - Sales Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Period: $period',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Region: $region',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Generated: ${DateTime.now().toString().split('.')[0]}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 30),
              _buildMetricsTable(metrics),
            ],
          );
        },
      ),
    );

    // Add orders summary
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Orders Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildOrdersTable(orders),
            ],
          );
        },
      ),
    );

    // Save PDF
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> _generateInventoryPDF(
    List<Inventory> inventory,
    Map<String, dynamic> metrics,
    String warehouseId,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'VedantaTrade - Inventory Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Warehouse: $warehouseId',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Generated: ${DateTime.now().toString().split('.')[0]}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 30),
              _buildInventoryMetricsTable(metrics),
            ],
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Inventory Details',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildInventoryTable(inventory),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/inventory_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  // Excel Generation Methods
  Future<void> _generateSalesExcel(
    List<SalesOrder> orders,
    Map<String, dynamic> metrics,
    String period,
    String region,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sales Report'];

    // Add headers
    sheet.cell(CellIndex.indexByString('A1')).value = 'Order Number';
    sheet.cell(CellIndex.indexByString('B1')).value = 'Customer';
    sheet.cell(CellIndex.indexByString('C1')).value = 'Date';
    sheet.cell(CellIndex.indexByString('D1')).value = 'Status';
    sheet.cell(CellIndex.indexByString('E1')).value = 'Total Amount';
    sheet.cell(CellIndex.indexByString('F1')).value = 'Items Count';

    // Add data
    for (int i = 0; i < orders.length; i++) {
      final order = orders[i];
      final rowIndex = i + 2;
      sheet.cell(CellIndex.indexByString('A$rowIndex')).value = order.orderNumber;
      sheet.cell(CellIndex.indexByString('B$rowIndex')).value = order.customerName;
      sheet.cell(CellIndex.indexByString('C$rowIndex')).value = order.orderDate.toString().split('.')[0];
      sheet.cell(CellIndex.indexByString('D$rowIndex')).value = order.status;
      sheet.cell(CellIndex.indexByString('E$rowIndex')).value = order.finalAmount;
      sheet.cell(CellIndex.indexByString('F$rowIndex')).value = order.totalQuantity;
    }

    // Add metrics summary
    final metricsSheet = excel['Metrics'];
    metricsSheet.cell(CellIndex.indexByString('A1')).value = 'Metric';
    metricsSheet.cell(CellIndex.indexByString('B1')).value = 'Value';
    
    int metricRow = 2;
    metrics.forEach((key, value) {
      metricsSheet.cell(CellIndex.indexByString('A$metricRow')).value = key;
      metricsSheet.cell(CellIndex.indexByString('B$metricRow')).value = value;
      metricRow++;
    });

    // Save Excel file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.save());
  }

  Future<void> _generateInventoryExcel(
    List<Inventory> inventory,
    Map<String, dynamic> metrics,
    String warehouseId,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Inventory Report'];

    // Add headers
    sheet.cell(CellIndex.indexByString('A1')).value = 'Product Name';
    sheet.cell(CellIndex.indexByString('B1')).value = 'Category';
    sheet.cell(CellIndex.indexByString('C1')).value = 'Current Stock';
    sheet.cell(CellIndex.indexByString('D1')).value = 'Available Stock';
    sheet.cell(CellIndex.indexByString('E1')).value = 'Unit Cost';
    sheet.cell(CellIndex.indexByString('F1')).value = 'Total Value';
    sheet.cell(CellIndex.indexByString('G1')).value = 'Status';
    sheet.cell(CellIndex.indexByString('H1')).value = 'Expiry Date';

    // Add data
    for (int i = 0; i < inventory.length; i++) {
      final item = inventory[i];
      final rowIndex = i + 2;
      sheet.cell(CellIndex.indexByString('A$rowIndex')).value = item.productName;
      sheet.cell(CellIndex.indexByString('B$rowIndex')).value = item.productCategory;
      sheet.cell(CellIndex.indexByString('C$rowIndex')).value = item.currentStock;
      sheet.cell(CellIndex.indexByString('D$rowIndex')).value = item.availableStock;
      sheet.cell(CellIndex.indexByString('E$rowIndex')).value = item.unitCost;
      sheet.cell(CellIndex.indexByString('F$rowIndex')).value = item.totalValue;
      sheet.cell(CellIndex.indexByString('G$rowIndex')).value = item.status;
      sheet.cell(CellIndex.indexByString('H$rowIndex')).value = item.expiryDate.toString().split('.')[0];
    }

    // Add metrics
    final metricsSheet = excel['Metrics'];
    metricsSheet.cell(CellIndex.indexByString('A1')).value = 'Metric';
    metricsSheet.cell(CellIndex.indexByString('B1')).value = 'Value';
    
    int metricRow = 2;
    metrics.forEach((key, value) {
      metricsSheet.cell(CellIndex.indexByString('A$metricRow')).value = key;
      metricsSheet.cell(CellIndex.indexByString('B$metricRow')).value = value;
      metricRow++;
    });

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/inventory_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.save());
  }

  // CSV Generation Methods
  Future<void> _generateSalesCSV(
    List<SalesOrder> orders,
    Map<String, dynamic> metrics,
    String period,
    String region,
  ) async {
    final csv = StringBuffer();
    
    // Add header
    csv.writeln('Order Number,Customer,Date,Status,Total Amount,Items Count,Payment Status,Distribution Channel');
    
    // Add data
    for (final order in orders) {
      csv.writeln('${order.orderNumber},${order.customerName},${order.orderDate.toString().split('.')[0]},${order.status},${order.finalAmount},${order.totalQuantity},${order.paymentStatus},${order.distributionChannel}');
    }

    // Add metrics summary
    csv.writeln('');
    csv.writeln('Metrics Summary');
    csv.writeln('Metric,Value');
    metrics.forEach((key, value) {
      csv.writeln('$key,$value');
    });

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv.toString());
  }

  Future<void> _generateInventoryCSV(
    List<Inventory> inventory,
    Map<String, dynamic> metrics,
    String warehouseId,
  ) async {
    final csv = StringBuffer();
    
    // Add header
    csv.writeln('Product Name,Category,Current Stock,Available Stock,Unit Cost,Total Value,Status,Expiry Date,Batch Number,Warehouse');
    
    // Add data
    for (final item in inventory) {
      csv.writeln('${item.productName},${item.productCategory},${item.currentStock},${item.availableStock},${item.unitCost},${item.totalValue},${item.status},${item.expiryDate.toString().split('.')[0]},${item.batchNumber},${item.warehouseName}');
    }

    // Add metrics
    csv.writeln('');
    csv.writeln('Metrics Summary');
    csv.writeln('Metric,Value');
    metrics.forEach((key, value) {
      csv.writeln('$key,$value');
    });

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/inventory_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv.toString());
  }

  // PDF Helper Methods
  pw.Widget _buildMetricsTable(Map<String, dynamic> metrics) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(200),
        1: pw.FixedColumnWidth(100),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Metric',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Value',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...metrics.entries.map((entry) {
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(entry.key),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(entry.value.toString()),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildOrdersTable(List<SalesOrder> orders) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(80),
        1: pw.FixedColumnWidth(100),
        2: pw.FixedColumnWidth(80),
        3: pw.FixedColumnWidth(80),
        4: pw.FixedColumnWidth(80),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Order #',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Customer',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Date',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Status',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Amount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...orders.take(20).map((order) {
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(order.orderNumber),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(order.customerName),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(order.orderDate.toString().split('.')[0]),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(order.status),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('NPR ${order.finalAmount.toStringAsFixed(2)}'),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildInventoryMetricsTable(Map<String, dynamic> metrics) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(200),
        1: pw.FixedColumnWidth(100),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Metric',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Value',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...metrics.entries.map((entry) {
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(entry.key),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(entry.value.toString()),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildInventoryTable(List<Inventory> inventory) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(120),
        1: pw.FixedColumnWidth(80),
        2: pw.FixedColumnWidth(60),
        3: pw.FixedColumnWidth(60),
        4: pw.FixedColumnWidth(60),
        5: pw.FixedColumnWidth(60),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Product',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Stock',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Available',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Unit Cost',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Total Value',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Status',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...inventory.take(20).map((item) {
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(item.productName),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(item.currentStock.toString()),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(item.availableStock.toString()),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('NPR ${item.unitCost.toStringAsFixed(2)}'),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('NPR ${item.totalValue.toStringAsFixed(2)}'),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(item.status),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Placeholder methods for other report types
  Future<void> _generateMarketingPDF(
    List<MarketingCampaign> campaigns,
    List<MarketingAnalytics> analytics,
    Map<String, dynamic> metrics,
  ) async {
    // Implementation similar to sales PDF
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('Marketing Report - Coming Soon'),
          );
        },
      ),
    );
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/marketing_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> _generateMarketingExcel(
    List<MarketingCampaign> campaigns,
    List<MarketingAnalytics> analytics,
    Map<String, dynamic> metrics,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Marketing Report'];
    sheet.cell(CellIndex.indexByString('A1')).value = 'Marketing Report - Coming Soon';
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/marketing_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.save());
  }

  Future<void> _generateMarketingCSV(
    List<MarketingCampaign> campaigns,
    List<MarketingAnalytics> analytics,
    Map<String, dynamic> metrics,
  ) async {
    final csv = StringBuffer();
    csv.writeln('Marketing Report - Coming Soon');
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/marketing_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv.toString());
  }

  Future<void> _generateCustomerPDF(
    List<Customer> customers,
    List<Lead> leads,
    Map<String, dynamic> metrics,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('Customer Report - Coming Soon'),
          );
        },
      ),
    );
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/customer_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> _generateCustomerExcel(
    List<Customer> customers,
    List<Lead> leads,
    Map<String, dynamic> metrics,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Customer Report'];
    sheet.cell(CellIndex.indexByString('A1')).value = 'Customer Report - Coming Soon';
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/customer_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.save());
  }

  Future<void> _generateCustomerCSV(
    List<Customer> customers,
    List<Lead> leads,
    Map<String, dynamic> metrics,
  ) async {
    final csv = StringBuffer();
    csv.writeln('Customer Report - Coming Soon');
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/customer_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv.toString());
  }

  Future<void> _generateDistributionPDF(
    List<DistributionNetwork> networks,
    List<StockMovement> movements,
    Map<String, dynamic> metrics,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('Distribution Report - Coming Soon'),
          );
        },
      ),
    );
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/distribution_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> _generateDistributionExcel(
    List<DistributionNetwork> networks,
    List<StockMovement> movements,
    Map<String, dynamic> metrics,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Distribution Report'];
    sheet.cell(CellIndex.indexByString('A1')).value = 'Distribution Report - Coming Soon';
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/distribution_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.save());
  }

  Future<void> _generateDistributionCSV(
    List<DistributionNetwork> networks,
    List<StockMovement> movements,
    Map<String, dynamic> metrics,
  ) async {
    final csv = StringBuffer();
    csv.writeln('Distribution Report - Coming Soon');
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/distribution_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv.toString());
  }
}

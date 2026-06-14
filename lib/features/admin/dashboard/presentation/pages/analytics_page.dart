import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/order_analytics_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/providers/order_analytics_provider.dart';

/// Analytics dashboard page for admin
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderAnalyticsProvider>().fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitik Order'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadPdf(context),
            tooltip: 'Download Laporan PDF',
          ),
        ],
      ),
      body: Consumer<OrderAnalyticsProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildFilterSection(context, provider),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                        ? _buildErrorView(provider.error!)
                        : _buildAnalyticsContent(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, OrderAnalyticsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filter: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<AnalyticsPeriod>(
                  value: provider.selectedPeriod,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  items: AnalyticsPeriod.values.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(period.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      if (value == AnalyticsPeriod.custom) {
                        _showDateRangePicker(context, provider);
                      } else {
                        provider.setPeriod(value);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          if (provider.selectedPeriod == AnalyticsPeriod.custom &&
              provider.startDate != null &&
              provider.endDate != null) ...[
            const SizedBox(height: 8),
            Text(
              '${DateFormat('dd MMM yyyy').format(provider.startDate!)} - ${DateFormat('dd MMM yyyy').format(provider.endDate!)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    OrderAnalyticsProvider provider,
  ) async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );

    if (result != null) {
      provider.setCustomDateRange(result.start, result.end);
    }
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, OrderAnalyticsProvider provider) {
    final analytics = provider.analytics;
    if (analytics == null) {
      return const Center(child: Text('Tidak ada data'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(analytics),
          const SizedBox(height: 24),
          _buildChartSection(provider),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(OrderAnalyticsModel analytics) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Order',
          analytics.totalOrders.toString(),
          Icons.shopping_cart,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Total Revenue',
          currencyFormat.format(analytics.totalRevenue),
          Icons.attach_money,
          Colors.green,
        ),
        _buildSummaryCard(
          'Pending',
          analytics.pendingCount.toString(),
          Icons.pending,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Completed',
          analytics.completedCount.toString(),
          Icons.check_circle,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(OrderAnalyticsProvider provider) {
    final chartData = provider.chartData;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grafik Revenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: chartData.isEmpty
                  ? const Center(child: Text('Tidak ada data untuk ditampilkan'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(chartData),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final data = chartData[groupIndex];
                              return BarTooltipItem(
                                '${data.label}\nRevenue: Rp ${NumberFormat('#,###').format(data.revenue)}\nOrder: ${data.count}',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < chartData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      chartData[index].label,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                              reservedSize: 32,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  'Rp ${_formatYAxis(value)}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _buildBarGroups(chartData),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getMaxY(chartData) / 5,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<ChartData> data) {
    if (data.isEmpty) return 100000;
    final maxRevenue = data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);
    return (maxRevenue * 1.2).toDouble();
  }

  String _formatYAxis(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}rb';
    }
    return value.toStringAsFixed(0);
  }

  List<BarChartGroupData> _buildBarGroups(List<ChartData> data) {
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.revenue.toDouble(),
            color: Colors.deepOrange,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Future<void> _downloadPdf(BuildContext context) async {
    final provider = context.read<OrderAnalyticsProvider>();
    final analytics = provider.analytics;
    final chartData = provider.chartData;

    if (analytics == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk didownload')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final currencyFormat = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
      final dateFormat = DateFormat('dd MMMM yyyy');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Analitik Order',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Periode: ${_getPeriodLabel(provider.selectedPeriod)}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              if (provider.startDate != null && provider.endDate != null)
                pw.Text(
                  '${dateFormat.format(provider.startDate!)} - ${dateFormat.format(provider.endDate!)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              pw.Divider(),
              pw.SizedBox(height: 16),
            ],
          ),
          build: (context) => [
            // Summary Section
            pw.Text(
              'Ringkasan',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('Total Order', isHeader: true),
                    _buildTableCell('Total Revenue', isHeader: true),
                    _buildTableCell('Pending', isHeader: true),
                    _buildTableCell('Completed', isHeader: true),
                    _buildTableCell('Cancelled', isHeader: true),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell(analytics.totalOrders.toString()),
                    _buildTableCell(currencyFormat.format(analytics.totalRevenue)),
                    _buildTableCell(analytics.pendingCount.toString()),
                    _buildTableCell(analytics.completedCount.toString()),
                    _buildTableCell(analytics.cancelledCount.toString()),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Chart Data Section
            pw.Text(
              'Detail Revenue per Hari',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            if (chartData.isNotEmpty)
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Tanggal', isHeader: true),
                      _buildTableCell('Jumlah Order', isHeader: true),
                      _buildTableCell('Revenue', isHeader: true),
                    ],
                  ),
                  ...chartData.map(
                    (data) => pw.TableRow(
                      children: [
                        _buildTableCell(data.label),
                        _buildTableCell(data.count.toString()),
                        _buildTableCell(currencyFormat.format(data.revenue)),
                      ],
                    ),
                  ),
                ],
              )
            else
              pw.Text('Tidak ada data detail'),
          ],
          footer: (context) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 16),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Warmindo Purnama',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Generated: ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'laporan_analitik_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal generate PDF: $e')),
        );
      }
    }
  }

  String _getPeriodLabel(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.day:
        return 'Hari Ini';
      case AnalyticsPeriod.week:
        return 'Minggu Ini';
      case AnalyticsPeriod.month:
        return 'Bulan Ini';
      case AnalyticsPeriod.custom:
        return 'Kustom';
    }
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }
}

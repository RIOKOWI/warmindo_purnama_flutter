import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/order_analytics_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/providers/order_analytics_provider.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/widgets/analytics_skeletonizer.dart';

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
      backgroundColor: AppColors.background,
      appBar: NeoAppBar(
        title: 'ANALITIK ORDER',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _downloadPdf(context),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.dark, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppColors.dark, offset: Offset(3, 3), blurRadius: 0),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download_rounded, size: 18, color: AppColors.text),
                    const SizedBox(width: 4),
                    Text('PDF', style: AppTextStyles.caption.copyWith(color: AppColors.text)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<OrderAnalyticsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const AnalyticsSkeletonizer();
          }
          if (provider.error != null) {
            return _buildErrorView(provider.error!, provider);
          }
          return Column(
            children: [
              _buildFilterSection(context, provider),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: () => provider.fetchAnalytics(),
                  child: _buildAnalyticsContent(context, provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Filter Section ────────────────────────────────────────────────────────

  Widget _buildFilterSection(BuildContext context, OrderAnalyticsProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.dark, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('PERIODE', style: AppTextStyles.caption),
              const SizedBox(width: 12),
              Expanded(
                child: _NeoDropdown<AnalyticsPeriod>(
                  value: provider.selectedPeriod,
                  items: AnalyticsPeriod.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.label, style: AppTextStyles.bodySmall)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    if (value == AnalyticsPeriod.custom) {
                      _showDateRangePicker(context, provider);
                    } else {
                      provider.setPeriod(value);
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
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Text(
                  '${DateFormat('dd MMM yyyy').format(provider.startDate!)} — ${DateFormat('dd MMM yyyy').format(provider.endDate!)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Date Picker ───────────────────────────────────────────────────────────

  Future<void> _showDateRangePicker(BuildContext context, OrderAnalyticsProvider provider) async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );

    if (result != null) {
      provider.setCustomDateRange(result.start, result.end);
    }
  }

  // ─── Error View ────────────────────────────────────────────────────────────

  Widget _buildErrorView(String error, OrderAnalyticsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.error, width: 3),
            ),
            child: const Icon(Icons.bar_chart_outlined, size: 48, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          Text('Gagal memuat data', style: AppTextStyles.headline),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: AppTextStyles.body),
          const SizedBox(height: 24),
          NeoButtonSmall(
            label: 'Coba Lagi',
            icon: Icons.refresh,
            onPressed: () => provider.fetchAnalytics(),
          ),
        ],
      ),
    );
  }

  // ─── Main Content ──────────────────────────────────────────────────────────

  Widget _buildAnalyticsContent(BuildContext context, OrderAnalyticsProvider provider) {
    final analytics = provider.analytics;
    if (analytics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dark, width: 3),
              ),
              child: const Icon(Icons.analytics_outlined, size: 48, color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            Text('Tidak ada data', style: AppTextStyles.headline),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RINGKASAN', style: AppTextStyles.caption),
          const SizedBox(height: 12),
          _buildSummaryCards(analytics),
          const SizedBox(height: 24),
          Text('GRAFIK REVENUE', style: AppTextStyles.caption),
          const SizedBox(height: 12),
          _buildChartSection(provider),
          const SizedBox(height: 24),
          Text('DETAIL DATA', style: AppTextStyles.caption),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.cancel_outlined,
            label: 'Cancelled',
            value: analytics.cancelledCount.toString(),
            color: AppColors.error,
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            icon: Icons.pending_actions,
            label: 'Pending',
            value: analytics.pendingCount.toString(),
            color: AppColors.warning,
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            icon: Icons.check_circle_outline,
            label: 'Completed',
            value: analytics.completedCount.toString(),
            color: AppColors.success,
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            icon: Icons.attach_money_rounded,
            label: 'Total Revenue',
            value: NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(analytics.totalRevenue),
            color: AppColors.info,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Summary Cards ─────────────────────────────────────────────────────────

  Widget _buildSummaryCards(OrderAnalyticsModel analytics) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;
        final aspectRatio = isSmall ? 1.2 : 1.5;

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: aspectRatio,
          children: [
            _buildSummaryCard(
              'Total Order',
              analytics.totalOrders.toString(),
              Icons.shopping_bag_outlined,
              AppColors.info,
              isSmall: isSmall,
            ),
            _buildSummaryCard(
              'Total Revenue',
              currencyFormat.format(analytics.totalRevenue),
              Icons.payments_outlined,
              AppColors.success,
              isSmall: isSmall,
            ),
            _buildSummaryCard(
              'Pending',
              analytics.pendingCount.toString(),
              Icons.pending_actions,
              AppColors.warning,
              isSmall: isSmall,
            ),
            _buildSummaryCard(
              'Completed',
              analytics.completedCount.toString(),
              Icons.check_circle_outline,
              AppColors.accent,
              isSmall: isSmall,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isSmall = false,
  }) {
    final double iconSize = isSmall ? 20 : 26;
    final double valueFontSize = isSmall ? 13 : 16;
    final double titleFontSize = isSmall ? 10 : 11;
    final double spacing = isSmall ? 4 : 6;
    final EdgeInsets cardPadding = isSmall ? const EdgeInsets.all(8) : const EdgeInsets.all(12);

    return NeoCardCustom(
      backgroundColor: color.withValues(alpha: 0.08),
      padding: cardPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          SizedBox(height: spacing),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: valueFontSize,
              color: AppColors.card,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontSize: titleFontSize,
              color: AppColors.card
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Stat Row ──────────────────────────────────────────────────────────────

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return NeoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTextStyles.body),
          ),
          Text(
            value,
            style: AppTextStyles.title.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  // ─── Chart Section ─────────────────────────────────────────────────────────

  Widget _buildChartSection(OrderAnalyticsProvider provider) {
    final chartData = provider.chartData;

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: const Icon(Icons.bar_chart_rounded, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Revenue Chart', style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: chartData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bar_chart_outlined, size: 48, color: AppColors.textLight),
                        const SizedBox(height: 8),
                        Text('Tidak ada data untuk ditampilkan', style: AppTextStyles.caption),
                      ],
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(chartData),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.dark,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final data = chartData[groupIndex];
                            return BarTooltipItem(
                              '${data.label}\nRp ${NumberFormat('#,###').format(data.revenue)}\n${data.count} order',
                              AppTextStyles.caption.copyWith(color: Colors.white),
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
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    chartData[index].label,
                                    style: AppTextStyles.caption.copyWith(fontSize: 9),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 56,
                            getTitlesWidget: (value, meta) => Text(
                              'Rp ${_formatYAxis(value)}',
                              style: AppTextStyles.caption.copyWith(fontSize: 9),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(chartData),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getMaxY(chartData) / 4,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.dark,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(List<ChartData> data) {
    if (data.isEmpty) return 100000;
    final maxRevenue = data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);
    return (maxRevenue * 1.2).toDouble();
  }

  String _formatYAxis(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}jt';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}rb';
    return value.toStringAsFixed(0);
  }

  List<BarChartGroupData> _buildBarGroups(List<ChartData> data) {
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.revenue.toDouble(),
            gradient: const LinearGradient(
              colors: [AppColors.accentPressed, AppColors.accent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 18,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            borderSide: const BorderSide(color: AppColors.dark, width: 2),
          ),
        ],
      );
    }).toList();
  }

  // ─── PDF Export ────────────────────────────────────────────────────────────

  Future<void> _downloadPdf(BuildContext context) async {
    final provider = context.read<OrderAnalyticsProvider>();
    final analytics = provider.analytics;
    final chartData = provider.chartData;

    if (analytics == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data untuk didownload'),
          backgroundColor: AppColors.warning,
        ),
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
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
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
            pw.Text('Ringkasan',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
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
            pw.Text('Detail Revenue per Periode',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
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
                pw.Text('Warmindo Purnama', style: const pw.TextStyle(fontSize: 10)),
                pw.Text(
                  'Generated: ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      );

      final pdfBytes = await pdf.save();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (kIsWeb) {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'laporan_analitik_$timestamp.pdf',
        );
      } else {
        final directory = await _getDownloadDirectory();
        final file = File('${directory.path}/laporan_analitik_$timestamp.pdf');
        await file.writeAsBytes(pdfBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF berhasil disimpan ke: ${file.path}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal generate PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${docsDir.path}/PDFs');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir;
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

// ─── Neo Dropdown ─────────────────────────────────────────────────────────────

class _NeoDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _NeoDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dark, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.dark, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isDense: true,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.text),
          style: AppTextStyles.bodySmall,
          dropdownColor: AppColors.card,
        ),
      ),
    );
  }
}

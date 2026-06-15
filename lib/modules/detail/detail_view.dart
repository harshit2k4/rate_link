import 'dart:io';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/format_utils.dart';
import 'detail_controller.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  static final _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    color: context.primaryAccent,
                  ),
                )
              : CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildTopCard(context)),
                    SliverToBoxAdapter(child: _buildHistoryHeader(context)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            _buildHistoryRow(ctx, controller.history[i]),
                        childCount: controller.history.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTopCard(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final isCompact = screenH < 680;
    final chartH = (screenH * 0.20).clamp(80.0, 160.0);
    final gapAfterBack = isCompact ? 12.0 : 20.0;
    final gapBeforeTabs = isCompact ? 10.0 : 18.0;
    final gapBeforeChart = isCompact ? 8.0 : 14.0;
    final cardPad = isCompact ? 16.0 : 24.0;
    final topMargin = isCompact ? 12.0 : 20.0;
    final rateFS = isCompact ? 28.0 : 38.0;

    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        margin: EdgeInsets.fromLTRB(24, topMargin, 24, 0),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.all(cardPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ← back   🗓 calendar   share →
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                Row(
                  children: [
                    // Calendar icon — opens date picker
                    GestureDetector(
                      onTap: () => _pickDate(context),
                      child: Obx(
                        () => Icon(
                          Icons.calendar_month_rounded,
                          color: controller.isHistoricalMode
                              ? Colors.amber
                              : Colors.white38,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showShareSheet(context),
                      child: const Icon(
                        Icons.ios_share_rounded,
                        color: Colors.white38,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Historical mode banner
            Obx(() {
              if (!controller.isHistoricalMode) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: EdgeInsets.only(top: gapAfterBack * 0.6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: Colors.amber,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Historical: ${formatDisplayDate(controller.currentDate.value)}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: controller.clearHistoricalMode,
                      child: const Icon(
                        Icons.close,
                        color: Colors.amber,
                        size: 13,
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: gapAfterBack),

            // Pair label
            Row(
              children: [
                Text(
                  '1 ${controller.baseCurrency.value}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white30,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  controller.targetCurrency.value,
                  style: const TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Text(
              formatRate(controller.rate.value),
              style: TextStyle(
                color: Colors.white,
                fontSize: rateFS,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.5,
              ),
            ),

            if (!isZeroChange(controller.rateChange.value))
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  formatChange(controller.rateChange.value),
                  style: TextStyle(
                    color: controller.rateChange.value > 0
                        ? AppColors.green
                        : AppColors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            SizedBox(height: gapBeforeTabs),
            _buildPeriodTabs(),
            SizedBox(height: gapBeforeChart),

            if (controller.chartSpots.length > 1)
              SizedBox(height: chartH, child: _buildDetailChart()),

            const SizedBox(height: 12),
            Text(
              formatDisplayDate(controller.currentDate.value),
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Shows a material date picker; max date is today
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          controller.historicalDate.value ??
          now.subtract(const Duration(days: 30)),
      firstDate: DateTime(1999),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: context.primaryAccent),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    if (picked.year == now.year &&
        picked.month == now.month &&
        picked.day == now.day) {
      // Today selected — clear historical mode
      controller.clearHistoricalMode();
    } else {
      controller.pickHistoricalDate(picked);
    }
  }

  Widget _buildPeriodTabs() {
    return Row(
      children: List.generate(controller.periods.length, (i) {
        final selected = controller.selectedPeriod.value == i;
        return GestureDetector(
          onTap: () => controller.selectPeriod(i),
          child: Padding(
            padding: const EdgeInsets.only(right: 22),
            child: Text(
              controller.periods[i],
              style: TextStyle(
                color: selected ? Colors.white : Colors.white38,
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailChart() {
    final spots = controller.chartSpots;
    final values = spots.map((s) => s.y).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final pad = range == 0 ? 1.0 : range * 0.15;
    final interval = range == 0 ? 1.0 : range / 3;

    return LineChart(
      LineChartData(
        minY: minVal - pad,
        maxY: maxVal + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Colors.white12, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              interval: interval,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  _axisLabel(value),
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.chartLine,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.chartLine.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }

  String _axisLabel(double v) {
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(v.abs() < 10 ? 3 : 2);
  }

  Widget _buildHistoryHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
      child: Row(
        children: [
          Text(
            'History',
            style: TextStyle(
              color: context.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (controller.isHistoricalMode) ...[
            const SizedBox(width: 8),
            Text(
              '· around this date',
              style: TextStyle(color: context.secondaryText, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryRow(BuildContext context, HistoryEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              formatShortDate(entry.isoDate),
              style: TextStyle(
                color: context.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              formatChange(entry.change),
              style: TextStyle(
                color: isZeroChange(entry.change)
                    ? context.secondaryText
                    : entry.change > 0
                    ? AppColors.green
                    : AppColors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            formatRate(entry.rate),
            style: TextStyle(
              color: context.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: sheetCtx.secondaryText.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Share Rate',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: sheetCtx.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            leading: Icon(
              Icons.text_fields_rounded,
              color: sheetCtx.primaryAccent,
            ),
            title: Text(
              'Share as Text',
              style: TextStyle(color: sheetCtx.primaryText),
            ),
            onTap: () {
              Navigator.pop(sheetCtx);
              _shareAsText();
            },
          ),
          ListTile(
            leading: Icon(Icons.image_rounded, color: sheetCtx.primaryAccent),
            title: Text(
              'Share as Image',
              style: TextStyle(color: sheetCtx.primaryText),
            ),
            onTap: () {
              Navigator.pop(sheetCtx);
              _shareAsImage();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _shareAsText() async {
    final base = controller.baseCurrency.value;
    final target = controller.targetCurrency.value;
    final rateStr = formatRate(controller.rate.value);
    final change = controller.rateChange.value;
    final changePart = isZeroChange(change)
        ? ''
        : '\nChange: ${formatChange(change)}';
    final historicalNote = controller.isHistoricalMode
        ? '\nRate on ${formatDisplayDate(controller.currentDate.value)}'
        : '';
    await Share.share(
      '1 $base = $rateStr $target$changePart$historicalNote\n\nShared via RateFlip',
    );
  }

  Future<void> _shareAsImage() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return _shareAsText();
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return _shareAsText();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/rateflip_${controller.baseCurrency.value}_${controller.targetCurrency.value}.png',
      );
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '1 ${controller.baseCurrency.value} = ${formatRate(controller.rate.value)} ${controller.targetCurrency.value} · RateFlip',
      );
    } catch (_) {
      await _shareAsText();
    }
  }
}

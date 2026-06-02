import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_pages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/format_utils.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: context.primaryAccent),
            );
          }
          if (controller.hasError.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load rates.',
                    style: TextStyle(color: context.secondaryText),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryAccent,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(context)),
              SliverToBoxAdapter(child: _buildHeroCard(context)),
              SliverToBoxAdapter(
                child: _buildSectionHeader(context, 'Other Currencies'),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) =>
                      _buildCurrencyRow(context, controller.otherCurrencies[i]),
                  childCount: controller.otherCurrencies.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Ex',
                  style: TextStyle(
                    color: context.primaryAccent,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'change',
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.settings),
            child: Icon(
              Icons.menu_rounded,
              color: context.surfaceIconColor,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final change = controller.targetChange.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: GestureDetector(
        onTap: () => Get.toNamed(
          Routes.detail,
          arguments: {
            'base': controller.baseCurrency.value,
            'target': controller.targetCurrency.value,
          },
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pair row — makes it obvious to a new user what is being shown
              Row(
                children: [
                  Text(
                    '1 ${controller.baseCurrency.value}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
                formatRate(controller.targetRate.value),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.5,
                ),
              ),
              // Full name of target currency so new users understand the unit
              Text(
                controller.targetCurrencyName,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 6),
              // Only render change row when it is actually non-zero
              if (!isZeroChange(change))
                Text(
                  formatChange(change),
                  style: TextStyle(
                    color: change > 0 ? AppColors.green : AppColors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 16),
              if (controller.chartSpots.length > 1)
                SizedBox(height: 80, child: _buildHomeChart()),
              const SizedBox(height: 12),
              Text(
                formatDisplayDate(controller.currentDate.value),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeChart() {
    final spots = controller.chartSpots;
    final values = spots.map((s) => s.y).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final pad = range == 0 ? 10.0 : range * 0.15;
    return LineChart(
      LineChartData(
        minY: minVal - pad,
        maxY: maxVal + pad,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
      child: Text(
        title,
        style: TextStyle(
          color: context.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCurrencyRow(BuildContext context, OtherCurrencyItem item) {
    final change = item.change;
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.detail,
        arguments: {'base': controller.baseCurrency.value, 'target': item.code},
      ),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            _buildCurrencyIcon(context, item.code),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.code,
                    style: TextStyle(
                      color: context.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    item.name,
                    style: TextStyle(
                      color: context.secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatRate(item.rate),
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isZeroChange(change))
                  Text(
                    formatChange(change),
                    style: TextStyle(
                      color: change > 0 ? AppColors.green : AppColors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyIcon(BuildContext context, String code) {
    final label = code.length >= 2 ? code.substring(0, 2) : code;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: context.purpleLightAdaptive,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: context.primaryAccent,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

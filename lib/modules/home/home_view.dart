import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/currencies.dart';
import '../../core/routes/app_pages.dart';
import '../../core/theme/app_theme.dart';
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
            return const Center(
              child: CircularProgressIndicator(color: AppColors.purple),
            );
          }
          if (controller.hasError.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Failed to load rates.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
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
              SliverToBoxAdapter(child: _buildAppBar()),
              SliverToBoxAdapter(child: _buildHeroCard()),
              SliverToBoxAdapter(
                child: _buildSectionHeader('Other Currencies'),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildCurrencyRow(controller.otherCurrencies[i]),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Ex',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'change',
                  style: TextStyle(
                    color: AppColors.textDark,
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
            child: const Icon(
              Icons.menu_rounded,
              color: AppColors.textDark,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
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
              Text(
                '1 ${controller.baseCurrency.value}',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                formatRate(controller.targetRate.value),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatChange(controller.targetChange.value),
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              if (controller.chartSpots.length > 1)
                SizedBox(height: 80, child: _buildHomeChart()),
              const SizedBox(height: 14),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCurrencyRow(OtherCurrencyItem item) {
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
            _buildCurrencyIcon(item.code),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.code,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: AppColors.textMuted,
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
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatChange(item.change),
                  style: TextStyle(
                    color: item.change >= 0 ? AppColors.green : AppColors.red,
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

  Widget _buildCurrencyIcon(String code) {
    final symbol = kCurrencySymbols[code] ?? code[0];
    final display = symbol.length > 2 ? symbol[0] : symbol;
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.purpleLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        display,
        style: const TextStyle(
          color: AppColors.purple,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

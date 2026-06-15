import 'dart:io';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/routes/app_pages.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/format_utils.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static final _heroKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.otherCurrencies.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: context.primaryAccent),
            );
          }
          if (controller.hasError.value && controller.otherCurrencies.isEmpty) {
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

          final searching = controller.searchQuery.value.isNotEmpty;
          final pinned = controller.pinnedCurrencies;
          final unpinned = controller.unpinnedCurrencies;

          return Column(
            children: [
              _buildOfflineBanner(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.loadData,
                  color: context.primaryAccent,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildAppBar(context)),
                      SliverToBoxAdapter(child: _buildHeroCard(context)),
                      SliverToBoxAdapter(child: _buildSearchBar(context)),

                      // Pinned section — hidden while searching
                      if (!searching && pinned.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _buildSectionHeader(context, 'Pinned'),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _buildCurrencyRow(context, pinned[i]),
                            childCount: pinned.length,
                          ),
                        ),
                      ],

                      SliverToBoxAdapter(
                        child: _buildSectionHeader(
                          context,
                          searching ? 'Results' : 'Other Currencies',
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _buildCurrencyRow(context, unpinned[i]),
                          childCount: unpinned.length,
                        ),
                      ),

                      if (unpinned.isEmpty && searching)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No currencies match\n"${controller.searchQuery.value}"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.secondaryText,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Obx(() {
      final offline = !Get.find<ConnectivityService>().isOnline.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: offline ? 30 : 0,
        color: const Color(0xFF374151),
        child: offline
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Offline · Rates may be outdated',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              )
            : null,
      );
    });
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
          Row(
            children: [
              // Converter shortcut
              GestureDetector(
                onTap: () => Get.toNamed(Routes.converter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.currency_exchange_rounded,
                        color: context.primaryAccent,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Convert',
                        style: TextStyle(
                          color: context.primaryAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Alerts bell
              GestureDetector(
                onTap: () => Get.toNamed(Routes.alerts),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: context.surfaceIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
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
        child: RepaintBoundary(
          key: _heroKey,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
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
                Text(
                  controller.targetCurrencyName,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 6),
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
                _buildStalenessRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStalenessRow() {
    return Obx(() {
      controller.stalenessTick.value;
      final stale = controller.isStale;
      final text = controller.stalenessText;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formatDisplayDate(controller.currentDate.value),
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          if (text.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (stale)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 12,
                    ),
                  ),
                Text(
                  text,
                  style: TextStyle(
                    color: stale ? Colors.amber : Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
        ],
      );
    });
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

  // Search bar between hero card and currency list
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: TextField(
        onChanged: (v) => controller.searchQuery.value = v,
        style: TextStyle(color: context.primaryText, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search currencies...',
          hintStyle: TextStyle(color: context.secondaryText, fontSize: 14),
          prefixIcon: Icon(
            Icons.search,
            color: context.secondaryText,
            size: 20,
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () => controller.searchQuery.value = '',
                    child: Icon(
                      Icons.close,
                      color: context.secondaryText,
                      size: 18,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          filled: true,
          fillColor: context.cardBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
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
      // Long-press to toggle favorite
      onLongPress: () {
        controller.toggleFavorite(item.code);
        final pinned = controller.favorites.contains(item.code);
        Get.snackbar(
          '',
          '',
          messageText: Text(
            pinned ? '${item.code} pinned to top' : '${item.code} unpinned',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: const Color(0xFF1E2140),
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          isDismissible: true,
          overlayBlur: 0,
        );
      },
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Filled star only on favorited rows — keeps rows clean
                    Obx(
                      () => controller.favorites.contains(item.code)
                          ? const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 14,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Text(
                      formatRate(item.rate),
                      style: TextStyle(
                        color: context.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
            subtitle: Text(
              'Plain-text format',
              style: TextStyle(color: sheetCtx.secondaryText, fontSize: 12),
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
            subtitle: Text(
              'Capture the rate card',
              style: TextStyle(color: sheetCtx.secondaryText, fontSize: 12),
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
    final rate = formatRate(controller.targetRate.value);
    final name = controller.targetCurrencyName;
    final change = controller.targetChange.value;
    final changePart = isZeroChange(change)
        ? ''
        : '\nChange today: ${formatChange(change)}';
    await Share.share(
      '1 $base = $rate $target ($name)$changePart\n\nShared via RateFlip',
    );
  }

  Future<void> _shareAsImage() async {
    try {
      final boundary =
          _heroKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return _shareAsText();
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return _shareAsText();
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/rateflip_${controller.baseCurrency.value}_${controller.targetCurrency.value}.png',
      );
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '1 ${controller.baseCurrency.value} = ${formatRate(controller.targetRate.value)} ${controller.targetCurrency.value} · RateFlip',
      );
    } catch (_) {
      await _shareAsText();
    }
  }
}

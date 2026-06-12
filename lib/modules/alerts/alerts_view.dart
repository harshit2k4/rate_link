import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/rate_alert.dart';
import 'alerts_controller.dart';

class AlertsView extends GetView<AlertsController> {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.primaryAccent,
                    ),
                  );
                }
                if (controller.alerts.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  itemCount: controller.alerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _buildAlertCard(context, controller.alerts[i]),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAlertSheet(context),
        backgroundColor: context.primaryAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Alert',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back,
              color: context.surfaceIconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Rate Alerts',
            style: TextStyle(
              color: context.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.purpleLightAdaptive,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: context.primaryAccent,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No alerts yet',
              style: TextStyle(
                color: context.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "New Alert" to get notified\nwhen a rate crosses your target.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.secondaryText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, RateAlert alert) {
    final isTriggered = alert.hasTriggered;
    final isAbove = alert.direction == AlertDirection.above;
    final dirColor = isAbove ? AppColors.green : AppColors.red;
    final dirIcon = isAbove
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final dirLabel = isAbove ? 'rises above' : 'drops below';

    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.red,
          size: 22,
        ),
      ),
      onDismissed: (_) => controller.deleteAlert(alert.id),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: isTriggered
              ? Border.all(color: AppColors.green.withOpacity(0.25), width: 1)
              : null,
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            // Direction icon bubble
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: dirColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(dirIcon, color: dirColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${alert.baseCurrency} → ${alert.targetCurrency}',
                        style: TextStyle(
                          color: context.primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isTriggered) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Triggered',
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Alert when $dirLabel ${formatRate(alert.threshold)}',
                    style: TextStyle(
                      color: context.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: alert.isEnabled,
              onChanged: (v) => controller.toggleAlert(alert.id, v),
              activeColor: context.primaryAccent,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }

  // ── Add Alert bottom sheet ──────────────────────────────────────

  void _showAddAlertSheet(BuildContext context) {
    controller.addThreshold.value = '';
    final thresholdCtrl = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (sheetCtx, _) => Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.82),
          decoration: BoxDecoration(
            color: sheetCtx.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sheetCtx.secondaryText.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'New Alert',
                  style: TextStyle(
                    color: sheetCtx.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 22),

                // Currency pair
                Text(
                  'Currency pair',
                  style: TextStyle(color: sheetCtx.secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _pairChip(
                          sheetCtx,
                          controller.addBase.value,
                          () => _pickCurrency(
                            title: 'Base Currency',
                            current: controller.addBase.value,
                            onSelect: controller.setAddBase,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_forward,
                        color: sheetCtx.secondaryText,
                        size: 16,
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () => _pairChip(
                          sheetCtx,
                          controller.addTarget.value,
                          () => _pickCurrency(
                            title: 'Target Currency',
                            current: controller.addTarget.value,
                            onSelect: controller.setAddTarget,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Direction
                Text(
                  'Alert direction',
                  style: TextStyle(color: sheetCtx.secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _dirBtn(
                          sheetCtx,
                          label: 'Rises above',
                          icon: Icons.trending_up_rounded,
                          color: AppColors.green,
                          selected:
                              controller.addDirection.value ==
                              AlertDirection.above,
                          onTap: () =>
                              controller.setAddDirection(AlertDirection.above),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dirBtn(
                          sheetCtx,
                          label: 'Drops below',
                          icon: Icons.trending_down_rounded,
                          color: AppColors.red,
                          selected:
                              controller.addDirection.value ==
                              AlertDirection.below,
                          onTap: () =>
                              controller.setAddDirection(AlertDirection.below),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Threshold
                Text(
                  'Threshold',
                  style: TextStyle(color: sheetCtx.secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: thresholdCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) => controller.addThreshold.value = v,
                  style: TextStyle(
                    color: sheetCtx.primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: sheetCtx.secondaryText,
                      fontSize: 24,
                    ),
                    filled: true,
                    fillColor: sheetCtx.searchFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: Obx(
                      () => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          controller.addTarget.value,
                          style: TextStyle(
                            color: sheetCtx.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Current rate hint
                Obx(() {
                  if (controller.isLoadingPreview.value) {
                    return const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    );
                  }
                  final r = controller.previewRate.value;
                  if (r <= 0) return const SizedBox.shrink();
                  return Text(
                    'Current rate: ${formatRate(r)} ${controller.addTarget.value}',
                    style: TextStyle(
                      color: sheetCtx.secondaryText,
                      fontSize: 13,
                    ),
                  );
                }),
                const SizedBox(height: 28),

                // Set Alert button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    final valid =
                        double.tryParse(controller.addThreshold.value) != null;
                    return ElevatedButton(
                      onPressed: valid
                          ? () async {
                              final ok = await controller.saveAlert();
                              if (ok) {
                                thresholdCtrl.clear();
                                Get.back();
                                Get.snackbar(
                                  '',
                                  '',
                                  messageText: const Text(
                                    'Alert created — you\'ll be notified when the rate crosses your target.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFF1E2140),
                                  duration: const Duration(seconds: 3),
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sheetCtx.primaryAccent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: sheetCtx.primaryAccent
                            .withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Set Alert',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _pairChip(BuildContext ctx, String code, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ctx.searchFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              code,
              style: TextStyle(
                color: ctx.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: ctx.secondaryText, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _dirBtn(
    BuildContext ctx, {
    required String label,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : ctx.searchFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color.withOpacity(0.35) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : ctx.secondaryText, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : ctx.secondaryText,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickCurrency({
    required String title,
    required String current,
    required void Function(String) onSelect,
  }) {
    final codes = controller.currencyCodes;
    final names = controller.currencyNames;
    var query = '';
    Get.bottomSheet(
      StatefulBuilder(
        builder: (sheetCtx, setState) {
          final filtered = query.isEmpty
              ? codes
              : codes
                    .where(
                      (c) =>
                          c.toLowerCase().contains(query.toLowerCase()) ||
                          (names[c] ?? '').toLowerCase().contains(
                            query.toLowerCase(),
                          ),
                    )
                    .toList();
          return Container(
            constraints: BoxConstraints(maxHeight: Get.height * 0.65),
            decoration: BoxDecoration(
              color: sheetCtx.cardBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetCtx.secondaryText.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: sheetCtx.primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (v) => setState(() => query = v),
                    style: TextStyle(color: sheetCtx.primaryText, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        color: sheetCtx.secondaryText,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: sheetCtx.secondaryText,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: sheetCtx.searchFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                Divider(height: 16, color: sheetCtx.dividerColor),
                Flexible(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final code = filtered[i];
                      final sel = code == current;
                      return ListTile(
                        dense: true,
                        title: Text(
                          code,
                          style: TextStyle(
                            color: sel
                                ? sheetCtx.primaryAccent
                                : sheetCtx.primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: names[code] != null
                            ? Text(
                                names[code]!,
                                style: TextStyle(
                                  color: sheetCtx.secondaryText,
                                  fontSize: 13,
                                ),
                              )
                            : null,
                        trailing: sel
                            ? Icon(
                                Icons.check,
                                color: sheetCtx.primaryAccent,
                                size: 18,
                              )
                            : null,
                        onTap: () {
                          onSelect(code);
                          Get.back();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}

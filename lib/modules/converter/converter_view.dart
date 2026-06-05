import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/format_utils.dart';
import 'converter_controller.dart';

class ConverterView extends GetView<ConverterController> {
  const ConverterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.currencyNames.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: context.primaryAccent,
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        _buildConverterCard(context),
                        const SizedBox(height: 16),
                        _buildRateInfoCard(context),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
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
            'Converter',
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

  Widget _buildConverterCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FROM row
          const Text(
            'You have',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller.amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 36),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => _buildCurrencyChip(
                  code: controller.fromCurrency.value,
                  onTap: () => _showCurrencyPicker(
                    title: 'From Currency',
                    current: controller.fromCurrency.value,
                    onSelect: controller.setFrom,
                  ),
                ),
              ),
            ],
          ),

          // Swap button
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: GestureDetector(
                onTap: controller.swap,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: context.primaryAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.primaryAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.swap_vert_rounded,
                    color: context.primaryAccent,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // TO row
          const Text(
            'You get',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Obx(
                  () => controller.isLoading.value
                      ? const Text(
                          '...',
                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          formatRate(controller.result.value),
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => _buildCurrencyChip(
                  code: controller.toCurrency.value,
                  onTap: () => _showCurrencyPicker(
                    title: 'To Currency',
                    current: controller.toCurrency.value,
                    onSelect: controller.setTo,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyChip({
    required String code,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateInfoCard(BuildContext context) {
    return Obx(() {
      final rate = controller.displayRate.value;
      final date = controller.currentDate.value;
      if (rate.isEmpty) return const SizedBox.shrink();
      return Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: context.secondaryText,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rate,
                    style: TextStyle(
                      color: context.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (date.isNotEmpty)
                    Text(
                      'As of ${formatDisplayDate(date)}',
                      style: TextStyle(
                        color: context.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showCurrencyPicker({
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
              : codes.where((c) {
                  final q = query.toLowerCase();
                  return c.toLowerCase().contains(q) ||
                      (names[c] ?? '').toLowerCase().contains(q);
                }).toList();
          return Container(
            constraints: BoxConstraints(maxHeight: Get.height * 0.75),
            decoration: BoxDecoration(
              color: sheetCtx.cardBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
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
                      hintText: 'Search currency...',
                      hintStyle: TextStyle(
                        color: sheetCtx.secondaryText,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: sheetCtx.secondaryText,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: sheetCtx.searchFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Divider(height: 16, color: sheetCtx.dividerColor),
                Flexible(
                  child: filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No currencies found.',
                            style: TextStyle(color: sheetCtx.secondaryText),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final code = filtered[i];
                            final name = names[code] ?? '';
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
                              subtitle: name.isNotEmpty
                                  ? Text(
                                      name,
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

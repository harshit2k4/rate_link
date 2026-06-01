import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/format_utils.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  _buildCurrencyCard(context),
                  const SizedBox(height: 16),
                  _buildThemeCard(context),
                ],
              ),
            ),
            _buildFooter(context),
          ],
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
            'Settings',
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

  Widget _buildCurrencyCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Currency',
            style: TextStyle(
              color: context.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => _buildDropdownRow(
              context: context,
              label: 'Base',
              value: controller.baseCurrency.value,
              loading: controller.isLoadingCurrencies.value,
              onTap: () => _showCurrencyPicker(
                title: 'Base Currency',
                current: controller.baseCurrency.value,
                onSelect: controller.setBase,
              ),
            ),
          ),
          _buildDivider(context),
          Obx(
            () => _buildDropdownRow(
              context: context,
              label: 'Target',
              value: controller.targetCurrency.value,
              loading: controller.isLoadingCurrencies.value,
              onTap: () => _showCurrencyPicker(
                title: 'Target Currency',
                current: controller.targetCurrency.value,
                onSelect: controller.setTarget,
              ),
            ),
          ),
          _buildDivider(context),
          Obx(
            () => _buildDropdownRow(
              context: context,
              label: 'List',
              value: controller.listFilter.value,
              onTap: () => _showSimplePicker(
                title: 'List Filter',
                current: controller.listFilter.value,
                options: const ['All', 'Major', 'Asia', 'Europe'],
                onSelect: controller.setListFilter,
              ),
            ),
          ),
          _buildDivider(context),
          Obx(
            () => _buildDropdownRow(
              context: context,
              label: 'Digit Separator',
              value: controller.digitSeparator.value,
              onTap: () => _showSimplePicker(
                title: 'Digit Separator',
                current: controller.digitSeparator.value,
                options: FormatPrefs.options,
                onSelect: controller.setDigitSeparator,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: context.secondaryText, fontSize: 15),
            ),
            loading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: context.secondaryText,
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          color: context.primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: context.secondaryText,
                        size: 18,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // Full-list currency picker with live search
  void _showCurrencyPicker({
    required String title,
    required String current,
    required void Function(String) onSelect,
  }) {
    final codes = controller.currencyCodes;
    final names = controller.currencyNames;
    // query lives outside the builder so it survives rebuilds
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
                _sheetHandle(sheetCtx),
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
                    autofocus: false,
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
                            final selected = code == current;
                            return ListTile(
                              dense: true,
                              title: Text(
                                code,
                                style: TextStyle(
                                  color: selected
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
                              trailing: selected
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

  // Simple picker for fixed-option lists (List filter, Digit separator)
  void _showSimplePicker({
    required String title,
    required String current,
    required List<String> options,
    required void Function(String) onSelect,
  }) {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (sheetCtx, _) => Container(
          decoration: BoxDecoration(
            color: sheetCtx.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _sheetHandle(sheetCtx),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: sheetCtx.primaryText,
                ),
              ),
              Divider(height: 16, color: sheetCtx.dividerColor),
              ...options.map(
                (opt) => ListTile(
                  dense: true,
                  title: Text(
                    opt,
                    style: TextStyle(
                      color: opt == current
                          ? sheetCtx.primaryAccent
                          : sheetCtx.primaryText,
                      fontWeight: opt == current
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: opt == current
                      ? Icon(
                          Icons.check,
                          color: sheetCtx.primaryAccent,
                          size: 18,
                        )
                      : null,
                  onTap: () {
                    onSelect(opt);
                    Get.back();
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetHandle(BuildContext context) => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: context.secondaryText.withOpacity(0.4),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _buildThemeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: TextStyle(
              color: context.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => _buildToggleRow(
              context: context,
              label: 'Color Scheme',
              // Shows which scheme is active as a live hint
              subtitle: controller.colorScheme.value ? 'Purple' : 'Blue',
              value: controller.colorScheme.value,
              onChanged: controller.toggleColorScheme,
            ),
          ),
          _buildDivider(context),
          Obx(
            () => _buildToggleRow(
              context: context,
              label: 'Dark Mode',
              value: controller.isDarkMode.value,
              onChanged: controller.toggleDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required BuildContext context,
    required String label,
    String? subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: context.secondaryText, fontSize: 15),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  color: context.primaryAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: context.primaryAccent,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) =>
      Divider(height: 24, thickness: 1, color: context.dividerColor);

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: Text(
          'RateFlip © 2025',
          style: TextStyle(color: context.secondaryText, fontSize: 13),
        ),
      ),
    );
  }
}

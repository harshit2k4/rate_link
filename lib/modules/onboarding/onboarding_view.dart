import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/routes/app_pages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../data/providers/frankfurter_provider.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();
  final _searchController = TextEditingController();

  int _page = 0;
  String _baseCurrency = 'USD';
  String _targetCurrency = 'INR';
  Map<String, String> _currencyNames = {};
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrencies() async {
    try {
      final data = await FrankfurterProvider().getCurrencies();
      if (mounted) {
        setState(() {
          _currencyNames = Map<String, String>.from(data);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> get _filteredCodes {
    final codes = _currencyNames.keys.toList()..sort();
    if (_searchQuery.isEmpty) return codes;
    final q = _searchQuery.toLowerCase();
    return codes
        .where(
          (c) =>
              c.toLowerCase().contains(q) ||
              (_currencyNames[c] ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  void _goNext() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final prefs = Hive.box('prefs');
    await prefs.put('baseCurrency', _baseCurrency);
    await prefs.put('targetCurrency', _targetCurrency);
    await prefs.put('onboardingDone', true);
    Get.offAllNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            _buildWelcomePage(context),
            _buildPickerPage(
              context,
              pageIndex: 1,
              title: 'I have...',
              subtitle: 'Choose your base currency',
              selected: _baseCurrency,
              onSelect: (code) {
                setState(() => _baseCurrency = code);
                _goNext();
              },
            ),
            _buildPickerPage(
              context,
              pageIndex: 2,
              title: 'I want to track...',
              subtitle: 'Choose your target currency',
              selected: _targetCurrency,
              onSelect: (code) {
                setState(() => _targetCurrency = code);
                _finish();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // App logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'R',
                    style: TextStyle(
                      color: context.primaryAccent,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: 'F',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'RateLink',
            style: TextStyle(
              color: context.primaryText,
              fontSize: 38,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Real-time exchange rates,\nalways in your pocket.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.secondaryText,
              fontSize: 17,
              height: 1.6,
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPickerPage(
    BuildContext context, {
    required int pageIndex,
    required String title,
    required String subtitle,
    required String selected,
    required void Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step dots
              Row(
                children: List.generate(
                  2,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    width: i + 1 == pageIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i + 1 == pageIndex
                          ? context.primaryAccent
                          : context.primaryAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                style: TextStyle(
                  color: context.primaryText,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: context.secondaryText, fontSize: 15),
              ),
              const SizedBox(height: 20),
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(color: context.primaryText, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search currency...',
                  hintStyle: TextStyle(
                    color: context.secondaryText,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.secondaryText,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: context.searchFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: context.primaryAccent,
                  ),
                )
              : _filteredCodes.isEmpty
              ? Center(
                  child: Text(
                    'No currencies found.',
                    style: TextStyle(color: context.secondaryText),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCodes.length,
                  itemBuilder: (_, i) {
                    final code = _filteredCodes[i];
                    final name = _currencyNames[code] ?? '';
                    final isSel = code == selected;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: isSel
                          ? context.primaryAccent.withOpacity(0.08)
                          : null,
                      title: Text(
                        code,
                        style: TextStyle(
                          color: isSel
                              ? context.primaryAccent
                              : context.primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        name,
                        style: TextStyle(
                          color: context.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                      trailing: isSel
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: context.primaryAccent,
                              size: 20,
                            )
                          : null,
                      onTap: () => onSelect(code),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

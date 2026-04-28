import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/parafix_theme.dart';
import '../features/compose/add_expense_sheet.dart';
import '../features/home/home_screen.dart';
import '../features/report/report_screen.dart';
import '../features/settings/personalization_sheet.dart';
import '../models/expense_category.dart';
import '../models/expense_entry.dart';
import '../models/monthly_payment.dart';

class ParafixApp extends StatefulWidget {
  const ParafixApp({super.key});

  @override
  State<ParafixApp> createState() => _ParafixAppState();
}

class _ParafixAppState extends State<ParafixApp> {
  static const _themeStorageKey = 'parafix_theme_preset_v1';
  static const _customCategoriesStorageKey = 'parafix_custom_categories_v1';
  static const _entriesStorageKey = 'parafix_entries_v1';
  static const _monthlyPaymentsStorageKey = 'parafix_monthly_payments_v1';

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final PageController _pageController;
  late final ValueNotifier<List<ExpenseEntry>> _entriesNotifier;
  late final ValueNotifier<List<MonthlyPayment>> _monthlyPaymentsNotifier;
  late final ValueNotifier<int> _tabIndexNotifier;
  OverlayEntry? _feedbackEntry;
  Timer? _feedbackTimer;

  final List<ExpenseCategory> _coreCategories = [
    ExpenseCategory(
      id: 'market',
      name: 'Market',
      icon: Icons.shopping_bag_rounded,
      color: const Color(0xFF5B8C5A),
      isBuiltIn: true,
    ),
    ExpenseCategory(
      id: 'food',
      name: 'Yeme İçme',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFD86F45),
      isBuiltIn: true,
    ),
    ExpenseCategory(
      id: 'transport',
      name: 'Ulaşım',
      icon: Icons.directions_bus_rounded,
      color: const Color(0xFF4A6FA5),
      isBuiltIn: true,
    ),
    ExpenseCategory(
      id: 'bills',
      name: 'Fatura',
      icon: Icons.receipt_long_rounded,
      color: const Color(0xFF7C5CFC),
      isBuiltIn: true,
    ),
    ExpenseCategory(
      id: 'other',
      name: 'Diğer',
      icon: Icons.more_horiz_rounded,
      color: const Color(0xFF6C707A),
      isBuiltIn: true,
    ),
  ];

  late ParafixThemePreset _selectedPreset;
  late List<ExpenseCategory> _customCategories;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabIndexNotifier = ValueNotifier(0);
    _selectedPreset = ParafixTheme.presets.first;
    _customCategories = [
      ExpenseCategory(
        id: 'pet',
        name: 'Evcil',
        icon: Icons.pets_rounded,
        color: const Color(0xFFB35D8D),
      ),
      ExpenseCategory(
        id: 'health',
        name: 'Sağlık',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFCC5A71),
      ),
    ];
    _entriesNotifier = ValueNotifier(_seedEntries());
    _monthlyPaymentsNotifier = ValueNotifier(_seedMonthlyPayments());
    unawaited(_restorePersistedState());
  }

  List<ExpenseCategory> get _allCategories => [
    ..._coreCategories,
    ..._customCategories,
  ];

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _feedbackEntry?.remove();
    _pageController.dispose();
    _entriesNotifier.dispose();
    _monthlyPaymentsNotifier.dispose();
    _tabIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parafix',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      locale: const Locale('tr', 'TR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      theme: ParafixTheme.buildTheme(preset: _selectedPreset),
      scrollBehavior: const ParafixScrollBehavior(),
      home: Scaffold(
        extendBody: true,
        appBar: AppBar(
          toolbarHeight: 76,
          titleSpacing: 0,
          title: ValueListenableBuilder<int>(
            valueListenable: _tabIndexNotifier,
            builder: (context, tabIndex, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tabIndex == 0 ? 'Parafix' : 'Rapor',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    tabIndex == 0
                        ? 'Harcamalarını tek bakışta gör.'
                        : 'Özetini net biçimde incele.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton.filledTonal(
                onPressed: _openPersonalization,
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Tema ve kategoriler',
              ),
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => _tabIndexNotifier.value = index,
          children: [
            ValueListenableBuilder<List<ExpenseEntry>>(
              valueListenable: _entriesNotifier,
              builder: (context, entries, _) {
                return RepaintBoundary(
                  child: HomeScreen(
                    key: const PageStorageKey('home-screen'),
                    entries: entries,
                    accentColor: _selectedPreset.accent,
                    onDeleteEntry: _deleteEntry,
                    onEditEntry: _editEntry,
                  ),
                );
              },
            ),
            ListenableBuilder(
              listenable: Listenable.merge([
                _entriesNotifier,
                _monthlyPaymentsNotifier,
              ]),
              builder: (context, _) {
                return RepaintBoundary(
                  child: ReportScreen(
                    key: const PageStorageKey('report-screen'),
                    entries: _entriesNotifier.value,
                    monthlyPayments: _monthlyPaymentsNotifier.value,
                    categories: _allCategories,
                    accentColor: _selectedPreset.accent,
                    onUpsertMonthlyPayment: _upsertMonthlyPayment,
                    onDeleteMonthlyPayment: _deleteMonthlyPayment,
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.large(
          onPressed: _openAddExpense,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 34),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _tabIndexNotifier,
          builder: (context, tabIndex, _) {
            return _ShellNavigationBar(
              currentIndex: tabIndex,
              onSelected: _goToTab,
            );
          },
        ),
      ),
    );
  }

  Future<void> _openAddExpense() async {
    await _openExpenseSheet();
  }

  Future<ExpenseEntry?> _editEntry(ExpenseEntry entry) async {
    return _openExpenseSheet(entry: entry);
  }

  Future<ExpenseEntry?> _openExpenseSheet({ExpenseEntry? entry}) async {
    final isEditing = entry != null;
    final modalContext = _navigatorKey.currentContext;
    if (modalContext == null) {
      return null;
    }

    final draft = await showModalBottomSheet<ExpenseDraft>(
      context: modalContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.86,
        minChildSize: 0.52,
        maxChildSize: 0.94,
        snap: true,
        snapSizes: const [0.86],
        shouldCloseOnMinExtent: true,
        builder: (context, scrollController) {
          return AddExpenseSheet(
            scrollController: scrollController,
            categories: _allCategories,
            recentCategoryIds: _recentCategoryIds(),
            initialEntry: entry == null
                ? null
                : ExpenseDraft(
                    title: entry.title,
                    amount: entry.amount,
                    date: entry.date,
                    category: entry.category,
                    note: entry.note,
                  ),
          );
        },
      ),
    );

    if (draft == null) {
      return null;
    }

    final nextEntry = ExpenseEntry(
      id: entry?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: draft.title,
      amount: draft.amount,
      note: draft.note,
      date: draft.date,
      category: draft.category,
    );

    _entriesNotifier.value = _upsertEntrySorted(
      _entriesNotifier.value,
      nextEntry,
    );
    unawaited(_persistState());

    _showFeedback(isEditing ? 'Harcama güncellendi.' : 'Harcama eklendi.');

    return nextEntry;
  }

  Future<void> _openPersonalization() async {
    final modalContext = _navigatorKey.currentContext;
    if (modalContext == null) {
      return;
    }

    final categoryResult = await showModalBottomSheet<CategoryEditorResult>(
      context: modalContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.86,
        minChildSize: 0.52,
        maxChildSize: 0.94,
        snap: true,
        snapSizes: const [0.86],
        shouldCloseOnMinExtent: true,
        builder: (context, scrollController) {
          return PersonalizationSheet(
            scrollController: scrollController,
            presets: ParafixTheme.presets,
            selectedPreset: _selectedPreset,
            categories: _allCategories,
            customCount: _customCategories.length,
            onPresetSelected: _selectPreset,
          );
        },
      ),
    );

    if (categoryResult == null) {
      return;
    }

    if (categoryResult.previousCategoryId == null &&
        _customCategories.length >= 5) {
      _showFeedback('En fazla 5 özel kategori ekleyebilirsin.');
      return;
    }

    setState(() {
      if (categoryResult.previousCategoryId != null) {
        _customCategories = _customCategories
            .map(
              (category) => category.id == categoryResult.previousCategoryId
                  ? categoryResult.category
                  : category,
            )
            .toList(growable: false);
        _entriesNotifier.value = _entriesNotifier.value
            .map(
              (entry) => entry.category.id == categoryResult.previousCategoryId
                  ? ExpenseEntry(
                      id: entry.id,
                      title: entry.title,
                      amount: entry.amount,
                      note: entry.note,
                      date: entry.date,
                      category: categoryResult.category,
                    )
                  : entry,
            )
            .toList(growable: false);
        _monthlyPaymentsNotifier.value = _monthlyPaymentsNotifier.value
            .map(
              (payment) =>
                  payment.category.id == categoryResult.previousCategoryId
                  ? payment.copyWith(category: categoryResult.category)
                  : payment,
            )
            .toList(growable: false);
      } else {
        _customCategories = [..._customCategories, categoryResult.category];
      }
    });
    unawaited(_persistState());
  }

  List<ExpenseEntry> _seedEntries() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final categories = {
      for (final category in [..._coreCategories, ..._customCategories])
        category.id: category,
    };

    DateTime at(int daysAgo, int hour, int minute) {
      return today
          .subtract(Duration(days: daysAgo))
          .add(Duration(hours: hour, minutes: minute));
    }

    ExpenseEntry entry({
      required String id,
      required String title,
      required double amount,
      required DateTime date,
      required String categoryId,
      String? note,
    }) {
      return ExpenseEntry(
        id: id,
        title: title,
        amount: amount,
        date: date,
        category: categories[categoryId]!,
        note: note,
      );
    }

    return [
      entry(
        id: '1',
        title: 'Sinema',
        amount: 400,
        date: at(0, 17, 20),
        categoryId: 'other',
      ),
      entry(
        id: '2',
        title: 'Metro',
        amount: 25,
        date: at(0, 16, 45),
        categoryId: 'transport',
      ),
      entry(
        id: '3',
        title: 'Kitap',
        amount: 700,
        date: at(0, 14, 10),
        categoryId: 'other',
        note: 'Kampüs kitabevi',
      ),
      entry(
        id: '4',
        title: 'Ara öğün',
        amount: 250,
        date: at(0, 11, 35),
        categoryId: 'food',
      ),
      entry(
        id: '5',
        title: 'Eczane',
        amount: 850,
        date: at(1, 18, 30),
        categoryId: 'health',
      ),
      entry(
        id: '6',
        title: 'Akşam yemeği',
        amount: 950,
        date: at(2, 20, 15),
        categoryId: 'food',
      ),
      entry(
        id: '7',
        title: 'Metro',
        amount: 50,
        date: at(3, 9, 20),
        categoryId: 'transport',
      ),
      entry(
        id: '8',
        title: 'Aylık market',
        amount: 2500,
        date: at(4, 19, 5),
        categoryId: 'market',
        note: 'Temel ihtiyaçlar',
      ),
      entry(
        id: '9',
        title: 'Veteriner',
        amount: 1250,
        date: at(5, 16, 40),
        categoryId: 'pet',
      ),
      entry(
        id: '10',
        title: 'Haftalık market',
        amount: 650,
        date: at(6, 18, 10),
        categoryId: 'market',
      ),
      entry(
        id: '11',
        title: 'İnternet faturası',
        amount: 620,
        date: at(8, 10, 0),
        categoryId: 'bills',
      ),
      entry(
        id: '12',
        title: 'Spor salonu',
        amount: 750,
        date: at(10, 12, 30),
        categoryId: 'other',
      ),
      entry(
        id: '13',
        title: 'Taksi',
        amount: 180,
        date: at(12, 22, 10),
        categoryId: 'transport',
      ),
      entry(
        id: '14',
        title: 'Market',
        amount: 540,
        date: at(14, 17, 50),
        categoryId: 'market',
      ),
      entry(
        id: '15',
        title: 'Öğle yemeği',
        amount: 220,
        date: at(16, 13, 15),
        categoryId: 'food',
      ),
      entry(
        id: '16',
        title: 'Diş kontrolü',
        amount: 900,
        date: at(19, 15, 45),
        categoryId: 'health',
      ),
      entry(
        id: '17',
        title: 'Elektrik',
        amount: 460,
        date: at(22, 10, 25),
        categoryId: 'bills',
      ),
      entry(
        id: '18',
        title: 'Mama',
        amount: 320,
        date: at(25, 18, 0),
        categoryId: 'pet',
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));
  }

  List<MonthlyPayment> _seedMonthlyPayments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final categories = {
      for (final category in [..._coreCategories, ..._customCategories])
        category.id: category,
    };

    int billingDayIn(int days) {
      return today.add(Duration(days: days)).day;
    }

    return [
      MonthlyPayment(
        id: 'monthly-1',
        title: 'Spotify Premium',
        amount: 60,
        billingDay: billingDayIn(1),
        category: categories['bills']!,
      ),
      MonthlyPayment(
        id: 'monthly-2',
        title: 'İnternet',
        amount: 620,
        billingDay: billingDayIn(4),
        category: categories['bills']!,
      ),
      MonthlyPayment(
        id: 'monthly-3',
        title: 'iCloud+',
        amount: 80,
        billingDay: billingDayIn(8),
        category: categories['other']!,
      ),
      MonthlyPayment(
        id: 'monthly-4',
        title: 'Spor salonu',
        amount: 750,
        billingDay: billingDayIn(12),
        category: categories['health']!,
      ),
    ];
  }

  List<ExpenseEntry> _insertEntrySorted(
    List<ExpenseEntry> entries,
    ExpenseEntry newEntry,
  ) {
    final nextEntries = [...entries];
    var low = 0;
    var high = nextEntries.length;

    while (low < high) {
      final mid = low + ((high - low) >> 1);
      if (newEntry.date.isAfter(nextEntries[mid].date)) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }

    nextEntries.insert(low, newEntry);

    return nextEntries;
  }

  List<ExpenseEntry> _upsertEntrySorted(
    List<ExpenseEntry> entries,
    ExpenseEntry nextEntry,
  ) {
    final filtered = entries
        .where((entry) => entry.id != nextEntry.id)
        .toList(growable: false);
    return _insertEntrySorted(filtered, nextEntry);
  }

  List<String> _recentCategoryIds() {
    final ids = <String>[];

    for (final entry in _entriesNotifier.value) {
      if (ids.contains(entry.category.id)) {
        continue;
      }
      ids.add(entry.category.id);
      if (ids.length == 3) {
        break;
      }
    }

    return ids;
  }

  void _upsertMonthlyPayment(MonthlyPayment nextPayment) {
    final isEditing = _monthlyPaymentsNotifier.value.any(
      (payment) => payment.id == nextPayment.id,
    );
    _monthlyPaymentsNotifier.value = _upsertMonthlyPaymentList(
      _monthlyPaymentsNotifier.value,
      nextPayment,
    );
    unawaited(_persistState());
    _showFeedback(
      isEditing ? 'Aylık ödeme güncellendi.' : 'Aylık ödeme eklendi.',
    );
  }

  List<MonthlyPayment> _upsertMonthlyPaymentList(
    List<MonthlyPayment> payments,
    MonthlyPayment nextPayment,
  ) {
    final nextPayments = payments
        .where((payment) => payment.id != nextPayment.id)
        .toList(growable: true);
    nextPayments.add(nextPayment);
    return List<MonthlyPayment>.unmodifiable(nextPayments);
  }

  void _deleteMonthlyPayment(String id) {
    _monthlyPaymentsNotifier.value = _monthlyPaymentsNotifier.value
        .where((payment) => payment.id != id)
        .toList(growable: false);
    unawaited(_persistState());
    _showFeedback('Aylık ödeme silindi.');
  }

  void _goToTab(int index) {
    if (_tabIndexNotifier.value == index) {
      return;
    }

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutQuart,
    );
  }

  void _deleteEntry(ExpenseEntry target) {
    _entriesNotifier.value = _entriesNotifier.value
        .where((entry) => entry.id != target.id)
        .toList(growable: false);
    unawaited(_persistState());
    _showFeedback('Harcama silindi.');
  }

  void _selectPreset(ParafixThemePreset preset) {
    if (_selectedPreset.id == preset.id) {
      return;
    }

    setState(() => _selectedPreset = preset);
    unawaited(_persistState());
  }

  Future<void> _restorePersistedState() async {
    final preferences = await SharedPreferences.getInstance();
    final storedPresetId = preferences.getString(_themeStorageKey);
    final storedCustomCategories = preferences.getString(
      _customCategoriesStorageKey,
    );
    final storedEntries = preferences.getString(_entriesStorageKey);
    final storedMonthlyPayments = preferences.getString(
      _monthlyPaymentsStorageKey,
    );

    var nextPreset = _selectedPreset;
    var nextCustomCategories = _customCategories;
    List<ExpenseEntry>? nextEntries;
    var nextMonthlyPayments = _monthlyPaymentsNotifier.value;

    if (storedPresetId != null) {
      nextPreset = ParafixTheme.presets.firstWhere(
        (preset) => preset.id == storedPresetId,
        orElse: () => _selectedPreset,
      );
    }

    if (storedCustomCategories != null) {
      final decoded = jsonDecode(storedCustomCategories) as List<dynamic>;
      nextCustomCategories = decoded
          .map(
            (item) => ExpenseCategory.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    }

    if (storedEntries != null) {
      final categoriesById = {
        for (final category in [..._coreCategories, ...nextCustomCategories])
          category.id: category,
      };
      final fallbackCategory = categoriesById['other']!;
      final decoded = jsonDecode(storedEntries) as List<dynamic>;
      nextEntries =
          decoded
              .map(
                (item) => ExpenseEntry.fromJson(
                  Map<String, dynamic>.from(item as Map),
                  resolveCategory: (categoryId) =>
                      categoriesById[categoryId] ?? fallbackCategory,
                ),
              )
              .toList(growable: false)
            ..sort((a, b) => b.date.compareTo(a.date));
      nextEntries = _alignScreenshotSeedEntriesToToday(nextEntries);
    }

    if (storedMonthlyPayments != null) {
      final categoriesById = {
        for (final category in [..._coreCategories, ...nextCustomCategories])
          category.id: category,
      };
      final fallbackCategory = categoriesById['other']!;
      final decoded = jsonDecode(storedMonthlyPayments) as List<dynamic>;
      nextMonthlyPayments = decoded
          .map(
            (item) => MonthlyPayment.fromJson(
              Map<String, dynamic>.from(item as Map),
              resolveCategory: (categoryId) =>
                  categoriesById[categoryId] ?? fallbackCategory,
            ),
          )
          .toList(growable: false);
      nextMonthlyPayments = _alignScreenshotSeedPaymentsToToday(
        nextMonthlyPayments,
      );
    } else if (storedPresetId != null ||
        storedCustomCategories != null ||
        storedEntries != null) {
      nextMonthlyPayments = const [];
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedPreset = nextPreset;
      _customCategories = nextCustomCategories;
      if (nextEntries != null) {
        _entriesNotifier.value = nextEntries;
      }
      _monthlyPaymentsNotifier.value = nextMonthlyPayments;
    });
  }

  Future<void> _persistState() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeStorageKey, _selectedPreset.id);
    await preferences.setString(
      _customCategoriesStorageKey,
      jsonEncode(
        _customCategories.map((category) => category.toJson()).toList(),
      ),
    );
    await preferences.setString(
      _entriesStorageKey,
      jsonEncode(
        _entriesNotifier.value.map((entry) => entry.toJson()).toList(),
      ),
    );
    await preferences.setString(
      _monthlyPaymentsStorageKey,
      jsonEncode(
        _monthlyPaymentsNotifier.value
            .map((payment) => payment.toJson())
            .toList(),
      ),
    );
  }

  List<ExpenseEntry> _alignScreenshotSeedEntriesToToday(
    List<ExpenseEntry> entries,
  ) {
    const seedEntryIds = {
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
    };

    if (entries.isEmpty ||
        entries.any((entry) => !seedEntryIds.contains(entry.id))) {
      return entries;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final newestDay = DateTime(
      entries.first.date.year,
      entries.first.date.month,
      entries.first.date.day,
    );
    final dayOffset = today.difference(newestDay).inDays;

    if (dayOffset == 0) {
      return entries;
    }

    return entries
        .map(
          (entry) => ExpenseEntry(
            id: entry.id,
            title: entry.title,
            amount: entry.amount,
            date: entry.date.add(Duration(days: dayOffset)),
            category: entry.category,
            note: entry.note,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<MonthlyPayment> _alignScreenshotSeedPaymentsToToday(
    List<MonthlyPayment> payments,
  ) {
    const seedPaymentOffsets = {
      'monthly-1': 1,
      'monthly-2': 4,
      'monthly-3': 8,
      'monthly-4': 12,
    };

    if (payments.isEmpty ||
        payments.any(
          (payment) => !seedPaymentOffsets.containsKey(payment.id),
        )) {
      return payments;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return payments
        .map(
          (payment) => payment.copyWith(
            billingDay: today
                .add(Duration(days: seedPaymentOffsets[payment.id]!))
                .day,
          ),
        )
        .toList(growable: false);
  }

  void _showFeedback(String message) {
    final overlay = _navigatorKey.currentState?.overlay;
    if (overlay == null) {
      return;
    }

    _feedbackTimer?.cancel();
    _feedbackEntry?.remove();

    final isDark = _selectedPreset.brightness == Brightness.dark;
    _feedbackEntry = OverlayEntry(
      builder: (_) => _FeedbackToast(
        message: message,
        backgroundColor: isDark
            ? const Color(0xFF243149)
            : const Color(0xFF111418),
        borderColor: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.12),
      ),
    );

    overlay.insert(_feedbackEntry!);
    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      _feedbackEntry?.remove();
      _feedbackEntry = null;
    });
  }
}

class _FeedbackToast extends StatelessWidget {
  const _FeedbackToast({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String message;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return IgnorePointer(
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 72),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellNavigationBar extends StatelessWidget {
  const _ShellNavigationBar({
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<ParafixPalette>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.24 : 0.06,
            ),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: BottomAppBar(
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        notchMargin: 10,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                label: 'Ana Sayfa',
                icon: Icons.home_rounded,
                selected: currentIndex == 0,
                onTap: () => onSelected(0),
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              child: _NavItem(
                label: 'Rapor',
                icon: Icons.bar_chart_rounded,
                selected: currentIndex == 1,
                onTap: () => onSelected(1),
              ),
            ),
          ],
        ),
      ).withSurfaceTint(theme),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ParafixPalette>()!;
    final selectedBackground = colors.accent.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.26 : 0.14,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Color.lerp(Colors.transparent, selectedBackground, value),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 1 + (0.04 * value),
                  child: Icon(
                    icon,
                    color: Color.lerp(colors.mutedText, colors.accent, value),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Color.lerp(colors.mutedText, colors.accent, value),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension on BottomAppBar {
  Widget withSurfaceTint(ThemeData theme) {
    return Theme(
      data: theme.copyWith(splashFactory: InkRipple.splashFactory),
      child: this,
    );
  }
}

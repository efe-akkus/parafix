import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/parafix_theme.dart';
import '../../models/expense_category.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({
    super.key,
    required this.categories,
    this.recentCategoryIds = const [],
    this.initialEntry,
    this.scrollController,
  });

  final List<ExpenseCategory> categories;
  final List<String> recentCategoryIds;
  final ExpenseDraft? initialEntry;
  final ScrollController? scrollController;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late ExpenseCategory _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  bool get _isFormValid {
    final amount = int.tryParse(_amountController.text);
    return _titleController.text.trim().isNotEmpty &&
        amount != null &&
        amount > 0;
  }

  List<ExpenseCategory> get _recentCategories {
    if (widget.recentCategoryIds.isEmpty) {
      return const [];
    }

    final recentCategories = widget.categories
        .where((category) => widget.recentCategoryIds.contains(category.id))
        .toList();

    recentCategories.sort(
      (left, right) => widget.recentCategoryIds
          .indexOf(left.id)
          .compareTo(widget.recentCategoryIds.indexOf(right.id)),
    );

    return recentCategories;
  }

  List<ExpenseCategory> get _remainingCategories {
    if (widget.recentCategoryIds.isEmpty) {
      return widget.categories;
    }

    final recentIds = widget.recentCategoryIds.toSet();
    return widget.categories
        .where((category) => !recentIds.contains(category.id))
        .toList(growable: false);
  }

  List<ExpenseCategory> get _displayedCategories {
    return [..._recentCategories, ..._remainingCategories];
  }

  @override
  void initState() {
    super.initState();
    final initialEntry = widget.initialEntry;
    final now = DateTime.now();
    _selectedCategory = initialEntry?.category ?? _displayedCategories.first;
    final initialDate = initialEntry?.date ?? now;
    _selectedDate = initialDate.isAfter(now) ? now : initialDate;
    _titleController.text = initialEntry?.title ?? '';
    _amountController.text = initialEntry == null
        ? ''
        : initialEntry.amount.toStringAsFixed(0);
    _noteController.text = initialEntry?.note ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ParafixPalette>()!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: parafixPlatformScrollPhysics(Theme.of(context).platform),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 14),
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: palette.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.initialEntry == null
                        ? 'Yeni harcama'
                        : 'Harcamayı düzenle',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.initialEntry == null
                        ? 'Hızlıca yeni bir kayıt ekle.'
                        : 'Bilgileri güncelle.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    inputFormatters: const [_AmountInputFormatter()],
                    style: Theme.of(context).textTheme.headlineMedium,
                    decoration: const InputDecoration(
                      labelText: 'Tutar',
                      hintText: '0',
                    ),
                    validator: (value) {
                      final amount = int.tryParse(value ?? '');
                      if (amount == null || amount <= 0) {
                        return '0\'dan büyük bir tutar gir.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: const InputDecoration(
                      labelText: 'Başlık',
                      hintText: 'Kahve, market, taksi...',
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Kısa bir başlık gir.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Kategori',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (_recentCategories.isNotEmpty) ...[
                    Text(
                      'Son kullanılanlar',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _recentCategories
                          .map(
                            (category) => _CategoryChip(
                              category: category,
                              selected: _selectedCategory.id == category.id,
                              onSelected: () =>
                                  setState(() => _selectedCategory = category),
                            ),
                          )
                          .toList(),
                    ),
                    if (_remainingCategories.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Diğer kategoriler',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                  if (_remainingCategories.isNotEmpty ||
                      _recentCategories.isEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _remainingCategories
                          .map(
                            (category) => _CategoryChip(
                              category: category,
                              selected: _selectedCategory.id == category.id,
                              onSelected: () =>
                                  setState(() => _selectedCategory = category),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Not',
                      hintText: 'İstersen kısa bir açıklama ekle.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tarih'),
                    subtitle: Text(_formatDate(_selectedDate)),
                    trailing: IconButton.filledTonal(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        _titleController,
                        _amountController,
                      ]),
                      builder: (context, _) {
                        return FilledButton(
                          onPressed: _isFormValid ? _submit : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              widget.initialEntry == null
                                  ? 'Kaydet'
                                  : 'Güncelle',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('tr', 'TR'),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDate: _selectedDate.isAfter(DateTime.now())
          ? DateTime.now()
          : _selectedDate,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);

    Navigator.of(context).pop(
      ExpenseDraft(
        title: _titleController.text.trim(),
        amount: amount,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        date: _selectedDate,
        category: _selectedCategory,
      ),
    );
  }
}

class _AmountInputFormatter extends TextInputFormatter {
  const _AmountInputFormatter();

  static final RegExp _validPattern = RegExp(r'^\d{0,8}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _validPattern.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

class ExpenseDraft {
  const ExpenseDraft({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  });

  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? note;
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 18),
          const SizedBox(width: 8),
          Text(category.name),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: category.color.withValues(alpha: 0.18),
      side: BorderSide.none,
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

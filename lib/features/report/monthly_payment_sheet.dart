import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/parafix_theme.dart';
import '../../models/expense_category.dart';
import '../../models/monthly_payment.dart';

class MonthlyPaymentSheet extends StatefulWidget {
  const MonthlyPaymentSheet({
    super.key,
    required this.categories,
    this.initialPayment,
    this.scrollController,
  });

  final List<ExpenseCategory> categories;
  final MonthlyPayment? initialPayment;
  final ScrollController? scrollController;

  @override
  State<MonthlyPaymentSheet> createState() => _MonthlyPaymentSheetState();
}

class _MonthlyPaymentSheetState extends State<MonthlyPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late ExpenseCategory _selectedCategory;
  late int _selectedBillingDay;
  bool _isActive = true;

  bool get _isFormValid {
    final amount = int.tryParse(_amountController.text);
    return _titleController.text.trim().isNotEmpty &&
        amount != null &&
        amount > 0;
  }

  @override
  void initState() {
    super.initState();
    final initialPayment = widget.initialPayment;
    _selectedCategory = initialPayment?.category ?? widget.categories.first;
    _selectedBillingDay = initialPayment?.billingDay ?? DateTime.now().day;
    _isActive = initialPayment?.isActive ?? true;
    _titleController.text = initialPayment?.title ?? '';
    _amountController.text = initialPayment == null
        ? ''
        : initialPayment.amount.toStringAsFixed(0);
    _noteController.text = initialPayment?.note ?? '';
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
    final isEditing = widget.initialPayment != null;

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
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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
                    isEditing ? 'Aylık ödemeyi düzenle' : 'Aylık ödeme ekle',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEditing
                        ? 'Tutarı, günü ya da durumu güncelle.'
                        : 'Tekrarlayan ödemelerini tek yerde topla.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      hintText: 'Spotify, internet, aidat...',
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
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.categories
                        .map(
                          (category) => ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(category.icon, size: 18),
                                const SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                            selected: _selectedCategory.id == category.id,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = category),
                            selectedColor: category.color.withValues(
                              alpha: 0.18,
                            ),
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Ödeme günü',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedBillingDay,
                    items: List.generate(
                      31,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}. gün'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _selectedBillingDay = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Her ay hangi gün',
                    ),
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
                  const SizedBox(height: 10),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Aktif'),
                    subtitle: Text(
                      _isActive
                          ? 'Raporlarda ve yaklaşan ödemelerde görünsün.'
                          : 'Kayıt dursun ama toplamda sayılmasın.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(isEditing ? 'Güncelle' : 'Kaydet'),
                          ),
                        );
                      },
                    ),
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _delete,
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Kaydı sil'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final initialPayment = widget.initialPayment;
    Navigator.of(context).pop(
      MonthlyPaymentSheetResult.save(
        MonthlyPayment(
          id:
              initialPayment?.id ??
              DateTime.now().microsecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text),
          billingDay: _selectedBillingDay,
          category: _selectedCategory,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          isActive: _isActive,
        ),
      ),
    );
  }

  void _delete() {
    final initialPayment = widget.initialPayment;
    if (initialPayment == null) {
      return;
    }

    Navigator.of(
      context,
    ).pop(MonthlyPaymentSheetResult.delete(initialPayment.id));
  }
}

enum MonthlyPaymentSheetAction { save, delete }

class MonthlyPaymentSheetResult {
  const MonthlyPaymentSheetResult.save(this.payment)
    : action = MonthlyPaymentSheetAction.save,
      deletedPaymentId = null;

  const MonthlyPaymentSheetResult.delete(this.deletedPaymentId)
    : action = MonthlyPaymentSheetAction.delete,
      payment = null;

  final MonthlyPaymentSheetAction action;
  final MonthlyPayment? payment;
  final String? deletedPaymentId;
}

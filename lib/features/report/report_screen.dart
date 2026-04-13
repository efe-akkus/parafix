import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/parafix_theme.dart';
import '../../models/expense_entry.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    required this.entries,
    required this.accentColor,
  });

  final List<ExpenseEntry> entries;
  final Color accentColor;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedRange = 1;

  static const _ranges = [
    _ReportRange(label: 'Son 7 Gün', type: _RangeType.sevenDays),
    _ReportRange(label: 'Son 30 Gün', type: _RangeType.thirtyDays),
    _ReportRange(label: 'Bu Ay', type: _RangeType.currentMonth),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ParafixPalette>()!;
    final now = DateTime.now();
    final range = _ranges[_selectedRange];
    final filtered = _filterEntries(widget.entries, range.type, now);
    final buckets = _buildBuckets(filtered, range.type, now);
    final maxBucket = _maxBucket(buckets);
    final totalsByCategory = <String, double>{};

    for (final entry in filtered) {
      totalsByCategory.update(
        entry.category.name,
        (value) => value + entry.amount,
        ifAbsent: () => entry.amount,
      );
    }

    final rankedCategories = totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = filtered.fold<double>(0, (sum, entry) => sum + entry.amount);
    final average = filtered.isEmpty ? 0.0 : total / filtered.length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              _ranges.length,
              (index) => ChoiceChip(
                label: Text(_ranges[index].label),
                selected: _selectedRange == index,
                onSelected: (_) => setState(() => _selectedRange = index),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harcama ritmi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _rangeDescription(range.type),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Bu aralıkta kayıt yok.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    SizedBox(
                      height: 170,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: buckets
                            .map(
                              (bucket) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        bucket.value == 0
                                            ? '-'
                                            : _groupedWhole(bucket.value),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: math.max(
                                          14,
                                          maxBucket == 0
                                              ? 14
                                              : (bucket.value / maxBucket) *
                                                        96 +
                                                    16,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              widget.accentColor,
                                              widget.accentColor.withValues(
                                                alpha: 0.28,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        bucket.label,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ReportMetric(
                  label: 'Toplam',
                  value: _money(total),
                  accentColor: widget.accentColor,
                  emphasized: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReportMetric(
                  label: 'İşlem başı ort.',
                  value: _money(average),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori dağılımı',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ...rankedCategories
                      .take(5)
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(category.key)),
                                  Flexible(
                                    child: _ScaledReportText(
                                      text: _money(category.value),
                                      alignment: Alignment.centerRight,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  minHeight: 10,
                                  backgroundColor: palette.surfaceAlt,
                                  value: total == 0
                                      ? 0
                                      : category.value / total,
                                  valueColor: AlwaysStoppedAnimation(
                                    widget.accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (rankedCategories.isEmpty)
                    Text(
                      'Kayıt ekledikçe dağılım burada görünür.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aylık Ödemeler',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Yakında gelecek.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({
    required this.label,
    required this.value,
    this.accentColor,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final Color? accentColor;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ParafixPalette>()!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: emphasized && accentColor != null
            ? accentColor!.withValues(alpha: 0.12)
            : palette.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          _ScaledReportText(
            text: value,
            alignment: Alignment.centerLeft,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _ScaledReportText extends StatelessWidget {
  const _ScaledReportText({
    required this.text,
    required this.alignment,
    required this.style,
  });

  final String text;
  final Alignment alignment;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(text, maxLines: 1, softWrap: false, style: style),
    );
  }
}

enum _RangeType { sevenDays, thirtyDays, currentMonth }

class _ReportRange {
  const _ReportRange({required this.label, required this.type});

  final String label;
  final _RangeType type;
}

class _Bucket {
  const _Bucket({required this.label, required this.value});

  final String label;
  final double value;
}

List<ExpenseEntry> _filterEntries(
  List<ExpenseEntry> entries,
  _RangeType range,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final DateTime start;

  switch (range) {
    case _RangeType.sevenDays:
      start = today.subtract(const Duration(days: 6));
      break;
    case _RangeType.thirtyDays:
      start = today.subtract(const Duration(days: 29));
      break;
    case _RangeType.currentMonth:
      start = DateTime(now.year, now.month, 1);
      break;
  }

  return entries.where((entry) => !entry.date.isBefore(start)).toList();
}

List<_Bucket> _buildBuckets(
  List<ExpenseEntry> entries,
  _RangeType range,
  DateTime now,
) {
  switch (range) {
    case _RangeType.sevenDays:
      return _buildDailyBuckets(entries, now);
    case _RangeType.thirtyDays:
      return _buildFiveDayBuckets(entries, now);
    case _RangeType.currentMonth:
      return _buildWeeklyMonthBuckets(entries, now);
  }
}

List<_Bucket> _buildDailyBuckets(List<ExpenseEntry> entries, DateTime now) {
  final start = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 6));
  final buckets = <_Bucket>[];

  for (var i = 0; i < 7; i++) {
    final day = start.add(Duration(days: i));
    final total = entries
        .where((entry) => _sameDay(entry.date, day))
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    buckets.add(_Bucket(label: _weekdayLabel(day.weekday), value: total));
  }

  return buckets;
}

List<_Bucket> _buildFiveDayBuckets(List<ExpenseEntry> entries, DateTime now) {
  final start = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 29));
  final buckets = <_Bucket>[];

  for (var i = 0; i < 6; i++) {
    final chunkStart = start.add(Duration(days: i * 5));
    final chunkEnd = chunkStart.add(const Duration(days: 4));
    final total = entries
        .where(
          (entry) =>
              !_atStartOfDay(entry.date).isBefore(chunkStart) &&
              !_atStartOfDay(entry.date).isAfter(chunkEnd),
        )
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    buckets.add(
      _Bucket(label: '${chunkStart.day}-${chunkEnd.day}', value: total),
    );
  }

  return buckets;
}

List<_Bucket> _buildWeeklyMonthBuckets(
  List<ExpenseEntry> entries,
  DateTime now,
) {
  final monthStart = DateTime(now.year, now.month, 1);
  final daysInMonth = now.day;
  final buckets = <_Bucket>[];
  var weekIndex = 1;

  for (var day = 1; day <= daysInMonth; day += 7) {
    final chunkStart = monthStart.add(Duration(days: day - 1));
    final chunkEnd = monthStart.add(
      Duration(days: math.min(day + 5, daysInMonth) - 1),
    );
    final total = entries
        .where(
          (entry) =>
              !_atStartOfDay(entry.date).isBefore(chunkStart) &&
              !_atStartOfDay(entry.date).isAfter(chunkEnd),
        )
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    buckets.add(_Bucket(label: '$weekIndex. hf', value: total));
    weekIndex++;
  }

  return buckets;
}

double _maxBucket(List<_Bucket> buckets) {
  return buckets.fold<double>(
    0,
    (maxValue, bucket) => math.max(maxValue, bucket.value),
  );
}

String _rangeDescription(_RangeType range) {
  switch (range) {
    case _RangeType.sevenDays:
      return 'Son 7 günü gün gün gösterir.';
    case _RangeType.thirtyDays:
      return 'Son 30 günü 5 günlük bloklarla özetler.';
    case _RangeType.currentMonth:
      return 'Bu ayı hafta bloklarıyla gösterir.';
  }
}

String _weekdayLabel(int weekday) {
  const labels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  return labels[weekday - 1];
}

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

DateTime _atStartOfDay(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _money(double value) => '${_groupedWhole(value)}₺';

String _groupedWhole(double value) {
  final digits = value.round().abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }

  return buffer.toString();
}

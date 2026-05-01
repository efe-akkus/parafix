import 'package:flutter/material.dart';

import '../../core/theme/parafix_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    _OnboardingPageData(
      title: 'Harcamalarını hızlıca kaydet',
      description:
          'Tutarı, başlığı ve kategoriyi gir; harcaman birkaç saniyede kaydedilsin.',
      icon: Icons.add_rounded,
      chips: ['Tutar', 'Başlık', 'Kategori'],
    ),
    _OnboardingPageData(
      title: 'Özetini tek bakışta gör',
      description:
          'Bugün, son 7 gün ve bu ay ne kadar harcadığını sade özetlerle takip et.',
      icon: Icons.bar_chart_rounded,
      chips: ['Bugün', 'Son 7 gün', 'Bu ay'],
    ),
    _OnboardingPageData(
      title: 'Aylık ödemelerini unutma',
      description: 'Aboneliklerini ve düzenli ödemelerini tek yerde takip et.',
      icon: Icons.event_repeat_rounded,
      chips: ['Abonelik', 'Sıradaki', 'Aylık yük'],
    ),
    _OnboardingPageData(
      title: 'Kategori ve tema kişiselleştirmesi',
      description:
          'Kategorilerini düzenle, uygulamanın görünümünü kendi kullanımına göre seç.',
      icon: Icons.tune_rounded,
      chips: ['Tema', 'Kategori', 'Renk'],
    ),
  ];

  late final PageController _controller;
  var _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<ParafixPalette>()!;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _OnboardingAppIcon(),
                  const SizedBox(width: 1),
                  Text(
                    'arafix',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 32,
                      height: 1,
                      letterSpacing: -0.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sade gider takibi.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() {
                    _currentPage = index;
                  }),
                  itemBuilder: (context, index) {
                    return _OnboardingPage(data: _pages[index]);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: index == _currentPage ? 34 : 12,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? palette.accent
                          : palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  TextButton(
                    onPressed: _currentPage == 0 ? null : _goBack,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(112, 54),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Geri'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: isLastPage ? widget.onCompleted : _goNext,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(132, 56),
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(isLastPage ? 'Başla' : 'İleri'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBack() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutQuart,
    );
  }

  void _goNext() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutQuart,
    );
  }
}

class _OnboardingAppIcon extends StatelessWidget {
  const _OnboardingAppIcon();

  static const _assetPath =
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        _assetPath,
        width: 44,
        height: 44,
        cacheWidth: 132,
        cacheHeight: 132,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<ParafixPalette>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final preferredHeight = (constraints.maxHeight * 0.74)
            .clamp(380.0, 470.0)
            .toDouble();
        final cardHeight = preferredHeight > constraints.maxHeight
            ? constraints.maxHeight
            : preferredHeight;

        return Center(
          child: SizedBox(
            height: cardHeight,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: palette.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(data.icon, size: 46, color: palette.accent),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.mutedText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: data.chips
                        .map(
                          (chip) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: palette.surfaceAlt.withValues(alpha: 0.62),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              chip,
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.chips,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<String> chips;
}

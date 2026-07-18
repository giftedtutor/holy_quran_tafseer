import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/quran_navigation.dart';
import '../widgets/screen_header.dart';

class PageJumpScreen extends StatefulWidget {
  const PageJumpScreen({super.key, required this.prefs});

  final PreferencesService prefs;

  @override
  State<PageJumpScreen> createState() => _PageJumpScreenState();
}

class _PageJumpScreenState extends State<PageJumpScreen> {
  final _pageController = TextEditingController();

  static const _quickPages = [1, 2, 50, 100, 200, 300, 400, 500, 604];

  void _goToPage(int page) {
    Navigator.pop(context, page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: theme.background,
        body: Column(
          children: [
            const ReaderToolbar(title: 'Go to Page'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
                    controller: _pageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter page number (1–604)',
                      suffixIcon: TextButton(
                        onPressed: () {
                          final page = int.tryParse(_pageController.text);
                          if (page != null && page >= 1 && page <= totalPages) {
                            _goToPage(page);
                          }
                        },
                        child: Text(
                          'Go',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Quick Pages', style: AppTypography.h3(theme.text)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _quickPages.map((page) {
                      return ActionChip(
                        label: Text('Page $page'),
                        backgroundColor: theme.surface,
                        side: BorderSide(color: theme.borderLight),
                        onPressed: () => _goToPage(page),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Green rounded header used on home and full-width screens.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.arabicLine,
    required this.title,
    this.subtitle,
  });

  final String arabicLine;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Text(
                arabicLine,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTheme.arabicText(
                  fontSize: 22,
                  lineHeight: 34,
                  color: AppColors.accentLight,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.h2(AppColors.textOnPrimary).copyWith(fontSize: 24),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabicText(
                    fontSize: 22,
                    lineHeight: 32,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// List screen header with optional back button (RTL: back on the right).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(
      Theme.of(context).brightness == Brightness.dark,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?trailing,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: AppTypography.h1(theme.text),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall(theme.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (showBack)
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
              color: AppColors.primary,
              tooltip: 'Back',
            ),
        ],
      ),
    );
  }
}

/// Dark toolbar for reader screens with back, title, and actions.
class ReaderToolbar extends StatelessWidget {
  const ReaderToolbar({
    super.key,
    required this.title,
    this.subtitle,
    this.counter,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final String? counter;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.accentLight, size: 22),
                tooltip: 'Back',
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTheme.translationText(
                        fontSize: 16,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: AppTheme.translationText(
                          fontSize: 13,
                          color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
              if (counter != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    counter!,
                    textDirection: TextDirection.rtl,
                    style: AppTheme.translationText(
                      fontSize: 13,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}

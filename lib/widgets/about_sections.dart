import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_info.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AuthenticityCard extends StatelessWidget {
  const AuthenticityCard({super.key, required this.theme});

  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Offline & Authentic', style: AppTypography.h3(AppColors.accent)),
          const SizedBox(height: 8),
          Text(
            AppInfo.authenticityNote,
            style: AppTypography.bodySmall(AppColors.textOnPrimary).copyWith(
              height: 1.4,
              color: AppColors.textOnPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class DeveloperNoteCard extends StatelessWidget {
  const DeveloperNoteCard({super.key, required this.theme});

  final AppThemeData theme;

  Future<void> _openDeveloperSite() async {
    final uri = Uri.parse(AppInfo.developerUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Developer', style: AppTypography.h3(theme.text)),
          const SizedBox(height: 8),
          Text(
            'Developed by',
            style: AppTypography.bodySmall(theme.textSecondary),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _openDeveloperSite,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                AppInfo.developerName,
                style: AppTypography.h3(AppColors.primary).copyWith(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppInfo.developerUrl,
            style: AppTypography.caption(theme.textMuted),
          ),
        ],
      ),
    );
  }
}

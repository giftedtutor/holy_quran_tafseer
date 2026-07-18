import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../services/urdu_quran_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.prefs});

  final PreferencesService prefs;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _error;
  String _status = 'Loading...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() => _status = 'Loading preferences...');
      await widget.prefs.load();
      setState(() => _status = 'Loading Urdu translation and tafseer...');
      await UrduQuranService.instance.load();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AppShell(prefs: widget.prefs)),
      );
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.menu_book,
                            color: AppColors.accent,
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Quran Tafseer & Translation',
                    style: AppTypography.h2(AppColors.accentLight).copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'التفسير والترجمة',
                    textDirection: TextDirection.rtl,
                    style: AppTheme.arabicText(
                      fontSize: 22,
                      lineHeight: 32,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _status,
                    style: AppTypography.bodySmall(
                      AppColors.textOnPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

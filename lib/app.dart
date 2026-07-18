import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_info.dart';
import 'screens/splash_screen.dart';
import 'services/preferences_service.dart';
import 'theme/app_theme.dart';

class HolyQuranTafseerApp extends StatelessWidget {
  HolyQuranTafseerApp({super.key});

  final _prefs = PreferencesService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _prefs,
      builder: (context, _) {
        return MaterialApp(
          title: AppInfo.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.materialTheme(false),
          darkTheme: AppTheme.materialTheme(true),
          themeMode: _prefs.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: const Locale('en'),
          supportedLocales: const [Locale('ur'), Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => child ?? const SizedBox.shrink(),
          home: SplashScreen(prefs: _prefs),
        );
      },
    );
  }
}

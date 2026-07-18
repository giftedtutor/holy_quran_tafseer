import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import 'bookmarks_screen.dart';
import 'home_screen.dart';
import 'juz_screen.dart';
import 'settings_screen.dart';
import 'surahs_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.prefs});

  final PreferencesService prefs;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (_index == index) return;
    setState(() => _index = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.prefs,
      builder: (context, _) {
        final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _index = index),
            children: [
              HomeScreen(
                prefs: widget.prefs,
                onSelectTab: _selectTab,
              ),
              SurahsScreen(prefs: widget.prefs),
              JuzScreen(prefs: widget.prefs),
              BookmarksScreen(prefs: widget.prefs),
              SettingsScreen(prefs: widget.prefs),
            ],
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.borderLight)),
            ),
            child: Transform.translate(
              offset: Platform.isAndroid ? Offset.zero : const Offset(0, 8),
              child: NavigationBar(
                height: 56,
                selectedIndex: _index,
                onDestinationSelected: _selectTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: 'Surahs',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.library_books_outlined),
                    selectedIcon: Icon(Icons.library_books),
                    label: 'Juz',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark_outline),
                    selectedIcon: Icon(Icons.bookmark),
                    label: 'Bookmarks',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Settings',
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

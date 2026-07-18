import 'package:flutter/material.dart';

Route<T> appPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

Future<T?> pushPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(appPageRoute<T>(page));
}

@Deprecated('Use pushPage instead')
Future<T?> pushRtl<T>(BuildContext context, Widget page) => pushPage(context, page);

@Deprecated('Use appPageRoute instead')
Route<T> rtlPageRoute<T>(Widget page) => appPageRoute(page);

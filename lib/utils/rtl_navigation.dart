import 'package:flutter/material.dart';

Route<T> rtlPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

Future<T?> pushRtl<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(rtlPageRoute<T>(page));
}

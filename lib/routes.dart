import 'package:flutter/material.dart';

PageRoute<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
      FadeTransition(opacity: animation, child: child),
  transitionDuration: const Duration(milliseconds: 280),
);

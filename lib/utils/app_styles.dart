// lib/utils/app_styles.dart
import 'package:flutter/material.dart';

class AppStyles {
  static BoxShadow bottomBarShadow = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 10,
    offset: const Offset(0, -5),
  );

  static BoxDecoration bottomBarItemDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: Colors.transparent,
  );
}
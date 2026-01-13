import 'package:flutter/material.dart';
import 'package:hassankamran/styles/app_text_styles.dart';

enum FormFactorType { mobile, tablet, desktop }

extension StyledContext on BuildContext {
  FormFactorType get formFactor {
    final width = MediaQuery.of(this).size.width;
    if (width >= 1024) {
      return FormFactorType.desktop;
    } else if (width >= 600) {
      return FormFactorType.tablet;
    } else {
      return FormFactorType.mobile;
    }
  }

  bool get isMobile => formFactor == FormFactorType.mobile;
  bool get isTablet => formFactor == FormFactorType.tablet;
  bool get isDesktop => formFactor == FormFactorType.desktop;

  /// Returns a scale factor based on screen width for responsive sizing
  /// Base width is 2560px (2K resolution). Returns 1.0 for 2K, 0.8 for 1080p
  double get responsiveScale {
    if (isMobile) return 1.0; // Don't scale mobile
    final width = MediaQuery.of(this).size.width;
    // Base width: 2560px (2K). At 1920px (1080p), scale is ~0.75
    // We clamp between 0.75 and 1.0 to ensure reasonable scaling
    return (width / 2560).clamp(0.75, 1.0);
  }

  AppTextStyle get textStyle {
    switch (formFactor) {
      case FormFactorType.mobile:
        return SmallTextStyles();
      case FormFactorType.tablet:
      case FormFactorType.desktop:
        return LargeTextStyles();
    }
  }
}

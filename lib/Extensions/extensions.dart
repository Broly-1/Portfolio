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

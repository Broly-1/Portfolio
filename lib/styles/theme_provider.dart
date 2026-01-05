import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Single theme color - Mocha
  static const Color mochaBackgroundColor = Color(0xFF1E1E2E);

  // Accent colors - matching the image
  static const List<Color> accentColors = [
    Color(0xFFE5C1CD), // Pink
    Color(0xFFCBA6F7), // Purple
    Color(0xFFF38BA8), // Red
    Color(0xFFEBA0AC), // Light Red
    Color(0xFFFAB387), // Peach
    Color(0xFFF9E2AF), // Yellow
    Color(0xFFA6E3A1), // Green
    Color(0xFF94E2D5), // Teal
    Color(0xFF89DCEB), // Sky
    Color(0xFF74C7EC), // Sapphire
    Color(0xFF89B4FA), // Blue
    Color(0xFFB4BEFE), // Lavender
  ];

  Color _accentColor = const Color(0xFFC6A0F6);
  bool _backgroundEffect = true;

  String get selectedTheme => 'Mocha'; // Always Mocha
  Color get accentColor => _accentColor;
  bool get backgroundEffect => _backgroundEffect;
  Color get themeBackgroundColor => mochaBackgroundColor;

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }

  void toggleBackgroundEffect() {
    _backgroundEffect = !_backgroundEffect;
    notifyListeners();
  }
}

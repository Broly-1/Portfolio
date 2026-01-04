import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AppColors {
  static const primaryColor = Color.fromARGB(255, 108, 108, 211);
  static const darkBackgroundColor = Color.fromARGB(255, 0, 0, 0);
  static const lightBackgroundColor = Color.fromARGB(255, 241, 239, 239);
  static const gray = MaterialColor(100, <int, Color>{
    50: Color.fromARGB(255, 250, 250, 250),
    100: Color.fromARGB(255, 245, 245, 245),
    200: Color.fromARGB(255, 230, 230, 230),
    300: Color.fromARGB(255, 200, 200, 200),
    400: Color.fromARGB(255, 170, 170, 170),
    500: Color.fromARGB(255, 130, 130, 130),
    600: Color.fromARGB(255, 100, 100, 100),
    700: Color.fromARGB(255, 70, 70, 70),
    800: Color.fromARGB(255, 50, 50, 50),
    900: Color.fromARGB(255, 30, 30, 30),
  });
}

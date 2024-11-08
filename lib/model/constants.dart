import 'package:flutter/material.dart';

/// To Access the property of [ColorTheme]
/// Whenever a Color property is needed,
/// Use the keyword [ColorTheme] then
/// intellisense will provide the values for you
/// 
/// e.g ColorTheme.secondaryColor 
///   = Color(0xffF6FCDF)
 class ColorTheme {
  static const Color primaryColor = Color(0xff859F3D);
  static const Color secondaryColor = Color(0xffF6FCDF);
  static const Color accentColor = Color(0xff31511E);

  /// To access the [textColor] property
  /// use the keyword [textColor] then
  /// together with a key
  /// e.g textColor['option 1']
  /// 
  /// selections:
  /// * option 1 Color(0xff1A1A19) (Almost Black)
  /// * option 2 Color(0xfff5f5f5) (WhiteSmoke)
  static const Map<String, Color> textColor = {
    'option 1' :  Color(0xff1A1A19),
    'option 2' :  Color(0xfff5f5f5)
  };
}
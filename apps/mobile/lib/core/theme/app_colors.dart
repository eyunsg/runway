import 'package:flutter/material.dart';

abstract final class AppColors {
  static Highlight highlight = Highlight();
  static Natural natural = Natural();
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
}

class Highlight {
  final Color dark = Color(0xFF3B495E);
  final Color medium = Color(0xFF3F5E91);
  final Color light = Color(0xFF2D68C4);
}

class Natural {
  final Text text = Text();
  final Background background = Background();
}

class Text {
  final Color primary = Color(0xFFE7EEF4);
  final Color secondary = Color(0xFFB2B8BD);
  final Color disabled = Color(0xFF7B8083);
}

class Background {
  final Color primary = Color(0xFF272C33);
  final Color secondary = Color(0xFF2A2E33);
}

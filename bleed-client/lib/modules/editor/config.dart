import 'package:flutter/services.dart';


class EditorConfig {
  final _Keys keys = _Keys();
  final int defaultStartTime = 12;
}

class _Keys {
  final selectTileType = LogicalKeyboardKey.keyQ;
  final pan = LogicalKeyboardKey.space;
  final move = LogicalKeyboardKey.keyG;
}

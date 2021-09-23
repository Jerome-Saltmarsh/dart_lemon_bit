import 'dart:ui';

import 'package:bleed_client/rects.dart';
import 'package:bleed_client/state.dart';

// interface
Rect get rectHealth => _rectsHealth[drawFrame % _healthFrames];

// private
const double _frameWidth = 47;
const double _frameHeight = 71;

final List<Rect> _rectsHealth = _itemFrames([5, 5, 6, 6, 7, 7, 8, 8, 7, 7]);
final int _healthFrames = _rectsHealth.length;

List<Rect> _itemFrames(List<int> indexes){
  return indexes.map(_itemFrame).toList();
}

Rect _itemFrame(int index){
  return rect(index, _frameWidth, _frameHeight);
}

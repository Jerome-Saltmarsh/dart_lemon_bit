import 'dart:ui';

import 'package:bleed_client/rects.dart';
import 'package:bleed_client/state.dart';

// interface
Rect get rectHealth => _rectsHealth[drawFrame % _healthFrames];

// private
const double _frameWidth = 48;
const double _frameHeight = 72;

List<Rect> _rectsHealth = _itemFrames([1, 1, 2, 2]);
int _healthFrames = _rectsHealth.length;

List<Rect> _itemFrames(List<int> indexes){
  return indexes.map(_itemFrame).toList();
}

Rect _itemFrame(int index){
  return rect(index, _frameWidth, _frameHeight);
}

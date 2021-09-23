import 'dart:ui';

import 'package:bleed_client/rects.dart';
import 'package:bleed_client/state.dart';

// interface
Rect get rectHealth => _rectsHealth[drawFrame % 3];

// private
double _frameWidth = 48;
double _frameHeight = 72;

List<Rect> _rectsHealth = _itemFrames([1, 2, 3]);

List<Rect> _itemFrames(List<int> indexes){
  return indexes.map(_itemFrame).toList();
}

Rect _itemFrame(int index){
  return rect(index, _frameWidth, _frameHeight);
}

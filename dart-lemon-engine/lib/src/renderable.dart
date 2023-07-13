
import 'dart:typed_data';
import 'dart:ui';

abstract class Renderable {
  Float32List get src;
  Float32List get dst;
  Int32List? get colors;
  BlendMode? get blendMode;
}
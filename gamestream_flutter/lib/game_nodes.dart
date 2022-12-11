
import 'dart:typed_data';

import 'enums/visibility.dart';

class GameNodes {
  static const nodesInitialSize = 0;
  static var nodesBake = Uint8List(nodesInitialSize);
  static var nodesColor = Int32List(nodesInitialSize);
  static var nodesOrientation = Uint8List(nodesInitialSize);
  static var nodesShade = Uint8List(nodesInitialSize);
  static var nodesTotal = nodesInitialSize;
  static var nodesType = Uint8List(nodesInitialSize);
  static var nodesVariation = List<bool>.generate(nodesInitialSize, (index) => false, growable: false);
  static var nodesVisible = Uint8List(nodesInitialSize);
  static var nodesVisibleIndex = Uint16List(nodesInitialSize);
  static var nodesDynamicIndex = Uint16List(nodesInitialSize);
  static var nodesWind = Uint8List(nodesInitialSize);

  static var visibleIndex = 0;


  static void addInvisibleIndex(int index){
    nodesVisible[index] = Visibility.Transparent;
    nodesVisibleIndex[visibleIndex] = index;
    visibleIndex++;
  }

  static void addTransparentIndex(int index){
    nodesVisible[index] = Visibility.Transparent;
    nodesVisibleIndex[visibleIndex] = index;
    visibleIndex++;
  }
}

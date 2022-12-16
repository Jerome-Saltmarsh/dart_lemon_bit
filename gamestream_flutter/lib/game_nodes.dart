
import 'package:gamestream_flutter/library.dart';

class GameNodes {
  static const Nodes_Initial_Size = 0;

  static var nodesBake = Uint8List(Nodes_Initial_Size);
  static var nodesColor = Int32List(Nodes_Initial_Size);
  static var nodesOrientation = Uint8List(Nodes_Initial_Size);
  static var nodesShade = Uint8List(Nodes_Initial_Size);
  static var nodesTotal = Nodes_Initial_Size;
  static var nodesType = Uint8List(Nodes_Initial_Size);
  static var nodesVariation = List<bool>.generate(Nodes_Initial_Size, (index) => false, growable: false);
  static var nodesVisible = Uint8List(Nodes_Initial_Size);
  static var nodesVisibleIndex = Uint16List(Nodes_Initial_Size);
  static var nodesDynamicIndex = Uint16List(Nodes_Initial_Size);
  static var nodesWind = Uint8List(Nodes_Initial_Size);
  static var visibleIndex = 0;
  static var dynamicIndex = 0;

  // METHODS

  static void addInvisibleIndex(int index){
    if (nodesVisible[index] == Visibility.Transparent) return;
    nodesVisible[index] = Visibility.Invisible;
    nodesVisibleIndex[visibleIndex] = index;
    visibleIndex++;
  }

  static void addTransparentIndex(int index){
    if (nodesVisible[index] == Visibility.Transparent) return;
    nodesVisible[index] = Visibility.Transparent;
    nodesVisibleIndex[visibleIndex] = index;
    visibleIndex++;
  }

  static void resetGridToAmbient(){
    for (var i = 0; i < GameNodes.nodesTotal; i++){
      nodesBake[i] = Shade.Pitch_Black;
      nodesShade[i] = Shade.Pitch_Black;
      dynamicIndex = 0;
    }
  }
}

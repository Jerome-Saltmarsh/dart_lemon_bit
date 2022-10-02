
import 'dart:typed_data';

import '../classes/library.dart';

Scene generateEmptyScene(){
  return Scene(
    name: '',
    gameObjects: [],
    gridHeight: 8,
    gridColumns: 50,
    gridRows: 50,
    nodeTypes: Uint8List(0), /// TODO
    nodeOrientations: Uint8List(0), /// TODO
  );
}
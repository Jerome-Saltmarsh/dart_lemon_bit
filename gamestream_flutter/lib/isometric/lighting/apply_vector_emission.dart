
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

void applyVector3Emission(Vector3 v, {required int maxBrightness, int radius = 5}){
  applyEmissionDynamic(
      zIndex: v.indexZ,
      rowIndex: v.indexRow,
      columnIndex: v.indexColumn,
      maxBrightness: maxBrightness,
      radius: radius,
  );
}
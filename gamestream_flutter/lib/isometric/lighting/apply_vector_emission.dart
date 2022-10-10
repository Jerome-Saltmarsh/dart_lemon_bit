
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';

void applyVector3Emission(Vector3 v, {required int maxBrightness}){
  if (!inBoundsVector3(v)) return;
  applyEmissionDynamic(
      index: gridNodeIndexVector3(v),
      maxBrightness: maxBrightness,
  );
}
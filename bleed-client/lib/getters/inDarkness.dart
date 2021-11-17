
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';

bool inDarkness(double x, double y){
  return getShadeAtPosition(x, y).index >= Shade.VeryDark.index;
}
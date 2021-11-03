
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/getters/getShading.dart';

bool inDarkness(double x, double y){
  return getShadeAtPosition(x, y) == Shading.VeryDark;
}
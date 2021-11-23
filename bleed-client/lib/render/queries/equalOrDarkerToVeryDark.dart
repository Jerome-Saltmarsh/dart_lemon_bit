import 'package:bleed_client/common/enums/Shade.dart';

bool equalOrDarkerToVeryDark(Shade shade){
  return shade.index >= Shade.VeryDark.index;
}
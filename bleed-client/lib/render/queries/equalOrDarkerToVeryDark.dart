import 'package:bleed_client/common/enums/Shade.dart';

bool equalOrDarkerToVeryDark(int shade){
  return shade >= Shade_VeryDark;
}
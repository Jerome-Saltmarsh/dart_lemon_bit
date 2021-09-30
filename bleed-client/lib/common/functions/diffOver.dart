
import 'package:bleed_client/common/functions/diff.dart';

bool diffOver(num a, num b, num over){
  return diff(a, b) > over;
}
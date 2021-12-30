
import 'package:lemon_math/randomItem.dart';

import '../common/CollectableType.dart';

CollectableType get randomCollectableType => randomItem(CollectableType.values);

const secondsPerMinute = 60;
const minutesPerHour = 60;

int calculateTime({int minute = 0, int hour = 0}){
  return secondsPerMinute * minutesPerHour * hour + minute;
}
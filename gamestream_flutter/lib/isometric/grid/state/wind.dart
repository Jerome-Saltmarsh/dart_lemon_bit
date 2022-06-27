import 'package:gamestream_flutter/isometric/events/on_wind_changed.dart';
import 'package:lemon_watch/watch.dart';

var windIsCalm = true;

final wind = Watch(Wind.Calm, onChanged: onWindChanged);

set windIndex(int value){
  assert(value >= 0);
  wind.value = value % 3;
}

void toggleWind(){
  wind.value = (wind.value + 1) % 3;
}

class Wind {
  static const Calm = 0;
  static const Gentle = 1;
  static const Strong = 2;
}
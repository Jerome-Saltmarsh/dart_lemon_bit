import 'package:gamestream_flutter/isometric/events/on_wind_changed.dart';
import 'package:lemon_watch/watch.dart';

final wind = Watch(Wind.Calm, onChanged: onWindChanged);

set windIndex(int value){
  assert(value >= 0);
  wind.value = windValues[value % windValues.length];
}

int get windIndex => wind.value.index;

final windValues = Wind.values;

void toggleWind(){
  windIndex++;
}

enum Wind {
  Calm,
  Gentle,
  Strong,
}
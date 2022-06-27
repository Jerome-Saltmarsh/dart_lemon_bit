import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:lemon_watch/watch.dart';

final wind = Watch(Wind.None, onChanged: (value){
  value == Wind.None ? audio.windStrongStop() : audio.windStrongStart();
});

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
  None,
  Weak,
  Strong,
}
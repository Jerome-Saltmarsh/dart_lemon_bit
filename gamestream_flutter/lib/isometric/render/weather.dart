import 'package:gamestream_flutter/isometric/events/on_rain_changed.dart';
import 'package:lemon_watch/watch.dart';


var raining = false;

var rainingWatch = Watch(false, onChanged: (value){
  raining = value;
  onRainChanged(value);
});

void toggleRaining(){
   rainingWatch.value = !rainingWatch.value;
}

void rainingStop(){
   rainingWatch.value = false;
}
import 'package:bleed_common/Rain.dart';
import 'package:gamestream_flutter/isometric/events/on_rain_changed.dart';
import 'package:lemon_watch/watch.dart';


var rainingWatch = Watch(Rain.None, onChanged: (value){
  onRainChanged(value);
});

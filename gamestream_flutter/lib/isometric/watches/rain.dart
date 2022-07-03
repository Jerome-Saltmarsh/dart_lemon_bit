import 'package:bleed_common/Rain.dart';
import 'package:gamestream_flutter/isometric/events/on_rain_changed.dart';
import 'package:lemon_watch/watch.dart';


final rain = Watch(Rain.None, onChanged: onRainChanged);

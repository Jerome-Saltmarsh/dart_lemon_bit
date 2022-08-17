import 'package:bleed_common/rain.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_rain.dart';
import 'package:lemon_watch/watch.dart';

final rain = Watch(Rain.None, onChanged: onChangedRain);

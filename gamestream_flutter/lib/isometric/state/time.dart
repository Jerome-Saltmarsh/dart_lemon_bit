import 'package:gamestream_flutter/events/on_hour_changed.dart';
import 'package:lemon_watch/watch.dart';

final hours = Watch(0, onChanged: onHourChanged);
final minutes = Watch(0);
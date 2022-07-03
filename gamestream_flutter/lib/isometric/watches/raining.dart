import 'package:gamestream_flutter/isometric/events/on_raining_changed.dart';
import 'package:lemon_watch/watch.dart';

final raining = Watch(false, onChanged: onRainingChanged);

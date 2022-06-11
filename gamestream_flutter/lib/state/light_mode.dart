import 'package:gamestream_flutter/state/grid.dart';
import 'package:lemon_watch/watch.dart';

final lightModeRadial = Watch(false, onChanged: (bool value){
  refreshLighting();
});
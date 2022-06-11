import 'package:gamestream_flutter/actions/refresh_lighting.dart';
import 'package:lemon_watch/watch.dart';

final lightModeRadial = Watch(false, onChanged: (bool value){
  refreshLighting();
});
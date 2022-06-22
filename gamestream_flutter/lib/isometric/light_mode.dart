import 'package:lemon_watch/watch.dart';

import 'grid.dart';

final lightModeRadial = Watch(true, onChanged: (bool value){
  refreshLighting();
});
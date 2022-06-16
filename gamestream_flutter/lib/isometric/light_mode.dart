import 'package:lemon_watch/watch.dart';

import 'grid.dart';

final lightModeRadial = Watch(false, onChanged: (bool value){
  refreshLighting();
});
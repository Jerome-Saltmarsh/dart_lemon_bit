import 'package:bleed_common/lightning.dart';
import 'package:lemon_watch/watch.dart';

import '../state/next_lightning.dart';

final lightning = Watch(Lightning.Off, onChanged: (Lightning value){
   if (value != Lightning.Off){
     nextLightning = 0;
   }
});

bool get lightningOn => lightning.value != Lightning.Off;

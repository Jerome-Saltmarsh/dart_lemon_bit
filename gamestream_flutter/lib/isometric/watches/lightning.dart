import 'package:bleed_common/lightning.dart';
import 'package:gamestream_flutter/isometric/variables/next_lightning.dart';
import 'package:lemon_watch/watch.dart';


final lightning = Watch(Lightning.Off, onChanged: (Lightning value){
   if (value != Lightning.Off){
     nextLightning = 0;
   }
});

bool get lightningOn => lightning.value != Lightning.Off;

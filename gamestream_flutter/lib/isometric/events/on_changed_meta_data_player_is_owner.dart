import 'package:gamestream_flutter/isometric/play_mode.dart';

void onChangedMetaDataPlayerIsOwner(bool playerIsOwner){
   if (!playerIsOwner){
     setPlayModePlay();
   }
}

import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/player.dart';

void onChangedMapX(int value){
   cameraSetPosition(player.x, player.y);
   cameraCenterOnPlayer();
}

void onChangedMapY(int value){
  cameraSetPosition(player.x, player.y);
  cameraCenterOnPlayer();
}
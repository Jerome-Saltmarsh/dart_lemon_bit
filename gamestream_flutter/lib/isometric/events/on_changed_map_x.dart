
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:lemon_engine/engine.dart';

void onChangedMapX(int value){
   cameraCenterOnPlayer();
   // engine.camera.x -= 100;
   // engine.camera.y -= 100;


}

void onChangedMapY(int value){
  cameraCenterOnPlayer();
}
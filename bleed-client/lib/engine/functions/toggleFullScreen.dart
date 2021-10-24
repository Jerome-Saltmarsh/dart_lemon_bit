import 'package:bleed_client/engine/functions/fullscreenExit.dart';
import 'package:bleed_client/engine/properties/fullScreenActive.dart';

import 'fullscreenEnter.dart';

void toggleFullScreen(){
  if(fullScreenActive){
    fullScreenExit();
  }else{
    fullScreenEnter();
  }
}
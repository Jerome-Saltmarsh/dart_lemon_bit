
import 'package:gamestream_flutter/library.dart';

class ClientEvents {
  static void onInventoryReadsChanged(int value){
    ClientActions.windowCloseInventoryInformation();
  }

  static void onChangedAttributesWindowVisible(bool value){
    GameAudio.click_sound_8(1);
  }
}
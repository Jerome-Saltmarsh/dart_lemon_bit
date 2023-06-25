
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_actions.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricIO {

  var Key_Inventory          = KeyCode.I;
  var Key_Zoom               = KeyCode.F;
  var Key_Settings           = KeyCode.Digit_0;
  var Key_Duplicate          = KeyCode.V;
  var Key_Auto_Attack        = KeyCode.Space;
  var Key_Message            = KeyCode.Enter;
  var Key_Toggle_Debug_Mode  = KeyCode.P;
  var Key_Toggle_Map         = KeyCode.M;
  var Mouse_Translation_Sensitivity = 0.1;


  void onKeyPressedModePlay(int key) {
    if (key == Key_Zoom) {
      gamestream.isometric.toggleZoom();
      return;
    }
  }
}
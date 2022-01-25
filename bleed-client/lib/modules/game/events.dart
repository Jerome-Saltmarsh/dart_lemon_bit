

import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/render/functions/applyDynamicShadeToTileSrc.dart';
import 'package:bleed_client/render/functions/resetDynamicShadesToBakeMap.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';
import 'package:lemon_engine/engine.dart';

import '../../modules.dart';

class GameEvents {
  void register(){
    print("modules.game.events.register()");
    engine.callbacks.onLeftClicked = performPrimaryAction;
    engine.callbacks.onPanStarted = performPrimaryAction;
    engine.callbacks.onLongLeftClicked = performPrimaryAction;
    modules.game.state.ambientLight.onChanged(onAmbientLightChanged);
    registerPlayKeyboardHandler();
  }

  void onAmbientLightChanged(Shade value){
    print("onAmbientLightChanged($value)");
    setBakeMapToAmbientLight();
    resetDynamicShadesToBakeMap();
    applyDynamicShadeToTileSrc();
    modules.game.actions.applyEnvironmentObjectsToBakeMapping();
  }
}
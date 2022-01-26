import 'package:bleed_client/common/enums/Shade.dart';

import '../../modules.dart';

class IsometricEvents {

  void register(){
    print("isometric.events.register()");
    modules.isometric.subscriptions.onAmbientLightChanged = modules.isometric.state.ambient.onChanged(_onAmbientShadeChanged);
  }

  void _onAmbientShadeChanged(Shade value){
    print("isometric.events.onAmbientLightChanged($value)");
    modules.isometric.actions.setBakeMapToAmbientLight();
    modules.isometric.actions.setDynamicMapToAmbientLight();
    modules.isometric.actions.resetDynamicShadesToBakeMap();
    modules.isometric.actions.applyDynamicShadeToTileSrc();
    modules.isometric.actions.applyEnvironmentObjectsToBakeMapping();
  }
}
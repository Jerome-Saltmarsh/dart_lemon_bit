

import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/functions/applyDynamicShadeToTileSrc.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';

import '../../modules.dart';
import 'subscriptions.dart';

class IsometricEvents {

  IsometricSubscriptions get _subscriptions => modules.isometric.subscriptions;

  void register(){
    print("isometric.events.register()");
    _subscriptions.onAmbientLightChanged = modules.isometric.state.ambientLight.onChanged(_onAmbientLightChanged);
  }

  void _onAmbientLightChanged(Shade value){
    print("isometric.events.onAmbientLightChanged($value)");
    modules.isometric.actions.setBakeMapToAmbientLight();
    modules.isometric.actions.resetDynamicShadesToBakeMap();
    applyDynamicShadeToTileSrc();
    modules.isometric.actions.applyEnvironmentObjectsToBakeMapping();
  }
}
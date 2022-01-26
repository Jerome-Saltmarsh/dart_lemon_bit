import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/state/game.dart';

Shade get _maxShade => game.shadeMax.value;

set ambient(Shade value) {
  if (value.isLighterThan(_maxShade)){
    modules.isometric.state.ambient.value = _maxShade;
    return;
  }
  modules.isometric.state.ambient.value = value;
}


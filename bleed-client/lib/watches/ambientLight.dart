import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/state/game.dart';

Shade get ambient => modules.isometric.state.ambientLight.value;

Shade get _maxShade => game.shadeMax.value;

set ambient(Shade value) {
  if (value.isLighterThan(_maxShade)){
    modules.isometric.state.ambientLight.value = _maxShade;
    return;
  }
  modules.isometric.state.ambientLight.value = value;
}

observeAmbientLight(Function(Shade value) function) {
  modules.isometric.state.ambientLight.onChanged(function);
}

void setAmbientLightBright(){
  ambient = Shade.Bright;
}

void setAmbientLightMedium(){
  ambient = Shade.Medium;
}

void setAmbientLightDark(){
  ambient = Shade.Dark;
}

void setAmbientLightVeryDark(){
  ambient = Shade.VeryDark;
}

void setAmbientLightPitchBlack(){
  ambient = Shade.PitchBlack;
}

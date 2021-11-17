import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_watch/watch.dart';

Watch<Shade> _ambientLight = Watch(Shade.VeryDark);

Shade get ambient => _ambientLight.value;

Shade get _maxShade => game.shadeMax.value;

set ambient(Shade value) {
  if (value.isLighterThan(_maxShade)){
    _ambientLight.value = _maxShade;
    return;
  }
  _ambientLight.value = value;
}

observeAmbientLight(Function(Shade value) function) {
  _ambientLight.onChanged(function);
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

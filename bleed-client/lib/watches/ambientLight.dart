import 'package:bleed_client/enums/Shading.dart';
import 'package:lemon_watch/watch.dart';

Watch<Shade> _ambientLight = Watch(Shade.VeryDark);

Shade get ambientLight => _ambientLight.value;

set ambientLight(Shade value) {
  _ambientLight.value = value;
}

observeAmbientLight(Function(Shade value) function) {
  _ambientLight.onChanged(function);
}

void setAmbientLightBright(){
  ambientLight = Shade.Bright;
}

void setAmbientLightMedium(){
  ambientLight = Shade.Medium;
}

void setAmbientLightDark(){
  ambientLight = Shade.Dark;
}

void setAmbientLightVeryDark(){
  ambientLight = Shade.VeryDark;
}

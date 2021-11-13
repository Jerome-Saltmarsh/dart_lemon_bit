import 'package:bleed_client/enums/Shading.dart';
import 'package:lemon_watch/watch.dart';

Watch<Shade> _ambientLight = Watch(Shade.VeryDark);

Shade get ambientLight => _ambientLight.value;

set ambientLight(Shade value){
  _ambientLight.value = value;
}

Watch<Shade> get ambientLightWatch => _ambientLight;
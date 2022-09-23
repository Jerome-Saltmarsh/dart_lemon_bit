import 'package:bleed_common/control_scheme.dart';
import 'package:lemon_watch/watch.dart';

final gameOptions = GameOptions();

var drawTemplateWithoutWeapon = false;

class GameOptions {
  final controlScheme = Watch(ControlScheme.schemeA, onChanged: (int value){
    drawTemplateWithoutWeapon = value == ControlScheme.schemeA;
  });
}
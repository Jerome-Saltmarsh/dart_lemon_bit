

import 'package:bleed_common/control_scheme.dart';
import 'package:gamestream_flutter/isometric/render/renderCharacter.dart';

void onChangedControlScheme(int value){
  renderTemplateWithWeapon = value == ControlScheme.schemeB;
}
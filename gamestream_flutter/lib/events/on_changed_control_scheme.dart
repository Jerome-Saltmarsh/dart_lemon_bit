

import 'package:bleed_common/control_scheme.dart';
import 'package:gamestream_flutter/isometric/render/renderCharacter.dart';
import 'package:gamestream_flutter/isometric/ui/ui_state.dart';

void onChangedControlScheme(int value){
  renderTemplateWithWeapon = value == ControlScheme.schemeB;
  uiState.isVisibleControlsPlayerWeapons.value = value == ControlScheme.schemeA;
}
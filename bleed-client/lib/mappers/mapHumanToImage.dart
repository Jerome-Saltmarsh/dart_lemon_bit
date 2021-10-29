import 'dart:ui';

import 'package:bleed_client/enums.dart';

import '../images.dart';

Image mapCharacterStateToImageMan(CharacterState state){
  switch(state){
    case CharacterState.Running:
      return images.manRunning;
    case CharacterState.Firing:
      return images.manFiring;
    default:
      return images.man;
  }
}

import 'dart:ui';

import 'package:bleed_client/enums.dart';

import '../images.dart';

Image mapCharacterStateToImageMan(CharacterState state){
  switch(state){
    case CharacterState.Running:
      return images.manRunning;
    default:
      return images.man;
  }
}

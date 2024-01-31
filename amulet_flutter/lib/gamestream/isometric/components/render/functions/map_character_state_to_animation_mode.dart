
import 'package:amulet_engine/packages/isometric_engine/packages/common/src/isometric/character_state.dart';
import 'package:lemon_sprite/lib.dart';

int mapCharacterStateToAnimationMode(int characterState) =>
    switch (characterState) {
      CharacterState.Idle => AnimationMode.bounce,
      CharacterState.Running => AnimationMode.loop,
      _ => AnimationMode.single
    };
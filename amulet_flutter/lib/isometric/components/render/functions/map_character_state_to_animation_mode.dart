
import 'package:amulet_common/src.dart';
import 'package:lemon_sprite/lib.dart';

int mapCharacterStateToAnimationMode(int characterState) =>
    switch (characterState) {
      CharacterState.Idle => AnimationMode.bounce,
      CharacterState.Running => AnimationMode.loop,
      _ => AnimationMode.single
    };
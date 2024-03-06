
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/ui/functions/render_character_sprites.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:amulet_flutter/isometric/classes/human_character_sprites.dart';

void renderPlayerCharacterSprites({
  required IsometricPlayer player,
  required HumanCharacterSprites sprites,
  required Canvas canvas,
  required int row,
  required int column,
  required int characterState,
  required int color,
}) => renderCharacterSprites(
      canvas: canvas,
      sprites: sprites,
      row: row,
      column: column,
      characterState: characterState,
      gender: player.gender.value,
      helmType: player.helmType.value,
      headType: player.headType.value,
      armorType: player.armorType.value,
      shoeType: player.shoeType.value,
      hairType: player.hairType.value,
      weaponType: player.weaponType.value,
      skinColor: player.colors.palette[player.complexion.value].value,
      hairColor: player.colors.red_0.value,
      color: color,
  );

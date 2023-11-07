
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/ui/functions/render_canvas_character_sprites.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/gamestream/sprites/kid_character_sprites.dart';

void renderCanvasIsometricPlayer({
  required IsometricPlayer player,
  required KidCharacterSprites sprites,
  required Canvas canvas,
  required int row,
  required int column,
  required int characterState,
  required int color,
}) => renderCanvasCharacterSprites(
      canvas: canvas,
      sprites: sprites,
      row: row,
      column: column,
      characterState: characterState,
      gender: player.gender.value,
      helmType: player.helmType.value,
      headType: player.headType.value,
      bodyType: player.bodyType.value,
      shoeType: player.shoeType.value,
      legsType: player.legsType.value,
      hairType: player.hairType.value,
      weaponType: player.weaponType.value,
      skinColor: player.colors.palette[player.complexion.value].value,
      hairColor: player.colors.palette[player.hairColor.value].value,
      color: color,
  );

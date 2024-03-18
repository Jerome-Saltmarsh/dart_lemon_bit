
import 'package:amulet_client/isometric/classes/human_character_sprites.dart';
import 'package:flutter/rendering.dart';
import 'package:lemon_sprite/lib.dart';

import 'render_canvas_sprite.dart';

void renderCharacterSprites({
  required Canvas canvas,
  required HumanCharacterSprites sprites,
  required int row,
  required int column,
  required int characterState,
  required int gender,
  required int helmType,
  required int headType,
  required int armorType,
  required int shoeType,
  required int hairType,
  required int weaponType,
  required int skinColor,
  required int hairColor,
  required int color,
}) {
  final helm = sprites.helm[helmType]?.fromCharacterState(characterState);
  final head = sprites.head[headType]?.fromCharacterState(characterState) ?? (throw Exception());
  final armor = sprites.armor[armorType] ?.fromCharacterState(characterState);
  final torso = sprites.torso[gender]?.fromCharacterState(characterState) ?? (throw Exception());
  final shoes = sprites.shoes[shoeType]
      ?.fromCharacterState(characterState);
  final hair = sprites.hair[hairType]
      ?.fromCharacterState(characterState);
  final weapon = sprites.weapons[weaponType]
      ?.fromCharacterState(characterState);

  renderCanvasSprite(
    sprite: torso,
    canvas: canvas,
    row: row,
    column: column,
    color: skinColor,
    blendMode: BlendMode.modulate,
    animationMode: AnimationMode.single,
  );

  renderCanvasSprite(
    sprite: torso,
    canvas: canvas,
    row: row,
    column: column,
    color: color,
    blendMode: BlendMode.modulate,
    animationMode: AnimationMode.single,
  );


  if (shoes != null) {
    renderCanvasSprite(
      sprite: shoes,
      canvas: canvas,
      row: row,
      column: column,
      blendMode: BlendMode.dstATop,
      color: color,
      animationMode: AnimationMode.single,
    );
  }

  if (armor != null) {
    renderCanvasSprite(
      sprite: armor,
      canvas: canvas,
      row: row,
      column: column,
      blendMode: BlendMode.dstATop,
      color: color,
      animationMode: AnimationMode.single,
    );
  }

  renderCanvasSprite(
    sprite: head,
    canvas: canvas,
    row: row,
    column: column,
    color: skinColor,
    blendMode: BlendMode.modulate,
    animationMode: AnimationMode.single,
  );

  renderCanvasSprite(
    sprite: head,
    canvas: canvas,
    row: row,
    column: column,
    color: color,
    blendMode: BlendMode.modulate,
    animationMode: AnimationMode.single,
  );

  if (hair != null){
    renderCanvasSprite(
      sprite: hair,
      canvas: canvas,
      row: row,
      column: column,
      color: hairColor,
      blendMode: BlendMode.modulate,
      animationMode: AnimationMode.single,
    );

    renderCanvasSprite(
      sprite: hair,
      canvas: canvas,
      row: row,
      column: column,
      color: color,
      blendMode: BlendMode.modulate,
      animationMode: AnimationMode.single,
    );
  }

  if (helm != null){
    renderCanvasSprite(
      sprite: helm,
      canvas: canvas,
      row: row,
      column: column,
      blendMode: BlendMode.dstATop,
      color: color,
      animationMode: AnimationMode.single,
    );
  }

  if (weapon != null){
    renderCanvasSprite(
      sprite: weapon,
      canvas: canvas,
      row: row,
      column: column,
      blendMode: BlendMode.dstATop,
      color: color,
      animationMode: AnimationMode.single,
    );
  }

}

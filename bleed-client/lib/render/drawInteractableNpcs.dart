import 'package:bleed_client/classes/InteractableNpc.dart';
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/functions/diffOver.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/engine/functions/drawText.dart';
import 'package:bleed_client/engine/properties/mouseWorld.dart';
import 'package:bleed_client/engine/render/drawAtlas.dart';
import 'package:bleed_client/render/drawCanvas.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/mappers/mapHumanToRect.dart';
import 'package:bleed_client/state.dart';

void drawInteractableNpcs() {
  render.npcs.rects.clear();
  render.npcs.transforms.clear();

  for (int i = 0; i < compiledGame.totalNpcs; i++) {
    InteractableNpc interactableNpc = compiledGame.interactableNpcs[i];
    render.npcs.transforms.add(
        mapHumanToRSTransform(interactableNpc.x, interactableNpc.y)
    );

    render.npcs.rects.add(
        mapHumanToRect(
            Weapon.HandGun,
            interactableNpc.state,
            interactableNpc.direction,
            interactableNpc.frame
        )
    );

    if (diffOver(interactableNpc.x, mouseWorldX, 50)) continue;
    if (diffOver(interactableNpc.y, mouseWorldY, 50)) continue;
    drawText(compiledGame.interactableNpcs[i].name, interactableNpc.x - charWidth * compiledGame.interactableNpcs[i].name.length,
        interactableNpc.y);
  }

  drawAtlas(images.human, render.npcs.transforms, render.npcs.rects);
}

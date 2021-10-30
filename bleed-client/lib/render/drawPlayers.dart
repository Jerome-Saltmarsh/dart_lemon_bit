

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/engine/render/drawAtlas.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/mappers/mapHumanToRect.dart';
import 'package:bleed_client/state.dart';

void drawPlayers() {
  render.playersTransforms.clear();
  render.playersRects.clear();
  for (int i = 0; i < compiledGame.totalHumans; i++) {
    Character player = compiledGame.humans[i];
    render.playersTransforms.add(
        mapHumanToRSTransform(player.x, player.y)
    );
    render.playersRects.add(
        mapHumanToRect(player.weapon, player.state, player.direction, player.frame)
    );
  }
  drawAtlas(images.human, render.playersTransforms, render.playersRects);
}
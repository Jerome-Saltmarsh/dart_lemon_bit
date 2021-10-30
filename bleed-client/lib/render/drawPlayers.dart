

import 'package:bleed_client/classes/Human.dart';
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
    Human human = compiledGame.humans[i];
    render.playersTransforms.add(
        mapHumanToRSTransform(human.x, human.y)
    );
    render.playersRects.add(
        mapHumanToRect(human.weapon, human.state, human.direction, human.frame)
    );
  }
  drawAtlas(images.human, render.playersTransforms, render.playersRects);
}
import 'package:bleed_client/engine/render/drawAtlas.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/mappers/mapCrateToRSTransform.dart';
import 'package:bleed_client/rects.dart';
import 'package:bleed_client/render/state/crates.dart';

void drawCrates() {
  crates.rects.clear();
  crates.transforms.clear();
  for (int i = 0; i < game.cratesTotal; i++) {
    crates.transforms
        .add(mapCrateToRSTransform((game.crates[i])));
    crates.rects.add(rectCrate);
  }
  drawAtlas(images.crate, crates.transforms, crates.rects);
}

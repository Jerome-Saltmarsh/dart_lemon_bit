
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:lemon_engine/engine.dart';

class IsometricRender {

  void drawTiles() {
    engine.actions.setPaintColorWhite();
    drawAtlas(
      dst: modules.isometric.state.tilesDst,
      src: modules.isometric.state.tilesSrc,
    );
  }

}
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/applyShade.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/render/functions/applyLightArea.dart';
import 'package:bleed_client/getters/getTileAt.dart';

void applyLightBright(List<List<Shading>> shader, double x, double y) {
  applyLightArea(shader, x, y, 7, Shading.Dark);
  applyLightArea(shader, x, y, 4, Shading.Medium);
  applyLightArea(shader, x, y, 2, Shading.Bright);
}

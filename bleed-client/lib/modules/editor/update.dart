import 'package:bleed_client/update.dart';
import 'package:lemon_engine/engine.dart';

void updateEditor() {
  updateZoom();
  engine.actions.redrawCanvas();
}

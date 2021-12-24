import 'dart:ui';

import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/editor/render/drawEditor.dart';
import 'package:bleed_client/network.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/watches/mode.dart';

void drawCanvas(Canvas canvass, Size _size) {
  if (editMode) {
    renderCanvasEdit();
    return;
  }

  if (game.type.value == GameType.None) return;
  if (!connected) return;
  if (game.player.uuid.value.isEmpty) return;
  if (game.status.value != GameStatus.In_Progress) return;
  renderGame();
}
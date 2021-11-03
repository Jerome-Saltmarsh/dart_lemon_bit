import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/state/editState.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:flutter/material.dart';

Widget buildTiles() {
  return Column(
      children: Tile.values.map((tile) {
        return button(tile.toString(), () {
          tool = EditTool.Tile;
          editState.tile = tile;
        });
      }).toList());
}

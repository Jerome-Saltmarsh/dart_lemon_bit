import 'package:bleed_common/grid_node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/edit_state.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildMapEditor() {
  return Stack(
    children: [
      Column(
        children: [
          Container(
            width: 200,
            height: 50,
            color: Colors.white60,
            child: text('FIll', onPressed: () {
              // sendClientRequestSetBlock(edit.row, edit.column, edit.z, value);
              for (var z = 0; z < edit.z; z++){
                sendClientRequestSetBlock(edit.row, edit.column, z, edit.type.value);
              }

            }),
          ),
          Container(
            width: 200,
            height: 50,
            color: Colors.white60,
            child: text('Mode', onPressed: () {
              isometric.render.lowerTileMode = !isometric.render.lowerTileMode;
            }),
          ),
          height(8),
          _buildSetType(GridNodeType.Empty, "Empty"),
          _buildSetType(GridNodeType.Bricks, "Bricks"),
          _buildSetType(GridNodeType.Grass, "Grass"),
          _buildSetType(GridNodeType.Stairs_North, "Stairs North"),
          _buildSetType(GridNodeType.Stairs_West, "Stairs West"),
          _buildSetType(GridNodeType.Stairs_South, "Stairs South"),
          _buildSetType(GridNodeType.Stairs_East, "Stairs East"),
          _buildSetType(GridNodeType.Water, "Water"),
        ],
      )
    ],
  );
}

Widget _buildSetType(int value, String name) {
  return WatchBuilder(edit.type, (int type) {
    return Container(
      width: 200,
      height: 50,
      color: type == value ? Colors.green : Colors.white60,
      child: text(name, onPressed: () {
        sendClientRequestSetBlock(edit.row, edit.column, edit.z, value);
      }),
    );
  });
}

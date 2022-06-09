
import 'package:bleed_common/grid_node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../game.dart';

Widget buildHudFrontLine(){
  return Stack(
     children: [
       Column(
         children: [
           _buildSetType(GridNodeType.Empty, "Empty"),
           _buildSetType(GridNodeType.Bricks, "Bricks"),
           _buildSetType(GridNodeType.Grass, "Grass"),
           _buildSetType(GridNodeType.Stairs_North, "Stairs North"),
         ],
       )
     ],
  );
}

Widget _buildSetType(int value, String name){
  return WatchBuilder(game.edit.type, (int type){
    return Container(
      width: 200,
      height: 50,
      color: type == value ? Colors.green : Colors.white60,
      child: text(name, onPressed: (){
        sendClientRequestSetBlock(game.edit.row, game.edit.column, game.edit.z, value);
      }),
    );
  });
}
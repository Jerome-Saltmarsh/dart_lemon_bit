import 'package:bleed_common/grid_node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/edit_state.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/state/grid.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'player.dart';


Widget buildHudMapEditor() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // _buildControlPlayerInfo(),
      // height8,
      // _buildWatchFrame(),
      
      _buildControlsSaveLoad(),
      _buildControlTime(),
      height8,
      _buildTabTiles(),
    ],
  );
}

Widget _buildControlsSaveLoad(){
  return Row(children: [
      text("Save"),
  ],);
}

Widget _buildWatchFrame(){
  return Refresh(() {
     return text("Frame: ${engine.frame}");
  });
}

Widget _buildControlPlayerInfo(){
  return Refresh((){
    return Container(
        // width: 350,
        height: 50,
        alignment: Alignment.centerLeft,
        color: Colors.white60,
        child: text("Player z: ${player.indexZ}, row: ${player.indexRow}, column: ${player.indexColumn}, xy:${player.x + player.y}"));
  });
}

Widget _buildControlTime() {
  return Container(
          height: 50,
          width: 200,
          color: Colors.white60,
          child: Row(
            children: [
              text("Time: "),
              watch(game.hours, (num hour) => text(padZero(hour))),
              text(":"),
              watch(game.minutes, (num hour) => text(padZero(hour))),
              Expanded(child: Container()),
              onPressed(
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: text("-"),
                ),
                callback: sendClientRequestReverseHour
              ),
              width2,
              onPressed(
                  child: Container(
                    width: 30,
                    height: 30,
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: text("+"),
                  ),
                  callback: sendClientRequestSkipHour
              ),
              width4,
            ],
          ),
        );
}

Widget _buildTabObjects(){
  return text('objects');
}

Widget _buildTabTiles(){
  return Column(
    children: [
      _buildSetType(GridNodeType.Empty, "Empty"),
      _buildSetType(GridNodeType.Bricks, "Bricks"),
      _buildSetType(GridNodeType.Grass, "Grass"),
      _buildSetType(GridNodeType.Stairs_North, "Stairs North"),
      _buildSetType(GridNodeType.Stairs_West, "Stairs West"),
      _buildSetType(GridNodeType.Stairs_South, "Stairs South"),
      _buildSetType(GridNodeType.Stairs_East, "Stairs East"),
      _buildSetType(GridNodeType.Water, "Water"),
      _buildSetType(GridNodeType.Torch, "Torch"),
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
        if (grid[edit.z][edit.row][edit.column] == value){
          for (var z = 0; z < edit.z; z++){
            sendClientRequestSetBlock(edit.row, edit.column, z, value);
          }
        } else {
          sendClientRequestSetBlock(edit.row, edit.column, edit.z, value);
        }

      }),
    );
  });
}
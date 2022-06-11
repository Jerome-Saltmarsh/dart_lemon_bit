import 'package:bleed_common/grid_node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/edit_state.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/state/grid.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:lemon_watch/watch_builder.dart';


Widget buildHudMapEditor() {
  return Stack(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     text("Tiles", onPressed: () => edit.tab.value = EditTab.Tile),
          //     text("Objects", onPressed: () => edit.tab.value = EditTab.Object),
          //   ],
          // ),

          _buildControlTime(),
          height8,
          _buildTabTiles(),
          // WatchBuilder(edit.tab, (tab){
          //    switch(tab){
          //      case EditTab.Tile:
          //        return _buildTabTiles();
          //      case EditTab.Object:
          //        return _buildTabObjects();
          //      default:
          //        throw Exception();
          //    }
          // }),
        ],
      )
    ],
  );
}

Container _buildControlTime() {
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
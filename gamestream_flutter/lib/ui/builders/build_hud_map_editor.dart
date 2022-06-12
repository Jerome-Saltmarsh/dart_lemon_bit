import 'package:bleed_common/grid_node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/edit_state.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/state/grid.dart';
import 'package:gamestream_flutter/state/light_mode.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'build_column_set_weapon.dart';
import 'player.dart';

Widget buildHudMapEditor() {
  return Stack(
    children: [
      Positioned(
          top: 0,
          left: 0,
          child: buildPanelEditor(),
      ),
      Positioned(
          top: 0,
          right: 0,
          child: buildPanelMenu()
      ),
      Positioned(
          bottom: 0,
          right: 0,
          child: buildColumnSetWeapon()),
    ],
  );
}

Widget buildPanelEditor(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildControlLightMode(),
      _buildControlTime(),
      height8,
      buildColumnEditTile(),
    ],
  );
}

Widget _buildControlLightMode(){
  return onPressed(
    callback: () => lightModeRadial.value = !lightModeRadial.value,
    child: Container(
        height: 50,
        width: 200,
        alignment: Alignment.centerLeft,
        color: Colors.white60,
        child: watch(lightModeRadial, (bool radial){
           return text(radial ? 'Radial' : "Square");
        })
    ),
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

Widget buildColumnEditTile(){
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
      _buildSetType(GridNodeType.Tree, "Tree"),
      onPressed(
        callback: () {
          sendClientRequestSpawnZombie(
            z: edit.z,
            row: edit.row,
            column: edit.column,
          );
        },
        child: Container(
          width: 200,
          height: 50,
          color: Colors.white60,
          alignment: Alignment.centerLeft,
          child: text("Zombie"),
        ),
      ),
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
          for (var z = 1; z < edit.z; z++){
            if (GridNodeType.isStairs(value)){
              sendClientRequestSetBlock(edit.row, edit.column, z, GridNodeType.Bricks);
            } else {
              sendClientRequestSetBlock(edit.row, edit.column, z, value);
            }
          }
        }
        sendClientRequestSetBlock(edit.row, edit.column, edit.z, value);
      }),
    );
  });
}
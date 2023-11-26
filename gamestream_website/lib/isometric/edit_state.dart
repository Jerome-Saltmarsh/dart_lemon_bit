import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/classes/node_extensions.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_editor_column_changed.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_editor_z_changed.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'classes/node.dart';
import 'editor/events/on_editor_row_changed.dart';
import 'grid.dart';
import 'player.dart';
import 'utils/mouse_raycast.dart';

final edit = EditState();

class EditState {

  final gameObject = GameObject();
  final gameObjectSelected = Watch(false);
  final gameObjectSelectedType = Watch(0);
  final gameObjectSelectedSpawnType = Watch(0);

  double get posX => row.value * tileSize + tileSizeHalf;
  double get posY => column.value * tileSize + tileSizeHalf;
  double get posZ => z.value * tileHeight;

  void refreshSelected([int? val]){
    selected.value = grid[z.value][row.value][column.value];
  }

  void deselectGameObject() {
    sendGameObjectRequestDeselect();
  }

  void translate({ double x = 0, double y = 0, double z = 0}){
    assert (gameObjectSelected.value);
    return sendClientRequestGameObjectTranslate(
      tx: x,
      ty: y,
      tz: z,
    );
  }

  var row = Watch(0, clamp: (int value){
    if (value < 0) return 0;
    if (value >= gridTotalRows) return gridTotalRows - 1;
    return value;
  }, onChanged: onEditorRowChanged);
  var column = Watch(0, clamp: (int value){
    if (value < 0) return 0;
    if (value >= gridTotalColumns) return gridTotalColumns - 1;
    return value;
  },
  onChanged: onEditorColumnChanged
  );
  var z = Watch(1, clamp: (int value){
    if (value < 0) return 0;
    if (value >= gridTotalZ) return gridTotalZ - 1;
    return value;
  }, onChanged: onEditorZChanged);
  final selected = Watch<Node>(Node.boundary);
  final paintType = Watch(GridNodeType.Bricks);
  final controlsVisibleWeather = Watch(true);

  int get selectedType => selected.value.type;

  void actionToggleControlsVisibleWeather(){
    controlsVisibleWeather.value = !controlsVisibleWeather.value;
  }

  void fill(){
    for (var zIndex = 0; zIndex <= z.value; zIndex++){
      sendClientRequestSetBlock(row.value, column.value, zIndex, paintType.value);
    }
  }

  void paintIfEmpty(int row, int column, int z, int type){
    if (outOfBounds(z, row, column)) return;
    // if (!GridNodeType.isRainOrEmpty(selectedType) && selectedType != GridNodeType.Grass_Long) return;
    sendClientRequestSetBlock(row, column, z, type);
  }

  void paintSlope(int row, int column, int z){
    if (outOfBounds(z, row, column)) return;
    // final current = getNode(z, row, column);

    final above = getNode(z, row - 1, column);
    final below = getNode(z, row + 1, column);
    final left = getNode(z, row, column + 1);
    final right = getNode(z, row, column - 1);
    var type = GridNodeType.Grass;

    if (above.isGrass && below.isEmpty){
       type = GridNodeType.Grass_Slope_North;
    }
    if (left.isEmpty && right.isGrass) {
      type = GridNodeType.Grass_Slope_East;
    }
    if (below.isGrass && above.isEmpty){
      type = GridNodeType.Grass_Slope_South;
    }
    if (left.isGrass && right.isEmpty) {
      type = GridNodeType.Grass_Slope_West;
    }
    if (left.isGrassSlopeSouth && below.isGrassSlopeWest){
      type = GridNodeType.Grass_Slope_Top;
    }
    if (above.isGrassSlopeWest && left.isGrassSlopeNorth){
      type = GridNodeType.Grass_Slope_Right;
    }
    if (above.isGrassSlopeEast && right.isGrassSlopeNorth){
      type = GridNodeType.Grass_Slope_Bottom;
    }
    if (right.isGrassSlopeSouth && below.isGrassSlopeEast){
      type = GridNodeType.Grass_Slope_Left;
    }

    if (above.isGrassSlopeWest && right.isGrassSlopeSouth){
      type = GridNodeType.Grass_Edge_Top;
    }
    if (right.isGrassSlopeNorth && below.isGrassSlopeWest){
      type = GridNodeType.Grass_Edge_Right;
    }
    if (left.isGrassSlopeNorth && below.isGrassSlopeEast){
      type = GridNodeType.Grass_Edge_Bottom;
    }
    if (above.isGrassSlopeEast && left.isGrassSlopeSouth){
      type = GridNodeType.Grass_Edge_Left;
    }

    if (type != GridNodeType.Grass){
      if (edit.selectedType == type){
        type = GridNodeType.Grass;
      }
    }
    sendClientRequestSetBlock(row, column, z, type);
  }

  void paintMouse(){
      selectMouseBlock();
      paint(selectPlayerIfPlay: false);
  }

  void selectMouseBlock(){
    mouseRaycast(selectBlock);
  }

  void selectMouseGameObject(){
    sendGameObjectRequestSelect();
  }

  void paintTorch(){
    paint(value: GridNodeType.Torch);
  }

  void paintTree(){
    selectPlayerIfPlayerMode();
    var zz = z.value;
    // if (GridNodeType.isSolid(currentType)){
    //     for (var i = 0; i < gridTotalZ - 1; i++){
    //        if (GridNodeType.isSolid(grid[i][row.value][column.value])) continue;
    //        zz = i;
    //        break;
    //     }
    // } else {
    //   for (var i = zz - 1; i >= 0; i--){
    //     if (!GridNodeType.isSolid(grid[i][row.value][column.value])) continue;
    //     zz = i + 1;
    //     break;
    //   }
    // }
    sendClientRequestSetBlock(row.value, column.value, zz, GridNodeType.Tree_Bottom);
    sendClientRequestSetBlock(row.value, column.value, zz + 1, GridNodeType.Tree_Top);
  }

  void selectPlayerIfPlayerMode(){
    if (modeIsPlay) selectPlayer();
  }

  void paintLongGrass(){
    paint(value: GridNodeType.Grass_Long);
  }

  void paintAtPlayerLongGrass(){
    sendClientRequestSetBlock(player.indexRow, player.indexColumn, player.indexZ, GridNodeType.Grass_Long);
  }

  void paintBricks(){
    paint(value: GridNodeType.Bricks);
  }

  void paintGrass(){
    paint(value: GridNodeType.Grass);
  }

  void paintWater(){
    paint(value: GridNodeType.Water);
  }

  void paintFloorBricks(){
     for (var row = 0; row < gridTotalRows; row++){
        for (var column = 0; column < gridTotalColumns; column++){
          sendClientRequestSetBlock(row, column, 0, GridNodeType.Bricks);
        }
     }
  }

  void selectBlock(int z, int row, int column){
    this.row.value = row;
    this.column.value = column;
    this.z.value = z;
  }

  void selectPlayerBlock(){
    row.value = player.indexRow;
    column.value = player.indexColumn;
    z.value = player.indexZ;
  }

  void deleteGameObjectSelected(){
    sendGameObjectRequestDelete();
  }

  void cameraCenterSelectedObject() =>
    engine.cameraCenter(gameObject.renderX, gameObject.renderY)
  ;

  void delete(){
    if (gameObjectSelected.value) {
      return deleteGameObjectSelected();
    }
    deleteIfTree();
    sendClientRequestSetBlock(row.value, column.value, z.value, GridNodeType.Empty);
  }

  void deleteIfTree(){
    if (selectedType == GridNodeType.Tree_Bottom){
      if (z.value < gridTotalZ - 1){
        if (grid[z.value + 1][row.value][column.value] == GridNodeType.Tree_Top){
          sendClientRequestSetBlock(row.value, column.value, z.value + 1, GridNodeType.Empty);
        }
      }
    }
    if (selectedType == GridNodeType.Tree_Top){
      if (z.value > 0){
        if (grid[z.value - 1][row.value][column.value] == GridNodeType.Tree_Bottom){
          sendClientRequestSetBlock(row.value, column.value, z.value - 1, GridNodeType.Empty);
        }
      }
    }
  }

  void selectPaintType(){
     paintType.value = selectedType;
  }

  void selectPlayer(){
    z.value = player.indexZ;
    row.value = player.indexRow;
    column.value = player.indexColumn;
  }

  void paint({int? value, bool selectPlayerIfPlay = true}) {
    if (modeIsPlay && selectPlayerIfPlay){
      selectPlayer();
    }

    if (value == GridNodeType.Empty){
       return delete();
    }

    if (value != null) {
      paintType.value = value;
    }

    deleteIfTree();
    return sendClientRequestSetBlock(row.value, column.value, z.value, paintType.value);
  }
}

void editZIncrease(){
   if (edit.z.value >= gridTotalZ) return;
   edit.z.value++;
}

void editZDecrease(){
  if (edit.z.value <= 0) return;
  edit.z.value--;
}
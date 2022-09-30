import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_cursor_position.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_node_type_spawn_selected.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_paint_type.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_selected_node.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_selected_node_type.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'grid.dart';
import 'player.dart';
import 'utils/mouse_raycast.dart';

final edit = Edit();

class SpawnNodeData {
  final int spawnType;
  final int spawnAmount;
  final int spawnRadius;

  SpawnNodeData({
    required this.spawnType,
    required this.spawnRadius,
    required this.spawnAmount,
  });
}

class Edit {


  int clamp(Function value, Function min, Function max){
    if (value() < min()) return min();
    if (value() > max()) return max();
    return value();
  }

  final selectedNodeData = Watch<SpawnNodeData?>(null);
  final gameObject = GameObject();
  final gameObjectSelected = Watch(false);
  final gameObjectSelectedType = Watch(0);
  final gameObjectSelectedAmount = Watch(0);
  final gameObjectSelectedParticleType = Watch(0);
  final gameObjectSelectedParticleSpawnRate = Watch(0);
  final gameObjectSelectedRadius = Watch(0.0);
  final gameObjectSelectedSpawnType = Watch(0);

  final nodeSelectedIndex = Watch<int>(0, onChanged: onChangedSelectedNodeIndex);
  final nodeSelectedType = Watch<int>(0, onChanged: onChangedSelectedNodeType);
  final nodeSelectedOrientation = Watch(NodeOrientation.None);
  final nodeOrientationVisible = Watch(true);
  final nodeTypeSpawnSelected = Watch(false, onChanged: onChangeNodeTypeSpawnSelected);
  final nodeSupportsSolid = Watch(false);
  final nodeSupportsSlopeSymmetric = Watch(false);
  final nodeSupportsSlopeCornerInner = Watch(false);
  final nodeSupportsSlopeCornerOuter = Watch(false);
  final nodeSupportsHalf = Watch(false);
  final nodeSupportsCorner = Watch(false);
  final isActiveEditTriggers = Watch(true);

  void cursorRowIncrease() => row.value++;
  void cursorRowDecrease() => row.value--;
  void cursorColumnIncrease() => column.value++;
  void cursorColumnDecrease() => column.value--;
  void cursorZIncrease() => z.value++;
  void cursorZDecrease() => z.value--;

  var row = Watch(0, clamp: (int value){
    if (value < 0) return 0;
    if (value >= gridTotalRows) return gridTotalRows - 1;
    return value;
  }, onChanged: onChangedCursorPosition);
  var column = Watch(0, clamp: (int value){
    if (value < 0) return 0;
    if (value >= gridTotalColumns) return gridTotalColumns - 1;
    return value;
  },
      onChanged: onChangedCursorPosition
  );
  var z = Watch(1, clamp: (int value){
    if (value < 0) return 0;
    if (value >= gridTotalZ) return gridTotalZ - 1;
    return value;
  }, onChanged: onChangedCursorPosition);


  final paintType = Watch(NodeType.Brick_2, onChanged: onChangedPaintType);
  final paintOrientation = Watch(NodeOrientation.None);
  final controlsVisibleWeather = Watch(true);

  double get posX => row.value * tileSize + tileSizeHalf;
  double get posY => column.value * tileSize + tileSizeHalf;
  double get posZ => z.value * tileHeight;

  double get renderX => projectX(edit.posX, edit.posY);
  double get renderY => projectY(edit.posX, edit.posY, edit.posZ);

  void refreshNodeSelectedIndex(){
    nodeSelectedIndex.value = gridNodeIndexZRC(z.value, row.value, column.value);
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

  void actionToggleControlsVisibleWeather(){
    controlsVisibleWeather.value = !controlsVisibleWeather.value;
  }

  void setPaintOrientationNone(){
    paintOrientation.value = NodeOrientation.None;
  }

  void assignDefaultNodeOrientation(int nodeType){
    paintOrientation.value = NodeType.getDefaultOrientation(nodeType);
  }

  void fill(){
    for (var zIndex = 0; zIndex <= z.value; zIndex++){
      sendClientRequestSetBlock(row.value, column.value, zIndex, paintType.value, paintOrientation.value);
    }
  }

  void paintSlope(int row, int column, int z){
    if (outOfBounds(z, row, column)) return;
    var type = NodeType.Grass;
    sendClientRequestSetBlock(row, column, z, type, paintOrientation.value);
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
    paint(nodeType: NodeType.Torch);
  }

  void paintTree(){
    selectPlayerIfPlayerMode();
    var zz = z.value;
    // if (NodeType.isSolid(currentType)){
    //     for (var i = 0; i < gridTotalZ - 1; i++){
    //        if (NodeType.isSolid(grid[i][row.value][column.value])) continue;
    //        zz = i;
    //        break;
    //     }
    // } else {
    //   for (var i = zz - 1; i >= 0; i--){
    //     if (!NodeType.isSolid(grid[i][row.value][column.value])) continue;
    //     zz = i + 1;
    //     break;
    //   }
    // }
    sendClientRequestSetBlock(row.value, column.value, zz, NodeType.Tree_Bottom);
    sendClientRequestSetBlock(row.value, column.value, zz + 1, NodeType.Tree_Top);
  }

  void selectPlayerIfPlayerMode(){
    if (playMode) selectPlayer();
  }

  void paintLongGrass(){
    paint(nodeType: NodeType.Grass_Long);
  }

  void paintAtPlayerLongGrass(){
    sendClientRequestSetBlock(player.indexRow, player.indexColumn, player.indexZ, NodeType.Grass_Long);
  }

  void paintBricks(){
    paint(nodeType: NodeType.Brick_2);
  }

  void paintGrass(){
    paint(nodeType: NodeType.Grass);
  }

  void paintWater(){
    paint(nodeType: NodeType.Water);
  }

  void paintFloorBricks(){
     for (var row = 0; row < gridTotalRows; row++){
        for (var column = 0; column < gridTotalColumns; column++){
          sendClientRequestSetBlock(row, column, 0, NodeType.Brick_2);
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
    print("edit.delete()");
    if (gameObjectSelected.value)
      return deleteGameObjectSelected();
    setNodeType(NodeType.Empty, NodeOrientation.None);
  }

  void setNodeType(int type, int orientation) =>
    sendClientRequestSetBlock(row.value, column.value, z.value, type, orientation);

  void selectPaintType(){
     paintType.value = nodeSelectedType.value;
     paintOrientation.value = nodeSelectedOrientation.value;
  }

  void selectPlayer(){
    z.value = player.indexZ;
    row.value = player.indexRow;
    column.value = player.indexColumn;
  }

  void paint({int? nodeType, bool selectPlayerIfPlay = true}) {
    if (playMode && selectPlayerIfPlay){
      selectPlayer();
    }

    if (nodeType == NodeType.Empty){
       return delete();
    }

    if (nodeType == null){
      nodeType = paintType.value;
    } else {
      paintType.value = nodeType;
    }

    var orientation = paintOrientation.value;

    if (NodeType.isOriented(nodeType)){
       if (!NodeType.supportsOrientation(nodeType, orientation)) {
          orientation = NodeType.getDefaultOrientation(nodeType);
       }
    }

    return sendClientRequestSetBlock(
        row.value,
        column.value,
        z.value,
        nodeType,
        orientation,
    );
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
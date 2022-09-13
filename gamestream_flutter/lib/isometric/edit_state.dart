import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_cursor_position.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_paint_type.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_selected_node.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'classes/node.dart';
import 'grid.dart';
import 'player.dart';
import 'utils/mouse_raycast.dart';

final edit = EditState();

class EditState {


  int clamp(Function value, Function min, Function max){
    if (value() < min()) return min();
    if (value() > max()) return max();
    return value();;
  }


  final gameObject = GameObject();
  final gameObjectSelected = Watch(false);
  final gameObjectSelectedType = Watch(0);
  final gameObjectSelectedAmount = Watch(0);
  final gameObjectSelectedRadius = Watch(0.0);
  final gameObjectSelectedSpawnType = Watch(0);

  final nodeSelected = Watch<Node>(Node.boundary, onChanged: onChangedSelectedNode);
  final nodeSelectedOrientation = Watch(NodeOrientation.None);
  final nodeOrientationVisible = Watch(true);
  final nodeSupportsSolid = Watch(false);
  final nodeSupportsSlopeSymmetric = Watch(false);
  final nodeSupportsSlopeCornerInner = Watch(false);
  final nodeSupportsSlopeCornerOuter = Watch(false);
  final nodeSupportsHalf = Watch(false);
  final nodeSupportsCorner = Watch(false);
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

  void updateNodeSupports(int type){
    nodeSupportsSolid.value = NodeType.isSolid(type);
    nodeSupportsCorner.value = NodeType.isCorner(type);
    nodeSupportsHalf.value = NodeType.isHalf(type);
    nodeSupportsSlopeCornerInner.value = NodeType.isSlopeCornerInner(type);
    nodeSupportsSlopeCornerOuter.value = NodeType.isSlopeCornerOuter(type);
    nodeSupportsSlopeSymmetric.value = NodeType.isSlopeSymmetric(type);
  }

  void refreshSelected([int? val]){
    nodeSelected.value = grid[z.value][row.value][column.value];
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

  int get selectedType => nodeSelected.value.type;

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
    paint(value: NodeType.Torch);
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
    if (modeIsPlay) selectPlayer();
  }

  void paintLongGrass(){
    paint(value: NodeType.Grass_Long);
  }

  void paintAtPlayerLongGrass(){
    sendClientRequestSetBlock(player.indexRow, player.indexColumn, player.indexZ, NodeType.Grass_Long);
  }

  void paintBricks(){
    paint(value: NodeType.Brick_2);
  }

  void paintGrass(){
    paint(value: NodeType.Grass);
  }

  void paintWater(){
    paint(value: NodeType.Water);
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
    if (gameObjectSelected.value) {
      return deleteGameObjectSelected();
    }
    deleteIfTree();
    sendClientRequestSetBlock(row.value, column.value, z.value, NodeType.Empty);
  }

  void deleteIfTree(){
    if (selectedType == NodeType.Tree_Bottom){
      if (z.value < gridTotalZ - 1){
        if (grid[z.value + 1][row.value][column.value] == NodeType.Tree_Top){
          sendClientRequestSetBlock(row.value, column.value, z.value + 1, NodeType.Empty);
        }
      }
    }
    if (selectedType == NodeType.Tree_Top){
      if (z.value > 0){
        if (grid[z.value - 1][row.value][column.value] == NodeType.Tree_Bottom){
          sendClientRequestSetBlock(row.value, column.value, z.value - 1, NodeType.Empty);
        }
      }
    }
  }

  void selectPaintType(){
     paintType.value = selectedType;
     paintOrientation.value = nodeSelected.value.orientation;
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

    if (value == NodeType.Empty){
       return delete();
    }

    if (value == null){
      value = paintType.value;
    } else {
      paintType.value = value;
    }

    deleteIfTree();

    var orientation = paintOrientation.value;

    if (NodeType.isOriented(value)){
       if (!NodeType.supportsOrientation(value, orientation)) {
          orientation = NodeType.getDefaultOrientation(value);
       }
    }

    return sendClientRequestSetBlock(
        row.value,
        column.value,
        z.value,
        value,
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
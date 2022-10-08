import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/convert_index.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_node_type_spawn_selected.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_paint_type.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_selected_node.dart';
import 'package:gamestream_flutter/isometric/editor/events/on_changed_selected_node_type.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
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


  final selectedNodeData = Watch<SpawnNodeData?>(null);
  final gameObject = GameObject();
  final gameObjectSelected = Watch(false);
  final gameObjectSelectedType = Watch(0);
  final gameObjectSelectedAmount = Watch(0);
  final gameObjectSelectedParticleType = Watch(0);
  final gameObjectSelectedParticleSpawnRate = Watch(0);
  final gameObjectSelectedRadius = Watch(0.0);
  final gameObjectSelectedSpawnType = Watch(0);

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

  var nodeIndex = Watch(0, clamp: (int value){
     if (value < 0) return 0;
     if (value >= nodesTotal) return nodesTotal - 1;
     return value;
  }, onChanged: onChangedSelectedNodeIndex);

  int get z => convertIndexToZ(nodeIndex.value);
  int get row => convertIndexToRow(nodeIndex.value);
  int get column => convertIndexToColumn(nodeIndex.value);

  set z(int value){
     if (value < 0) return;
     if (value >= nodesTotalZ) return;
     final difference = value - z;
     nodeIndex.value += difference * nodesArea;
  }

  set row(int value){
    if (value < 0) return;
    if (value >= nodesTotalRows) return;
    final difference = row - value;
    nodeIndex.value += difference * nodesTotalColumns;
  }

  set column(int value){
    if (value < 0) return;
    if (value >= nodesTotalColumns) return;
    nodeIndex.value += column - value;
  }

  final paintType = Watch(NodeType.Brick_2, onChanged: onChangedPaintType);
  final paintOrientation = Watch(NodeOrientation.None);
  final controlsVisibleWeather = Watch(true);

  double get posX => row * tileSize + tileSizeHalf;
  double get posY => column * tileSize + tileSizeHalf;
  double get posZ => z * tileHeight;

  double get renderX => projectX(edit.posX, edit.posY);
  double get renderY => projectY(edit.posX, edit.posY, edit.posZ);

  void refreshNodeSelectedIndex(){
    nodeSelectedType.value = nodesType[nodeIndex.value];
    nodeSelectedOrientation.value = nodesOrientation[nodeIndex.value];
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

  void paintLongGrass(){
    paint(nodeType: NodeType.Grass_Long);
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

  void selectBlock(int z, int row, int column){
    nodeIndex.value = getNodeIndexZRC(z, row, column);
  }

  void deleteGameObjectSelected(){
    sendGameObjectRequestDelete();
  }

  void cameraCenterSelectedObject() =>
    engine.cameraCenter(gameObject.renderX, gameObject.renderY)
  ;

  void delete(){
    if (gameObjectSelected.value)
      return deleteGameObjectSelected();
    setNodeType(NodeType.Empty, NodeOrientation.None);
  }

  void setNodeType(int type, int orientation) =>
    sendClientRequestSetBlock(
        index: nodeIndex.value,
        type: type,
        orientation: orientation,
    );

  void selectPaintType(){
     paintType.value = nodeSelectedType.value;
     paintOrientation.value = nodeSelectedOrientation.value;
  }

  void paint({int? nodeType, bool selectPlayerIfPlay = true}) {
    if (nodeType == NodeType.Empty){
       return delete();
    }

    if (nodeType == null){
      nodeType = paintType.value;
    } else {
      paintType.value = nodeType;
    }

    var orientation = paintOrientation.value;

    if (!NodeType.supportsOrientation(nodeType, orientation)) {
      orientation = NodeType.getDefaultOrientation(nodeType);
    }

    return sendClientRequestSetBlock(
        index: nodeIndex.value,
        type: nodeType,
        orientation: orientation,
    );
  }

  void cursorSetToPlayer() => nodeIndex.value = player.nodeIndex;
  void cursorRowIncrease() => row++;
  void cursorRowDecrease() => row--;
  void cursorColumnIncrease() => column++;
  void cursorColumnDecrease() => column--;
  void cursorZIncrease() => z++;
  void cursorZDecrease() => z--;
}

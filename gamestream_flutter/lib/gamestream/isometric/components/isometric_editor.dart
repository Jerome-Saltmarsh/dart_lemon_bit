
import 'package:gamestream_flutter/library.dart';

import '../enums/editor_dialog.dart';
import '../enums/emission_type.dart';
import '../classes/isometric_gameobject.dart';


class IsometricEditor {
  late final editorDialog = Watch<EditorDialog?>(null, onChanged: onChangedEditorDialog);
  late final editTab = Watch(EditTab.Grid, onChanged: onChangedEditTab);
  final selectedSceneName = Watch<String?>(null);
  final gameObject = Watch<IsometricGameObject?>(null);
  final gameObjectSelected = Watch(false);
  final gameObjectSelectedType = Watch(0);
  final gameObjectSelectedCollidable = Watch(true);
  final gameObjectSelectedGravity = Watch(true);
  final gameObjectSelectedFixed = Watch(true);
  final gameObjectSelectedCollectable = Watch(true);
  final gameObjectSelectedPhysical = Watch(true);
  final gameObjectSelectedPersistable = Watch(true);
  final gameObjectSelectedAmount = Watch(0);
  final gameObjectSelectedParticleType = Watch(0);
  final gameObjectSelectedParticleSpawnRate = Watch(0);
  final gameObjectSelectedSpawnType = Watch(0);
  final gameObjectSelectedEmission = Watch(IsometricEmissionType.None);

  late final gameObjectSelectedEmissionIntensity = Watch(1.0, onChanged: (double value){
    gameObject.value?.emission_intensity = value;
  });

  late final nodeSelectedType = Watch<int>(0, onChanged: onChangedSelectedNodeType);
  final nodeSelectedOrientation = Watch(NodeOrientation.None);
  final nodeOrientationVisible = Watch(true);
  final nodeTypeSpawnSelected = Watch(false);
  final isActiveEditTriggers = Watch(true);

  late var nodeSelectedIndex = Watch(0, clamp: (int value){
    if (value < 0) return 0;
    if (value >= gamestream.isometric.nodes.total) return gamestream.isometric.nodes.total - 1;
    return value;
  }, onChanged: onChangedSelectedNodeIndex);

  int get z => gamestream.isometric.nodes.convertNodeIndexToIndexZ(nodeSelectedIndex.value);
  int get row => gamestream.isometric.nodes.convertNodeIndexToIndexX(nodeSelectedIndex.value);
  int get column => gamestream.isometric.nodes.convertNodeIndexToIndexY(nodeSelectedIndex.value);

  set z(int value){
    if (value < 0) return;
    if (value >= gamestream.isometric.nodes.totalZ) return;
    final difference = value - z;
    nodeSelectedIndex.value += difference * gamestream.isometric.nodes.area;
  }

  set row(int value){
    if (value < 0) return;
    if (value >= gamestream.isometric.nodes.totalRows) return;
    final difference = value - row;
    nodeSelectedIndex.value += difference * gamestream.isometric.nodes.totalColumns;
  }

  set column(int value){
    if (value < 0) return;
    if (value >= gamestream.isometric.nodes.totalColumns) return;
    nodeSelectedIndex.value += value - column;
  }

  late final paintType = Watch(NodeType.Brick, onChanged: onChangedPaintType);
  final paintOrientation = Watch(NodeOrientation.None);
  final controlsVisibleWeather = Watch(true);

  double get posX => row * Node_Size + Node_Size_Half;
  double get posY => column * Node_Size + Node_Size_Half;
  double get posZ => z * Node_Height;


  void onKeyPressedModeEdit(int key){

    switch (key){
      case KeyCode.V:
        sendGameObjectRequestDuplicate();
        break;
      case KeyCode.F:
        gamestream.isometric.editor.paint();
        break;
      case KeyCode.G:
        if (gamestream.isometric.editor.gameObjectSelected.value) {
          sendGameObjectRequestMoveToMouse();
        } else {
          gamestream.isometric.camera.cameraSetPositionGrid(gamestream.isometric.editor.row, gamestream.isometric.editor.column, gamestream.isometric.editor.z);
        }
        break;
      case KeyCode.R:
        gamestream.isometric.editor.selectPaintType();
        break;
      case KeyCode.Arrow_Up:
        if (engine.keyPressedShiftLeft) {
          if (gamestream.isometric.editor.gameObjectSelected.value){
            gamestream.isometric.editor.translate(x: 0, y: 0, z: 1);
            return;
          }
          gamestream.isometric.editor.cursorZIncrease();
          return;
        }
        if (gamestream.isometric.editor.gameObjectSelected.value) {
          gamestream.isometric.editor.translate(x: -1, y: -1, z: 0);
          return;
        }
        gamestream.isometric.editor.cursorRowDecrease();
        return;
      case KeyCode.Arrow_Right:
        if (gamestream.isometric.editor.gameObjectSelected.value){
          return gamestream.isometric.editor.translate(x: 1, y: -1, z: 0);
        }
        gamestream.isometric.editor.cursorColumnDecrease();
        break;
      case KeyCode.Arrow_Down:
        if (engine.keyPressedShiftLeft) {
          if (gamestream.isometric.editor.gameObjectSelected.value){
            return gamestream.isometric.editor.translate(x: 0, y: 0, z: -1);
          }
          gamestream.isometric.editor.cursorZDecrease();
        } else {
          if (gamestream.isometric.editor.gameObjectSelected.value){
            return gamestream.isometric.editor.translate(x: 1, y: 1, z: 0);
          }
          gamestream.isometric.editor.cursorRowIncrease();
        }
        break;
      case KeyCode.Arrow_Left:
        if (gamestream.isometric.editor.gameObjectSelected.value){
          return gamestream.isometric.editor.translate(x: -1, y: 1, z: 0);
        }
        gamestream.isometric.editor.cursorColumnIncrease();
        break;
    }
  }


  void refreshNodeSelectedIndex(){
    nodeSelectedType.value = gamestream.isometric.nodes.nodeTypes[nodeSelectedIndex.value];
    nodeSelectedOrientation.value = gamestream.isometric.nodes.nodeOrientations[nodeSelectedIndex.value];
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
    gamestream.io.mouseRaycast(selectBlock);
  }

  void selectMouseGameObject(){
    sendGameObjectRequestSelect();
  }

  void paintTorch(){
    paint(nodeType: NodeType.Torch);
  }

  void paintTree(){
    paint(nodeType: NodeType.Tree_Bottom);
  }

  void paintLongGrass(){
    paint(nodeType: NodeType.Grass_Long);
  }

  void paintBricks(){
    paint(nodeType: NodeType.Brick);
  }

  void paintGrass(){
    paint(nodeType: NodeType.Grass);
  }

  void paintWater(){
    paint(nodeType: NodeType.Water);
  }

  void selectBlock(int z, int row, int column){
    nodeSelectedIndex.value = gamestream.isometric.nodes.getNodeIndexZRC(z, row, column);
  }

  void deleteGameObjectSelected(){
    sendGameObjectRequestDelete();
  }

  void cameraCenterSelectedObject() =>
      engine.cameraCenter(
        gameObject.value!.renderX,
        gameObject.value!.renderY,
      );

  void delete(){
    if (gameObjectSelected.value)
      return deleteGameObjectSelected();
    setNodeType(NodeType.Empty, NodeOrientation.None);
  }

  void setNodeType(int type, int orientation) =>
      sendClientRequestSetBlock(
        index: nodeSelectedIndex.value,
        type: type,
        orientation: orientation,
      );

  void raise(){
    final nodeIndex = nodeSelectedIndex.value;
    if (nodeIndex <= gamestream.isometric.nodes.area) return;
    final nodeIndexBelow = nodeIndex - gamestream.isometric.nodes.area;
    sendClientRequestSetBlock(
      index: nodeSelectedIndex.value,
      type: gamestream.isometric.nodes.nodeTypes[nodeIndexBelow],
      orientation: gamestream.isometric.nodes.nodeOrientations[nodeIndexBelow],
    );
  }

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
      index: nodeSelectedIndex.value,
      type: nodeType,
      orientation: orientation,
    );
  }

  void cursorSetToPlayer() {
    if (!gamestream.isometric.player.inBounds) return;
    nodeSelectedIndex.value = gamestream.isometric.player.position.nodeIndex;
  }
  void cursorRowIncrease() => row++;
  void cursorRowDecrease() => row--;
  void cursorColumnIncrease() => column++;
  void cursorColumnDecrease() => column--;
  void cursorZIncrease() => z++;
  void cursorZDecrease() => z--;

  void selectSceneName(String value){
    selectedSceneName.value = value;
  }

  void actionRecenterCamera() =>
      gamestream.isometric.camera.cameraSetPositionGrid(
        row,
        column,
        z,
      );

  void onChangedPaintType(int type) {
    if (!NodeType.supportsOrientation(type, paintOrientation.value))
      return setPaintOrientationNone();
    if (NodeType.supportsOrientation(type, paintOrientation.value)) return;
    assignDefaultNodeOrientation(type);
  }

  void onChangedSelectedNodeIndex(int index){
    nodeSelectedOrientation.value = gamestream.isometric.nodes.nodeOrientations[index];
    nodeSelectedType.value = gamestream.isometric.nodes.nodeTypes[index];
    gameObjectSelected.value = false;
    refreshNodeSelectedIndex();
    deselectGameObject();
  }

  void onChangedSelectedNodeType(int nodeType){
    nodeOrientationVisible.value = true;
    nodeTypeSpawnSelected.value = nodeType == NodeType.Spawn;
  }

  void onChangedEditorDialog(EditorDialog? value){
    if (value == EditorDialog.Scene_Load){

    }
  }

  void actionGameDialogShowSceneSave(){
    editorDialog.value = EditorDialog.Scene_Save;
  }

  void actionGameDialogClose(){
    editorDialog.value = null;
  }

  void setTabGrid(){
    editTab.value = EditTab.Grid;
  }

  // EVENTS

  void onChangedEditTab(EditTab editTab){
    deselectGameObject();
  }

  void setSelectedObjectedIntensity(double value){
    gameObject.value?.emission_intensity = value;
  }

  void onMouseLeftClicked() {
    switch (editTab.value) {
      case EditTab.File:
        setTabGrid();
        selectMouseBlock();
        break;
      case EditTab.Grid:
        selectMouseBlock();
        actionRecenterCamera();
        break;
      case EditTab.Objects:
        selectMouseGameObject();
        break;
    }
  }

  void sendClientRequestGameObjectTranslate({
    required double tx,
    required double ty,
    required double tz,
  }) => sendGameObjectRequest(IsometricEditorGameObjectRequest.Translate, "$tx $ty $tz");

  void sendGameObjectRequestDuplicate() => sendGameObjectRequest(IsometricEditorGameObjectRequest.Duplicate);

  void sendGameObjectRequestSelect() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Select);

  void sendGameObjectRequestDeselect() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Deselect);

  void sendGameObjectRequestDelete() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Delete);

  void sendGameObjectRequestMoveToMouse() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Move_To_Mouse);

  void sendGameObjectRequestToggleStrikable() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Strikable);

  void sendGameObjectRequestToggleGravity() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Gravity);

  void sendGameObjectRequestToggleFixed() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Fixed);

  void sendGameObjectRequestToggleCollectable() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Collectable);

  void selectedGameObjectTogglePhysical() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Physical);

  void selectedGameObjectTogglePersistable() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Persistable);

  void actionAddGameObject(int type) =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Add, '${nodeSelectedIndex.value} $type');

  void sendGameObjectRequest(IsometricEditorGameObjectRequest gameObjectRequest, [dynamic message]) =>
      sendIsometricEditorRequest(
        IsometricEditorRequest.GameObject,
        '${gameObjectRequest.index} $message',
      );

  void sendClientRequestSetBlock({
    required int index,
    required int type,
    required int orientation,
  }) =>
      sendIsometricEditorRequest(
        IsometricEditorRequest.Set_Node,
        '$index $type $orientation',
      );

  void sendIsometricEditorRequest(IsometricEditorRequest request, [dynamic message]) =>
      gamestream.network.sendClientRequest(
        ClientRequest.Isometric_Editor,
        '${request.index} $message',
      );
}

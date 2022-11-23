import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:gamestream_flutter/library.dart';

class GameEditor {
  static final editorDialog = Watch<EditorDialog?>(null, onChanged: onChangedEditorDialog);
  static final selectedSceneName = Watch<String?>(null);

  static final editTab = Watch(EditTab.Grid);
  static final gameObject = GameObject();
  static final gameObjectSelected = Watch(false);
  static final gameObjectSelectedType = Watch(0);
  static final gameObjectSelectedAmount = Watch(0);
  static final gameObjectSelectedParticleType = Watch(0);
  static final gameObjectSelectedParticleSpawnRate = Watch(0);
  static final gameObjectSelectedRadius = Watch(0.0);
  static final gameObjectSelectedSpawnType = Watch(0);

  static final nodeSelectedType = Watch<int>(0, onChanged: onChangedSelectedNodeType);
  static final nodeSelectedOrientation = Watch(NodeOrientation.None);
  static final nodeOrientationVisible = Watch(true);
  static final nodeTypeSpawnSelected = Watch(false);
  static final isActiveEditTriggers = Watch(true);

  static var nodeSelectedIndex = Watch(0, clamp: (int value){
     if (value < 0) return 0;
     if (value >= GameNodes.nodesTotal) return GameNodes.nodesTotal - 1;
     return value;
  }, onChanged: onChangedSelectedNodeIndex);

  static int get z => GameState.convertNodeIndexToZ(nodeSelectedIndex.value);
  static int get row => GameState.convertNodeIndexToRow(nodeSelectedIndex.value);
  static int get column => GameState.convertNodeIndexToColumn(nodeSelectedIndex.value);

  static set z(int value){
     if (value < 0) return;
     if (value >= GameState.nodesTotalZ) return;
     final difference = value - z;
     nodeSelectedIndex.value += difference * GameState.nodesArea;
  }

  static set row(int value){
    if (value < 0) return;
    if (value >= GameState.nodesTotalRows) return;
    final difference = value - row;
    nodeSelectedIndex.value += difference * GameState.nodesTotalColumns;
  }

  static set column(int value){
    if (value < 0) return;
    if (value >= GameState.nodesTotalColumns) return;
    nodeSelectedIndex.value += value - column;
  }

  static final paintType = Watch(NodeType.Brick_2, onChanged: onChangedPaintType);
  static final paintOrientation = Watch(NodeOrientation.None);
  static final controlsVisibleWeather = Watch(true);

  static double get posX => row * Node_Size + Node_Size_Half;
  static double get posY => column * Node_Size + Node_Size_Half;
  static double get posZ => z * Node_Height;

  static void refreshNodeSelectedIndex(){
    nodeSelectedType.value = GameNodes.nodesType[nodeSelectedIndex.value];
    nodeSelectedOrientation.value = GameNodes.nodesOrientation[nodeSelectedIndex.value];
  }

  static void deselectGameObject() {
    GameNetwork.sendGameObjectRequestDeselect();
  }

  static void translate({ double x = 0, double y = 0, double z = 0}){
    assert (gameObjectSelected.value);
    return GameNetwork.sendClientRequestGameObjectTranslate(
      tx: x,
      ty: y,
      tz: z,
    );
  }

  static void actionToggleControlsVisibleWeather(){
    controlsVisibleWeather.value = !controlsVisibleWeather.value;
  }

  static void setPaintOrientationNone(){
    paintOrientation.value = NodeOrientation.None;
  }

  static void assignDefaultNodeOrientation(int nodeType){
    paintOrientation.value = NodeType.getDefaultOrientation(nodeType);
  }

  static void paintMouse(){
      selectMouseBlock();
      paint(selectPlayerIfPlay: false);
  }

  static void selectMouseBlock(){
    GameIO.mouseRaycast(selectBlock);
  }

  static void selectMouseGameObject(){
    GameNetwork.sendGameObjectRequestSelect();
  }

  static void paintTorch(){
    paint(nodeType: NodeType.Torch);
  }

  static void paintTree(){
    paint(nodeType: NodeType.Tree_Bottom);
  }

  static void paintLongGrass(){
    paint(nodeType: NodeType.Grass_Long);
  }

  static void paintBricks(){
    paint(nodeType: NodeType.Brick_2);
  }

  static void paintGrass(){
    paint(nodeType: NodeType.Grass);
  }

  static void paintWater(){
    paint(nodeType: NodeType.Water);
  }

  static void selectBlock(int z, int row, int column){
    nodeSelectedIndex.value = GameState.getNodeIndexZRC(z, row, column);
  }

  static void deleteGameObjectSelected(){
    GameNetwork.sendGameObjectRequestDelete();
  }

  static void cameraCenterSelectedObject() =>
      Engine.cameraCenter(gameObject.renderX, gameObject.renderY)
  ;

  static void delete(){
    if (gameObjectSelected.value)
      return deleteGameObjectSelected();
    setNodeType(NodeType.Empty, NodeOrientation.None);
  }

  static void setNodeType(int type, int orientation) =>
      GameNetwork.sendClientRequestSetBlock(
        index: nodeSelectedIndex.value,
        type: type,
        orientation: orientation,
    );

  static void selectPaintType(){
     paintType.value = nodeSelectedType.value;
     paintOrientation.value = nodeSelectedOrientation.value;
  }

  static void paint({int? nodeType, bool selectPlayerIfPlay = true}) {
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

    return GameNetwork.sendClientRequestSetBlock(
        index: nodeSelectedIndex.value,
        type: nodeType,
        orientation: orientation,
    );
  }

  static void cursorSetToPlayer() => nodeSelectedIndex.value = GamePlayer.position.nodeIndex;
  static void cursorRowIncrease() => row++;
  static void cursorRowDecrease() => row--;
  static void cursorColumnIncrease() => column++;
  static void cursorColumnDecrease() => column--;
  static void cursorZIncrease() => z++;
  static void cursorZDecrease() => z--;

  static void selectSceneName(String value){
    selectedSceneName.value = value;
  }

  static void actionAddGameObject(int type) =>
      GameNetwork.sendClientRequestAddGameObject(
        index: GameEditor.nodeSelectedIndex.value,
        type: type,
      );

  static void actionRecenterCamera() =>
      GameCamera.cameraSetPositionGrid(
        GameEditor.row,
        GameEditor.column,
        GameEditor.z,
      );

  static void requestSaveScene() =>
    GameNetwork.sendClientRequest(ClientRequest.Save_Scene);

  static void onChangedPaintType(int type) {
    if (!NodeType.supportsOrientation(type, paintOrientation.value))
      return setPaintOrientationNone();
    if (NodeType.supportsOrientation(type, paintOrientation.value)) return;
    assignDefaultNodeOrientation(type);
  }

  static void onChangedSelectedNodeIndex(int index){
    nodeSelectedOrientation.value = GameNodes.nodesOrientation[index];
    nodeSelectedType.value = GameNodes.nodesType[index];
    gameObjectSelected.value = false;
    refreshNodeSelectedIndex();
    deselectGameObject();
  }

  static void onChangedSelectedNodeType(int nodeType){
    nodeOrientationVisible.value = true;
    nodeTypeSpawnSelected.value = nodeType == NodeType.Spawn;
  }

  static void onChangedEditorDialog(EditorDialog? value){
    if (value == EditorDialog.Scene_Load){

    }
  }

  static void editorLoadScene() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final contents = result.files[0].bytes;
    if (contents == null) throw Exception("Load Scene Exception: selected file contents are null");
    GameNetwork.sendClientRequest(ClientRequest.Editor_Load_Scene, utf8.decode(contents));
  }

  static void actionGameDialogShowSceneSave(){
    GameEditor.editorDialog.value = EditorDialog.Scene_Save;
  }

  static void actionGameDialogClose(){
    GameEditor.editorDialog.value = null;
  }
}

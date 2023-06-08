
import 'package:gamestream_flutter/library.dart';


class IsometricEditor {
  late final editorDialog = Watch<EditorDialog?>(null, onChanged: onChangedEditorDialog);
  late final editTab = Watch(EditTab.Grid, onChanged: onChangedEditTab);
  final selectedSceneName = Watch<String?>(null);
  final gameObject = Watch<GameObject?>(null);
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
  final gameObjectSelectedEmission = Watch(EmissionType.None);

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

  int get z => gamestream.isometric.clientState.convertNodeIndexToIndexZ(nodeSelectedIndex.value);
  int get row => gamestream.isometric.clientState.convertNodeIndexToIndexX(nodeSelectedIndex.value);
  int get column => gamestream.isometric.clientState.convertNodeIndexToIndexY(nodeSelectedIndex.value);

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

  void refreshNodeSelectedIndex(){
    nodeSelectedType.value = gamestream.isometric.nodes.nodeTypes[nodeSelectedIndex.value];
    nodeSelectedOrientation.value = gamestream.isometric.nodes.nodeOrientations[nodeSelectedIndex.value];
  }

  void deselectGameObject() {
    gamestream.network.sendGameObjectRequestDeselect();
  }

  void translate({ double x = 0, double y = 0, double z = 0}){
    assert (gameObjectSelected.value);
    return gamestream.network.sendClientRequestGameObjectTranslate(
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
    gamestream.network.sendGameObjectRequestSelect();
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
    nodeSelectedIndex.value = gamestream.isometric.clientState.getNodeIndexZRC(z, row, column);
  }

  void deleteGameObjectSelected(){
    gamestream.network.sendGameObjectRequestDelete();
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
      gamestream.network.sendClientRequestSetBlock(
        index: nodeSelectedIndex.value,
        type: type,
        orientation: orientation,
      );

  void raise(){
    final nodeIndex = nodeSelectedIndex.value;
    if (nodeIndex <= gamestream.isometric.nodes.area) return;
    final nodeIndexBelow = nodeIndex - gamestream.isometric.nodes.area;
    gamestream.network.sendClientRequestSetBlock(
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

    return gamestream.network.sendClientRequestSetBlock(
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

  void actionAddGameObject(int type) =>
      gamestream.network.sendClientRequestAddGameObject(
        index: gamestream.isometric.editor.nodeSelectedIndex.value,
        type: type,
      );

  void actionRecenterCamera() =>
      gamestream.isometric.camera.cameraSetPositionGrid(
        gamestream.isometric.editor.row,
        gamestream.isometric.editor.column,
        gamestream.isometric.editor.z,
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
    gamestream.isometric.editor.editorDialog.value = EditorDialog.Scene_Save;
  }

  void actionGameDialogClose(){
    gamestream.isometric.editor.editorDialog.value = null;
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
}

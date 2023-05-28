import 'package:gamestream_flutter/library.dart';


class GameEditor {
  static final editorDialog = Watch<EditorDialog?>(null, onChanged: onChangedEditorDialog);
  static final selectedSceneName = Watch<String?>(null);


  static final editTab = Watch(EditTab.Grid, onChanged: onChangedEditTab);
  static final gameObject = Watch<GameObject?>(null);
  static final gameObjectSelected = Watch(false);
  static final gameObjectSelectedType = Watch(0);
  static final gameObjectSelectedCollidable = Watch(true);
  static final gameObjectSelectedGravity = Watch(true);
  static final gameObjectSelectedFixed = Watch(true);
  static final gameObjectSelectedCollectable = Watch(true);
  static final gameObjectSelectedPhysical = Watch(true);
  static final gameObjectSelectedPersistable = Watch(true);
  static final gameObjectSelectedAmount = Watch(0);
  static final gameObjectSelectedParticleType = Watch(0);
  static final gameObjectSelectedParticleSpawnRate = Watch(0);
  static final gameObjectSelectedSpawnType = Watch(0);
  static final gameObjectSelectedEmission = Watch(EmissionType.None);

  static final gameObjectSelectedEmissionIntensity = Watch(1.0, onChanged: (double value){
     gameObject.value?.emission_intensity = value;
  });

  static final nodeSelectedType = Watch<int>(0, onChanged: onChangedSelectedNodeType);
  static final nodeSelectedOrientation = Watch(NodeOrientation.None);
  static final nodeOrientationVisible = Watch(true);
  static final nodeTypeSpawnSelected = Watch(false);
  static final isActiveEditTriggers = Watch(true);

  static var nodeSelectedIndex = Watch(0, clamp: (int value){
     if (value < 0) return 0;
     if (value >= gamestream.games.isometric.nodes.total) return gamestream.games.isometric.nodes.total - 1;
     return value;
  }, onChanged: onChangedSelectedNodeIndex);

  static int get z => gamestream.games.isometric.clientState.convertNodeIndexToIndexZ(nodeSelectedIndex.value);
  static int get row => gamestream.games.isometric.clientState.convertNodeIndexToIndexX(nodeSelectedIndex.value);
  static int get column => gamestream.games.isometric.clientState.convertNodeIndexToIndexY(nodeSelectedIndex.value);

  static set z(int value){
     if (value < 0) return;
     if (value >= gamestream.games.isometric.nodes.totalZ) return;
     final difference = value - z;
     nodeSelectedIndex.value += difference * gamestream.games.isometric.nodes.area;
  }

  static set row(int value){
    if (value < 0) return;
    if (value >= gamestream.games.isometric.nodes.totalRows) return;
    final difference = value - row;
    nodeSelectedIndex.value += difference * gamestream.games.isometric.nodes.totalColumns;
  }

  static set column(int value){
    if (value < 0) return;
    if (value >= gamestream.games.isometric.nodes.totalColumns) return;
    nodeSelectedIndex.value += value - column;
  }

  static final paintType = Watch(NodeType.Brick, onChanged: onChangedPaintType);
  static final paintOrientation = Watch(NodeOrientation.None);
  static final controlsVisibleWeather = Watch(true);

  static double get posX => row * Node_Size + Node_Size_Half;
  static double get posY => column * Node_Size + Node_Size_Half;
  static double get posZ => z * Node_Height;

  static void refreshNodeSelectedIndex(){
    nodeSelectedType.value = gamestream.games.isometric.nodes.nodeTypes[nodeSelectedIndex.value];
    nodeSelectedOrientation.value = gamestream.games.isometric.nodes.nodeOrientations[nodeSelectedIndex.value];
  }

  static void deselectGameObject() {
    gamestream.network.sendGameObjectRequestDeselect();
  }

  static void translate({ double x = 0, double y = 0, double z = 0}){
    assert (gameObjectSelected.value);
    return gamestream.network.sendClientRequestGameObjectTranslate(
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
    gamestream.io.mouseRaycast(selectBlock);
  }

  static void selectMouseGameObject(){
    gamestream.network.sendGameObjectRequestSelect();
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
    paint(nodeType: NodeType.Brick);
  }

  static void paintGrass(){
    paint(nodeType: NodeType.Grass);
  }

  static void paintWater(){
    paint(nodeType: NodeType.Water);
  }

  static void selectBlock(int z, int row, int column){
    nodeSelectedIndex.value = gamestream.games.isometric.clientState.getNodeIndexZRC(z, row, column);
  }

  static void deleteGameObjectSelected(){
    gamestream.network.sendGameObjectRequestDelete();
  }

  static void cameraCenterSelectedObject() =>
      engine.cameraCenter(
          gameObject.value!.renderX,
          gameObject.value!.renderY,
      );

  static void delete(){
    if (gameObjectSelected.value)
      return deleteGameObjectSelected();
    setNodeType(NodeType.Empty, NodeOrientation.None);
  }

  static void setNodeType(int type, int orientation) =>
      gamestream.network.sendClientRequestSetBlock(
        index: nodeSelectedIndex.value,
        type: type,
        orientation: orientation,
    );

  static void raise(){
    final nodeIndex = nodeSelectedIndex.value;
    if (nodeIndex <= gamestream.games.isometric.nodes.area) return;
    final nodeIndexBelow = nodeIndex - gamestream.games.isometric.nodes.area;
    gamestream.network.sendClientRequestSetBlock(
      index: nodeSelectedIndex.value,
      type: gamestream.games.isometric.nodes.nodeTypes[nodeIndexBelow],
      orientation: gamestream.games.isometric.nodes.nodeOrientations[nodeIndexBelow],
    );
  }

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

    return gamestream.network.sendClientRequestSetBlock(
        index: nodeSelectedIndex.value,
        type: nodeType,
        orientation: orientation,
    );
  }

  static void cursorSetToPlayer() {
    if (!GamePlayer.inBounds) return;
    nodeSelectedIndex.value = GamePlayer.position.nodeIndex;
  }
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
      gamestream.network.sendClientRequestAddGameObject(
        index: GameEditor.nodeSelectedIndex.value,
        type: type,
      );

  static void actionRecenterCamera() =>
        gamestream.games.isometric.camera.cameraSetPositionGrid(
        GameEditor.row,
        GameEditor.column,
        GameEditor.z,
      );

  static void onChangedPaintType(int type) {
    if (!NodeType.supportsOrientation(type, paintOrientation.value))
      return setPaintOrientationNone();
    if (NodeType.supportsOrientation(type, paintOrientation.value)) return;
    assignDefaultNodeOrientation(type);
  }

  static void onChangedSelectedNodeIndex(int index){
    nodeSelectedOrientation.value = gamestream.games.isometric.nodes.nodeOrientations[index];
    nodeSelectedType.value = gamestream.games.isometric.nodes.nodeTypes[index];
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

  static void actionGameDialogShowSceneSave(){
    GameEditor.editorDialog.value = EditorDialog.Scene_Save;
  }

  static void actionGameDialogClose(){
    GameEditor.editorDialog.value = null;
  }

  static void setTabGrid(){
    editTab.value = EditTab.Grid;
  }

  // EVENTS

  static void onChangedEditTab(EditTab editTab){
     deselectGameObject();
  }

  static void setSelectedObjectedIntensity(double value){
    gameObject.value?.emission_intensity = value;
  }
}

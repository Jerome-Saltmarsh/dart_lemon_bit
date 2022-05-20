import 'package:bleed_common/ItemType.dart';
import 'package:bleed_common/SceneJson.dart';
import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/constants.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/classes/game_object.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/isometric/classes.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';
import 'package:typedef/json.dart';

import 'compile.dart';
import 'enums.dart';
import 'scope.dart';

class EditorActions with EditorScope {

  final EditorCompile compile;
  EditorActions(this.compile);

  // void addEnvironmentObject () {
  //   state.environmentObjects.add(
  //       StaticObject(
  //         x: mouseWorldX,
  //         y: mouseWorldY,
  //         type: state.objectType.value,
  //       )
  //   );
  //   if (state.objectType.value == ObjectType.Torch) {
  //     isometric.resetLighting();
  //   }
  //   engine.redrawCanvas();
  // }

  void setTile() {
    setTileAtMouse(state.tile.value);
  }

  void deleteSelected() {
    if (state.selected.value == null) return;
    byteStreamParser.gameObjects.remove(state.selected.value);
    state.selected.value = null;
    engine.redrawCanvas();
  }

  void panModeActivate(){
    engine.callbacks.onMouseMoved = events.onMouseMoved;
  }

  void panModeDeactivate(){
    if (engine.callbacks.onMouseMoved == events.onMouseMoved){
      engine.callbacks.onMouseMoved = null;
    }
  }

  void clear() {
    newScene(
        rows: isometric.totalRows.value,
        columns: isometric.totalColumns.value
    );
  }

  void play(){
    website.actions.connectToCustomGame(state.mapNameController.text);
  }

  void moveSelectedToMouse(){
    final selected = state.selected.value;
    if (selected == null) return;
    if (selected is GameObject){
      selected.move(mouseWorldX, mouseWorldY);
    } else{
      selected.x = mouseWorldX;
      selected.y = mouseWorldY;
    }
  }

  void newScene({
    int rows = 40,
    int columns = 40,
    int tile = Tile.Grass,
  }){
    print("editor.actions.newScene()");
    isometric.totalRows.value = rows;
    isometric.totalColumns.value = columns;
    isometric.maxColumn = columns;
    isometric.maxRow = rows;
    isometric.tiles.clear();
    editor.state.teamSpawnPoints.clear();
    editor.state.teamSpawnPoints.add(
       isometric.mapCenter
    );

    editor.state.timeSpeed.value = TimeSpeed.Normal;
    isometric.minutes.value = config.defaultStartTime;
    editor.state.characters.clear();
    for (int row = 0; row < rows; row++) {
      List<int> columnTiles = [];
      for (int column = 0; column < columns; column++) {
        columnTiles.add(tile);
      }
      isometric.tiles.add(columnTiles);
    }
    isometric.particleEmitters.clear();
    byteStreamParser.gameObjects.clear();
    byteStreamParser.itemsTotal = 0;
    isometric.updateTileRender();
  }

  void closeDialog(){
    print("editor.actions.closeDialog()");
    editor.state.dialog.value = EditorDialog.None;
  }

  void showDialogLoadMap(){
    print("actions.showDialogSelectMap()");
    editor.state.dialog.value = EditorDialog.Load;
  }

  void showDialogSave(){
    print("actions.showEditorDialogSave()");
    editor.state.dialog.value = EditorDialog.Save;
  }


  void saveMapToFirestore() async {
    print("editor.actions.saveMapToFirestore()");
    final mapId = editor.state.mapNameController.text;
    if (mapId.isEmpty) {
      core.actions.setError("map id cannot be empty");
      return;
    }
    closeDialog();
    core.state.operationStatus.value = OperationStatus.Saving_Map;
    firestoreService.createMap(
        mapId: mapId,
        map: compile.compileGameToJson()
    ).whenComplete(core.actions.operationCompleted);
  }

  void loadMap(String name) async {
    closeDialog();
    state.mapNameController.text = name;
    core.state.operationStatus.value = OperationStatus.Loading_Map;
    final mapJson = await firestoreService
        .loadMap(name)
        .whenComplete(core.actions.operationCompleted)
    ;
    final jsonRows = mapJson['tiles'];
    isometric.tiles = mapJsonToTiles(jsonRows);
    isometric.refreshTileSize();
    final jsonEnvironment = mapJson['environment'];
    // state.environmentObjects.clear();
    // for (Json json in jsonEnvironment) {
    //   final x = json.getDouble('x');
    //   final y = json.getDouble('y');
    //   final type = parseObjectTypeFromString(json['type']);
    //   state.environmentObjects.add(StaticObject(x: x, y: y, type: type));
    // }

    isometric.minutes.value = mapJson[sceneFieldNames.startTime] / secondsPerHour;

    final List<Character> characters = [];
    for(Json json in mapJson['characters']){
      // final x = json.getDouble('x');
      // final y = json.getDouble('y');
      // final type = parseCharacterType(json['type']);
      // characters.add(Character(type: type, x: x, y: y));
    }

    state.items.clear();
    if (mapJson.containsKey(sceneFieldNames.items)){
      final List items = mapJson[sceneFieldNames.items];
      for(var i = 0; i < items.length; i += 3){
        state.items.add(
            Item(
                type: ItemType.values[items[i]],
                x: items[i + 1].toDouble(),
                y: items[i + 2].toDouble())
        );
      }
    }

    if (mapJson.containsKey(sceneFieldNames.playerSpawnPoints)) {
      final List spawnPoints = mapJson[sceneFieldNames.playerSpawnPoints];
      state.teamSpawnPoints.clear();
      for (var i = 0; i < spawnPoints.length; i += 2) {
         final x = (spawnPoints[i] as int).toDouble();
         final y = (spawnPoints[i + 1] as int).toDouble();
         state.teamSpawnPoints.add(Vector2(x, y));
      }
    }

    state.characters = characters;
    isometric.updateTileRender();
    isometric.refreshTileSize();
    engine.redrawCanvas();
  }

  void timeSpeedIncrease() {
    int currentIndex = state.timeSpeed.value.index;
    if (currentIndex < timeSpeeds.length - 1){
      state.timeSpeed.value = timeSpeeds[currentIndex + 1];
    }
  }

  void refreshSelected(){
    final sel = state.selected.value;
    state.selected.value = null;
    state.selected.value = sel;
  }

  void timeSpeedDecrease() {
    int currentIndex = state.timeSpeed.value.index;
    if (currentIndex > 0){
      state.timeSpeed.value = timeSpeeds[currentIndex - 1];
    }
  }
}

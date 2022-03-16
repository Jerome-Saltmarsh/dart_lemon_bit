import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/classes/Character.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:bleed_common/CharacterType.dart';
import 'package:bleed_common/ItemType.dart';
import 'package:bleed_common/SceneJson.dart';
import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/constants.dart';
import 'package:bleed_common/enums/ObjectType.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/parse.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:gamestream_flutter/utils/list_util.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:typedef/json.dart';

import 'compile.dart';
import 'enums.dart';
import 'scope.dart';


class EditorActions with EditorScope {

  final EditorCompile compile;
  EditorActions(this.compile);

  void addEnvironmentObject () {
    print("editor.actions.addEnvironmentObject()");
    state.environmentObjects.add(
        EnvironmentObject(
          x: mouseWorldX,
          y: mouseWorldY,
          type: state.objectType.value,
          radius: 0,
        )
    );
    if (state.objectType.value == ObjectType.Torch) {
      isometric.actions.resetLighting();
    }
    sortReversed(modules.isometric.state.environmentObjects, environmentObjectY);
    engine.redrawCanvas();
  }

  void setTile() {
    setTileAtMouse(state.tile.value);
  }

  void deleteSelected() {
    if (state.selected.value == null) return;
    isometric.state.environmentObjects.remove(state.selected.value);
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
        rows: isometric.state.totalRows.value,
        columns: isometric.state.totalColumns.value
    );
  }

  void play(){
    website.actions.connectToCustomGame(state.mapNameController.text);
  }

  void moveSelectedToMouse(){
    final selected = state.selected.value;
    if (selected == null) return;
    if (selected is EnvironmentObject){
      selected.move(mouseWorldX, mouseWorldY);
    } else{
      selected.x = mouseWorldX;
      selected.y = mouseWorldY;
    }
  }

  void newScene({
    int rows = 40,
    int columns = 40,
    Tile tile = Tile.Grass,
  }){
    print("editor.actions.newScene()");
    isometric.state.totalRows.value = rows;
    isometric.state.totalColumns.value = columns;
    isometric.state.maxColumn = columns;
    isometric.state.maxRow = rows;
    isometric.state.tiles.clear();
    editor.state.teamSpawnPoints.clear();
    editor.state.teamSpawnPoints.add(
       isometric.properties.mapCenter
    );

    editor.state.timeSpeed.value = TimeSpeed.Normal;
    isometric.state.minutes.value = config.defaultStartTime;
    editor.state.characters.clear();
    for (int row = 0; row < rows; row++) {
      List<Tile> columnTiles = [];
      for (int column = 0; column < columns; column++) {
        columnTiles.add(tile);
      }
      isometric.state.tiles.add(columnTiles);
    }
    game.crates.clear();
    isometric.state.particleEmitters.clear();
    isometric.state.environmentObjects.clear();
    game.collectables.clear();
    game.itemsTotal = 0;
    isometric.actions.updateTileRender();
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
    isometric.state.tiles = mapJsonToTiles(jsonRows);
    isometric.actions.refreshTileSize();
    final jsonEnvironment = mapJson['environment'];
    state.environmentObjects.clear();
    for (var json in jsonEnvironment) {
      final x = json.getDouble('x');
      final y = json.getDouble('y');
      final type = parseObjectTypeFromString(json['type']);
      state.environmentObjects.add(EnvironmentObject(x: x, y: y, type: type, radius: 25));
    }

    isometric.state.minutes.value = mapJson[sceneFieldNames.startTime] / secondsPerHour;

    final List<Character> characters = [];
    for(var json in mapJson['characters']){
      final x = json.getDouble('x');
      final y = json.getDouble('y');
      final type = parseCharacterType(json['type']);
      characters.add(Character(type: type, x: x, y: y));
    }

    state.items.clear();
    if (mapJson.containsKey(sceneFieldNames.items)){
      final List items = mapJson[sceneFieldNames.items];
      for(var i = 0; i < items.length; i += 3){
        state.items.add(
            Item(
                type: itemTypes[items[i]],
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
    isometric.actions.updateTileRender();
    isometric.actions.refreshTileSize();
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

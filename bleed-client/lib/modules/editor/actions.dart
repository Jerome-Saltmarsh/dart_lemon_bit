import 'package:bleed_client/actions.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/editor/mixin.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:lemon_engine/engine.dart';
import 'package:typedef/json.dart';

import 'enums.dart';


class EditorActions with EditorScope {

  void addEnvironmentObject ({
    required ObjectType type,
    required double x,
    required double y,
  }){
    modules.isometric.state.environmentObjects.add(EnvironmentObject(
      x: x,
      y: y,
      type: type,
      radius: 0,
    ));
    if (type == ObjectType.Torch) {
      isometric.actions.resetLighting();
    }
  }

  void deleteSelected() {
    if (state.selected.value == null) return;
    modules.isometric.state.environmentObjects.remove(state.selected.value);
    state.selected.value = null;
    engine.actions.redrawCanvas();
  }

  void clear() {
    newScene(
        rows: modules.isometric.state.totalRows,
        columns: modules.isometric.state.totalColumns
    );
  }

  void newScene({
    int rows = 40,
    int columns = 40,
    Tile tile = Tile.Grass,
  }){
    print("editor.actions.newScene()");
    modules.isometric.state.totalRows = rows;
    modules.isometric.state.totalColumns = columns;
    isometric.state.tiles.clear();
    editor.state.characters.clear();
    for (int row = 0; row < rows; row++) {
      List<Tile> columnTiles = [];
      for (int column = 0; column < columns; column++) {
        columnTiles.add(tile);
      }
      isometric.state.tiles.add(columnTiles);
    }
    game.crates.clear();
    game.particleEmitters.clear();
    modules.isometric.state.environmentObjects.clear();
    game.collectables.clear();
    game.items.clear();
    modules.isometric.actions.updateTileRender();
  }

  void startProcess(String value){
    print("editor.actions.startProcess('$value')");
    editor.state.process.value = value;
  }

  void endProcess(){
    print("editor.actions.processFinished('${editor.state.process.value}')");
    editor.state.process.value = "";
  }

  void endProcessAndCloseDialogs(){
    endProcess();
    closeDialog();
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
      actions.showErrorMessage("map id cannot be empty");
      return;
    }
    closeDialog();
    core.state.operationStatus.value = OperationStatus.Saving_Map;
    firestoreService.createMap(
        mapId: mapId,
        map: compileGameToJson()
    ).whenComplete(core.actions.operationCompleted);
  }

  void loadMapFromFirestore(String name) async {
    closeDialog();
    core.state.operationStatus.value = OperationStatus.Loading_Map;
    final mapJson = await firestoreService
        .loadMap(name)
        .whenComplete(core.actions.operationCompleted)
    ;
    final jsonRows = mapJson['tiles'];
    isometric.state.tiles = mapJsonToTiles(jsonRows);

    final jsonEnvironment = mapJson['environment'];
    modules.isometric.state.environmentObjects.clear();
    for(Json envJson in jsonEnvironment){
      final x = (envJson['x'] as int).toDouble();
      final y = (envJson['y'] as int).toDouble();
      final type = parseObjectTypeFromString(envJson['type']);
      modules.isometric.state.environmentObjects.add(EnvironmentObject(x: x, y: y, type: type, radius: 25));
    }

    final jsonMisc = mapJson['misc'];
    modules.isometric.state.time.value = jsonMisc['start-hour'] ?? 12;

    List<Character> characters = [];
    for(Json json in mapJson['characters']){
      final x = (json['x'] as int).toDouble();
      final y = (json['y'] as int).toDouble();
      final type = parseCharacterType(json['type']);
      characters.add(Character(type: type, x: x, y: y));
    }
    editor.state.characters = characters;

    modules.isometric.actions.updateTileRender();
    engine.actions.redrawCanvas();
  }

  void showErrorMessage(String message) {
    actions.showErrorMessage(message);
  }
}

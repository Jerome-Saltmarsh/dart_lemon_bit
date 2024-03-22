
import 'package:amulet_client/components/isometric_component.dart';
import 'package:amulet_client/enums/editor_dialog.dart';
import 'package:amulet_client/enums/emission_type.dart';
import 'package:amulet_common/src.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:lemon_watch/src.dart';
import '../../../classes/gameobject.dart';
import 'editor_tab.dart';


class IsometricEditor with IsometricComponent {

  final windowEnabledScene = WatchBool(false);
  final windowEnabledCanvasSize = WatchBool(false);
  final windowEnabledGenerate = WatchBool(false);

  final generateRows = WatchInt(50, min: 5, max: 200);
  final generateColumns = WatchInt(50, min: 5, max: 200);
  final generateHeight = WatchInt(8, min: 5, max: 20);
  final generateOctaves = WatchInt(8, min: 0, max: 100);
  final generateFrequency = WatchInt(1, min: 0, max: 100);

  final selectedMarkListValue = Watch(0);
  final selectedMarkNodeIndex = Watch(0);
  final selectedMarkListIndex = Watch(-1);
  final selectedMarkType = Watch(0);
  final selectedMarkSubType = Watch(0);

  final selectedKeyEntry = Watch<MapEntry<String, int>?>(null);

  final selectedSceneName = Watch<String?>(null);
  final gameObject = Watch<GameObject?>(null);
  final gameObjectSelectedType = Watch(0);
  final gameObjectSelectedSubType = Watch(0);
  final gameObjectSelectedHitable = Watch(true);
  final gameObjectSelectedGravity = Watch(true);
  final gameObjectSelectedInteractable = Watch(true);
  final gameObjectSelectedCollidable = Watch(true);
  final gameObjectSelectedFixed = Watch(true);
  final gameObjectSelectedCollectable = Watch(true);
  final gameObjectSelectedPhysical = Watch(true);
  final gameObjectSelectedAmount = Watch(0);
  final gameObjectSelectedParticleType = Watch(0);
  final gameObjectSelectedParticleSpawnRate = Watch(0);
  final gameObjectSelectedSpawnType = Watch(0);

  late final editorDialog = Watch<EditorDialog?>(
      null, onChanged: onChangedEditorDialog);
  late final editorTab = Watch(
      EditorTab.Nodes, onChanged: onChangedEditTab);
  late final nodeSelectedType = Watch<int>(
      0, onChanged: onChangedSelectedNodeType);
  final nodeSelectedOrientation = Watch(NodeOrientation.None);
  final nodeOrientationVisible = Watch(true);
  final nodeSelectedVariation = Watch(0);
  final isActiveEditTriggers = Watch(true);

  int get selectedIndex => nodeSelectedIndex.value;

  late final nodeSelectedIndex = Watch(0, clamp: (int value) {
    if (value < 0) return 0;
    if (value >= scene.totalNodes) return scene.totalNodes - 1;
    return value;
  }, onChanged: onChangedSelectedNodeIndex);

  IsometricEditor(){
    selectedKeyEntry.onChanged(onChangedSelectedKeyEntryIndex);
  }

  void update(){
    switch (editorTab.value){
      case EditorTab.Nodes:
        cameraCenterOnNodeSelectedIndex();
        break;
      case EditorTab.Objects:
        final selected = gameObject.value;
        if (selected != null){
          options.cameraEdit.copy(selected);
        }
        break;
      default:
        break;
    }
  }

  int get z => scene.convertNodeIndexToIndexZ(nodeSelectedIndex.value);

  int get row => scene.convertNodeIndexToIndexX(nodeSelectedIndex.value);

  int get column => scene.convertNodeIndexToIndexY(nodeSelectedIndex.value);

  set z(int value) {
    if (value < 0) return;
    if (value >= scene.totalZ) return;
    final difference = value - z;
    nodeSelectedIndex.value += difference * scene.area;
  }

  set row(int value) {
    if (value < 0) return;
    if (value >= scene.totalRows) return;
    final difference = value - row;
    nodeSelectedIndex.value += difference * scene.totalColumns;
  }

  set column(int value) {
    if (value < 0) return;
    if (value >= scene.totalColumns) return;
    nodeSelectedIndex.value += value - column;
  }

  late final paintType = Watch(NodeType.Brick, onChanged: onChangedPaintType);
  final paintOrientation = Watch(NodeOrientation.None);
  final controlsVisibleWeather = Watch(true);


  @override
  void onComponentReady() {
    scene.marksChangedNotifier.onChanged((t) {
      refreshSelectedMarkListValue();
    });

    selectedMarkListIndex.onChanged((index) {
      refreshSelectedMarkListValue();
    });

    selectedMarkListValue.onChanged((value) {
      if (value != -1){
        selectedMarkNodeIndex.value = value & 0xFFFF;
        selectedMarkType.value = (value >> 16) & 0xFF;
        selectedMarkSubType.value = (value >> 24) & 0xFF;
      } else {
        deselectMarkIndex();
      }
    });

    selectedMarkNodeIndex.onChanged((index) {
      if (index != -1){
        if (options.editing){
          camera.clearTarget();
          camera.setPositionIndex(index);
        }
        nodeSelectedIndex.value = index;
      }
    });
  }

  void refreshSelectedMarkListValue() {
    final index = selectedMarkListIndex.value;
    final marks = scene.marks;
    selectedMarkListValue.value =
      index >= 0 && index < marks.length
        ? marks[index]
        : -1;
  }

  double get posX => row * Node_Size + Node_Size_Half;

  double get posY => column * Node_Size + Node_Size_Half;

  double get posZ => z * Node_Height;
  
  bool get gameObjectSelected => gameObject.value != null;

  void onKeyPressed(PhysicalKeyboardKey key) {

    switch (key) {
      case PhysicalKeyboardKey.arrowUp:
        if (engine.keyPressedShiftLeft) {
          if (gameObjectSelected && editorTab.value == EditorTab.Objects) {
            translateSelectedGameObject(x: 0, y: 0, z: 1);
            return;
          }
          cursorZIncrease();
          return;
        }
        if (gameObjectSelected) {
          translateSelectedGameObject(x: -1, y: -1, z: 0);
          return;
        }
        cursorRowDecrease();
        return;
      case PhysicalKeyboardKey.arrowRight:
        if (gameObjectSelected && editorTab.value == EditorTab.Objects) {
          return translateSelectedGameObject(x: 1, y: -1, z: 0);
        }
        cursorColumnDecrease();
        break;
      case PhysicalKeyboardKey.arrowDown:
        if (engine.keyPressedShiftLeft) {
          if (gameObjectSelected && editorTab.value == EditorTab.Objects) {
            return translateSelectedGameObject(x: 0, y: 0, z: -1);
          }
          cursorZDecrease();
        } else {
          if (gameObjectSelected && editorTab.value == EditorTab.Objects) {
            return translateSelectedGameObject(x: 1, y: 1, z: 0);
          }
          cursorRowIncrease();
        }
        break;
      case PhysicalKeyboardKey.arrowLeft:
        if (gameObjectSelected && editorTab.value == EditorTab.Objects) {
          return translateSelectedGameObject(x: -1, y: 1, z: 0);
        }
        cursorColumnIncrease();
        break;
    }

    switch (editorTab.value){
      case EditorTab.Keys:
        onKeyPressedEditorTabKeys(key);
        return;
      case EditorTab.Objects:
        onKeyPressedEditorTabObjects(key);
        return;
      case EditorTab.Nodes:
        onKeyPressedEditorTabNodes(key);
        return;
      case EditorTab.Marks:
        onKeyPressedEditorMarks(key);
        return;
      default:
        return;
    }

    // switch (key) {
    //   case KeyCode.Arrow_Up:
    //     if (engine.keyPressedShiftLeft) {
    //       if (gameObjectSelected) {
    //         translateSelectedGameObject(x: 0, y: 0, z: 1);
    //         return;
    //       }
    //       cursorZIncrease();
    //       return;
    //     }
    //     if (gameObjectSelected) {
    //       translateSelectedGameObject(x: -1, y: -1, z: 0);
    //       return;
    //     }
    //     cursorRowDecrease();
    //     return;
    //   case KeyCode.Arrow_Right:
    //     if (gameObjectSelected) {
    //       return translateSelectedGameObject(x: 1, y: -1, z: 0);
    //     }
    //     cursorColumnDecrease();
    //     break;
    //   case KeyCode.Arrow_Down:
    //     if (engine.keyPressedShiftLeft) {
    //       if (gameObjectSelected) {
    //         return translateSelectedGameObject(x: 0, y: 0, z: -1);
    //       }
    //       cursorZDecrease();
    //     } else {
    //       if (gameObjectSelected) {
    //         return translateSelectedGameObject(x: 1, y: 1, z: 0);
    //       }
    //       cursorRowIncrease();
    //     }
    //     break;
    //   case KeyCode.Arrow_Left:
    //     if (gameObjectSelected) {
    //       return translateSelectedGameObject(x: -1, y: 1, z: 0);
    //     }
    //     cursorColumnIncrease();
    //     break;
    //   // case KeyCode.Digit_1:
    //   //   addMark(
    //   //     index: editor.nodeSelectedIndex.value,
    //   //     markType: MarkType.values[0],
    //   //   );
    //   //   break;
    //   // case KeyCode.Digit_2:
    //   //   addMark(
    //   //     index: editor.nodeSelectedIndex.value,
    //   //     markType: MarkType.values[1],
    //   //   );
    //   //   break;
    //   // case KeyCode.Digit_3:
    //   //   addMark(
    //   //     index: editor.nodeSelectedIndex.value,
    //   //     markType: MarkType.values[2],
    //   //   );
    //   //   break;
    //   // case KeyCode.Digit_4:
    //   //   addMark(
    //   //     index: editor.nodeSelectedIndex.value,
    //   //     markType: MarkType.values[3],
    //   //   );
    //   //   break;
    //   // case KeyCode.Digit_5:
    //   //   addMark(
    //   //     index: editor.nodeSelectedIndex.value,
    //   //     markType: MarkType.values[4],
    //   //   );
    //   //   break;
    //   // case KeyCode.Digit_6:
    //   //   addMark(
    //   //     index: editor.nodeSelectedIndex.value,
    //   //     markType: MarkType.values[5],
    //   //   );
    //   //   break;
    // }
  }

  void moveSelectedGameObjectToMouse() {
    if (gameObjectSelected) {
      sendGameObjectRequestMoveToMouse();
    }
  }

  void addMark({required int index, required int markType}){
    server.sendNetworkRequest(NetworkRequest.Scene, '${NetworkRequestScene.Add_Mark.index} $index $markType');
  }

  void refreshNodeSelectedIndex() {
    if (selectedIndex >= scene.nodeTypes.length){
      return;
    }

    nodeSelectedType.value = scene.nodeTypes[selectedIndex];
    nodeSelectedOrientation.value = scene.nodeOrientations[selectedIndex];
    nodeSelectedVariation.value = scene.nodeVariations[selectedIndex];
  }

  void translateSelectedGameObject({ double x = 0, double y = 0, double z = 0}) {
    assert (gameObjectSelected);
    return sendClientRequestGameObjectTranslate(
      tx: x,
      ty: y,
      tz: z,
    );
  }

  void actionToggleControlsVisibleWeather() {
    controlsVisibleWeather.value = !controlsVisibleWeather.value;
  }

  void setPaintOrientationNone() {
    paintOrientation.value = NodeOrientation.None;
  }

  void assignDefaultNodeOrientation(int nodeType) {
    paintOrientation.value = NodeType.getDefaultOrientation(nodeType);
  }

  void paintMouse() {
    selectMouseBlock();
    paint();
  }

  void selectMouseBlock() {
    io.mouseRaycast(selectBlock);
  }

  void selectMouseGameObject() {
    sendGameObjectRequestSelect();
  }

  void selectBlock(int z, int row, int column) {
    nodeSelectedIndex.value = scene.getIndexZRC(z, row, column);
  }

  void deleteGameObjectSelected() => sendGameObjectRequestDelete();

  void delete() {
    if (gameObjectSelected) {
      deleteGameObjectSelected();
      return;
    }

    if (editorTab.value == EditorTab.Marks){
      markDelete();
      return;
    }
    setNodeType(NodeType.Empty, NodeOrientation.None);
  }

  void setNodeType(int type, int orientation) =>
      setNode(
        index: nodeSelectedIndex.value,
        type: type,
        orientation: orientation,
      );

  void raise() {
    final nodeIndex = nodeSelectedIndex.value;
    if (nodeIndex <= scene.area) return;
    final nodeIndexBelow = nodeIndex - scene.area;
    setNode(
      index: nodeSelectedIndex.value,
      type: scene.nodeTypes[nodeIndexBelow],
      orientation: scene.nodeOrientations[nodeIndexBelow],
      variation: scene.nodeVariations[nodeIndexBelow]
    );
  }

  void selectPaintType() {
    paintType.value = nodeSelectedType.value;
    paintOrientation.value = nodeSelectedOrientation.value;
  }

  void paint({int? nodeType}) {
    if (nodeType == NodeType.Empty) {
      return delete();
    }

    if (nodeType == null) {
      nodeType = paintType.value;
    } else {
      paintType.value = nodeType;
    }

    var orientation = paintOrientation.value;

    if (!NodeType.supportsOrientation(nodeType, orientation)) {
      orientation = NodeType.getDefaultOrientation(nodeType);
    }

    return setNode(
      index: nodeSelectedIndex.value,
      type: nodeType,
      orientation: orientation,
    );
  }

  void cursorSetToPlayer() {
    if (!player.inBounds) return;
    nodeSelectedIndex.value = scene.getIndexPosition(player.position);
  }

  void cursorRowIncrease() => row++;

  void cursorRowDecrease() => row--;

  void cursorColumnIncrease() => column++;

  void cursorColumnDecrease() => column--;

  void cursorZIncrease() => z++;

  void cursorZDecrease() => z--;

  void selectSceneName(String value) {
    selectedSceneName.value = value;
  }

  void actionRecenterCamera() =>
      camera.cameraSetPositionGrid(
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

  void onChangedSelectedNodeIndex(int index) {
    refreshNodeSelectedIndex();
    cameraCenterOnNodeSelectedIndex();
    switch (editorTab.value){
      case EditorTab.Marks:
        deselectMarkIndex();
        break;
      default:
        break;
    }
  }

  void onChangedSelectedNodeType(int nodeType) =>
      nodeOrientationVisible.value = true;

  void onChangedEditorDialog(EditorDialog? value) { }

  void actionGameDialogShowSceneSave() =>
      editorDialog.value = EditorDialog.Scene_Save;

  void actionGameDialogClose() => editorDialog.value = null;

  void setTabNodes() => editorTab.value = EditorTab.Nodes;

  void onChangedEditTab(EditorTab editTab) => sendGameObjectRequestDeselect();

  void onMouseLeftClicked() {
    switch (editorTab.value) {
      case EditorTab.File:
        setTabNodes();
        selectMouseBlock();
        break;
      case EditorTab.Nodes:
        selectMouseBlock();
        actionRecenterCamera();
        break;
      case EditorTab.Objects:
        selectMouseGameObject();
        break;
      case EditorTab.Marks:
        selectMouseMark();
        break;
      case EditorTab.Keys:
        break;
    }
  }

  void sendClientRequestGameObjectTranslate({
    required double tx,
    required double ty,
    required double tz,
  }) => sendGameObjectRequest(
      IsometricEditorGameObjectRequest.Translate, '$tx $ty $tz');

  void sendGameObjectRequestDuplicate() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Duplicate);

  void sendGameObjectRequestSelect() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Select);

  void sendGameObjectRequestDeselect() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Deselect);

  void sendGameObjectRequestDelete() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Delete);

  void sendGameObjectRequestMoveToMouse() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Move_To_Mouse);

  void sendGameObjectRequestToggleHitable() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Hitable);

  void sendGameObjectRequestToggleGravity() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Gravity);

  void sendGameObjectRequestToggleCollidable() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Collidable);

  void sendGameObjectRequestToggleInteractable() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Interactable);

  void sendGameObjectRequestToggleFixed() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Fixed);

  void sendGameObjectRequestToggleCollectable() =>
      sendGameObjectRequest(
          IsometricEditorGameObjectRequest.Toggle_Collectable);

  void selectedGameObjectTogglePhysical() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Physical);

  // void selectedGameObjectTogglePersistable() =>
  //     sendGameObjectRequest(
  //         IsometricEditorGameObjectRequest.Toggle_Persistable);

  void actionAddGameObject(int type) =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Add,
          '${nodeSelectedIndex.value} $type');

  void sendGameObjectRequest(IsometricEditorGameObjectRequest gameObjectRequest,
      [dynamic message]) =>
      sendEditorRequest(
        NetworkRequestEdit.GameObject,
        '${gameObjectRequest.index} $message',
      );


  void loadScene(List<int> bytes) {
    // final package = Uint8List(bytes.length + 1);
    // package[0] = ClientRequest.Editor_Load_Scene;
    // for (var i = 0; i < bytes.length; i++){
    //   package[i + 1] = bytes[i];
    // }
    // gamestream.network.sink.add(package);
    sendEditorRequest(
      NetworkRequestEdit.Load_Scene,
      bytes.join(' '),
    );
  }

  void setNode({
    required int index,
    int? type,
    int? orientation,
    int? variation,
  }) =>
      server.sendNetworkRequest(
        NetworkRequest.Edit,
        NetworkRequestEdit.Set_Node.index,
        '--index $index',
        '${type != null ? '--type $type' : ''} '
        '${orientation != null ? '--orientation $orientation' : ''} '
        '${variation != null ? '--variation $variation' : ''}'
      );

  void downloadScene() =>
      sendEditorRequest(NetworkRequestEdit.Download);

  void clearScene() =>
      sendEditorRequest(NetworkRequestEdit.Clear_Scene);

  void toggleGameRunning() =>
      sendEditorRequest(NetworkRequestEdit.Toggle_Game_Running);

  void sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize request) =>
      sendEditorRequest(NetworkRequestEdit.Modify_Canvas_Size, request.index);

  void sendClientRequestEditGenerateScene({
    required int rows,
    required int columns,
    required int height,
    required int octaves,
    required int frequency,
  }) =>
      sendEditorRequest(
          NetworkRequestEdit.Generate_Scene,
          '$rows $columns $height $octaves $frequency'
      );

  void sendClientRequestEditSceneSetFloorTypeStone() =>
      sendClientRequestEditSceneSetFloorType(NodeType.Concrete);

  void sendClientRequestEditSceneSetFloorType(int nodeType) =>
      sendEditorRequest(NetworkRequestEdit.Scene_Set_Floor_Type, nodeType);

  void editSceneReset() =>
      sendEditorRequest(NetworkRequestEdit.Scene_Reset);

  void editSceneClearSpawnedAI() {
    sendEditorRequest(NetworkRequestEdit.Clear_Spawned);
  }

  void restoreGameObjects() {
    sendEditorRequest(NetworkRequestEdit.Restore_GameObjects);
  }

  void editSceneSpawnAI() =>
      sendEditorRequest(NetworkRequestEdit.Spawn_AI);

  void saveScene() => sendEditorRequest(NetworkRequestEdit.Save);

  void sendEditorRequest(NetworkRequestEdit request, [dynamic message]) =>
      server.sendNetworkRequest(
        NetworkRequest.Edit,
        '${request.index} $message',
      );

  void uploadScene() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      dialogTitle: 'Load Scene',
      type: FileType.custom,
      allowedExtensions: ['scene'],
    );
    if (result == null) {
      actions.showMessage('result == null');
      return;
    }
    final sceneBytes = result.files[0].bytes;
    if (sceneBytes == null) {
      actions.showMessage('contents == null');
      return;
    }
    loadScene(sceneBytes);
  }

  void exportSceneToJson() {

  }

  void generateScene() =>
      sendClientRequestEditGenerateScene(
        rows: generateRows.value,
        columns: generateColumns.value,
        height: generateHeight.value,
        octaves: generateOctaves.value,
        frequency: generateFrequency.value,
      );

  void markAdd(int value) =>
      server.sendArgs2(
        NetworkRequest.Edit,
        NetworkRequestEdit.Mark_Add.index,
        value,
      );

  void markDelete() =>
      server.sendNetworkRequest(
        NetworkRequest.Edit,
        NetworkRequestEdit.Mark_Delete.index,
      );

  void selectMarkByIndex(int index) =>
      server.sendArgs2(
        NetworkRequest.Edit,
        NetworkRequestEdit.Mark_Select.index,
        index,
      );

  void onPressedMarkType(int markType) =>
      server.sendArgs2(
        NetworkRequest.Edit,
        NetworkRequestEdit.Mark_Set_Type.index,
        markType,
      );

  void selectMouseMark() {
    final nearestIndex = scene.findNearestMark(
      x: mouse.positionX,
      y: mouse.positionY,
      z: mouse.positionZ,
      minRadius: 100.0,
    );
    if (nearestIndex != -1) {
      selectMarkByIndex(nearestIndex);
    }
  }

  void onChangedSelectedKeyEntryIndex(MapEntry<String, int>? keyEntry) {
    print('onChangedSelectedKeyEntryIndex($keyEntry)');
    if (keyEntry == null){
      return;
    }
    nodeSelectedIndex.value = keyEntry.value;
    cameraCenterOnNodeSelectedIndex();
  }

  void cameraCenterOnNodeSelectedIndex() {
    final index = nodeSelectedIndex.value;
    final cameraEdit = options.cameraEdit;
    cameraEdit.x = scene.getIndexPositionX(index);
    cameraEdit.y = scene.getIndexPositionY(index);
    cameraEdit.z = scene.getIndexPositionZ(index);
  }

  void deleteSelectedKeyEntry(){
     final selected = selectedKeyEntry.value;
     if (selected == null){
       return;
     }
     deleteKeyByName(selected.key);
     selectedKeyEntry.value = null;
  }

  void deleteKeyByName(String name){
      server.sendNetworkRequest(
          NetworkRequest.Edit,
          NetworkRequestEdit.Delete_Key.index,
          name,
      );
  }

  void moveSelectedKeyEntryToNodeSelected() {
    final selectedKey = selectedKeyEntry.value;
    if (selectedKey == null){
      return;
    }
    moveKeyToIndex(
      name: selectedKey.key,
      index: nodeSelectedIndex.value,
    );
  }

  void moveKeyToIndex({required String name, required int index}) {
    server.sendNetworkRequest(
      NetworkRequest.Edit,
      NetworkRequestEdit.Move_Key.index,
      '--name $name --index $index',
    );
  }

  void renameKey({required String from, required String to}){
    server.sendNetworkRequest(
      NetworkRequest.Edit,
      NetworkRequestEdit.Rename_Key.index,
      '--from $from --to $to',
    );
  }

  void onMouseRightClicked() {
    switch (editorTab.value){
      case EditorTab.Objects:
        sendGameObjectRequestDeselect();
        break;
      case EditorTab.Marks:
        deselectMarkIndex();
        break;
      default:
        break;
    }
  }

  void deselectMarkIndex() =>
      server.sendRequest(
          NetworkRequest.Edit,
          NetworkRequestEdit.Mark_Deselect_Index.index,
      );

  void onKeyPressedEditorTabKeys(PhysicalKeyboardKey key) {
    switch (key){
      case PhysicalKeyboardKey.keyG:
        moveSelectedKeyEntryToNodeSelected();
        break;
      default:
        break;
    }
  }

  void onKeyPressedEditorTabObjects(PhysicalKeyboardKey key) {
    switch (key){
      case PhysicalKeyboardKey.arrowUp:
        if (engine.keyPressedShiftLeft) {
          if (gameObjectSelected) {
            translateSelectedGameObject(x: 0, y: 0, z: 1);
            return;
          }
        }
        if (gameObjectSelected) {
          translateSelectedGameObject(x: -1, y: -1, z: 0);
        }
        break;

      case PhysicalKeyboardKey.keyD:
        sendGameObjectRequestDuplicate();
      case PhysicalKeyboardKey.keyG:
        moveSelectedGameObjectToMouse();
        break;
      case PhysicalKeyboardKey.delete:
        deleteGameObjectSelected();
        break;
      default:
        break;
    }
  }

  void onKeyPressedEditorTabNodes(PhysicalKeyboardKey key) {
    switch(key){
      case PhysicalKeyboardKey.delete:
        delete();
        break;
      case PhysicalKeyboardKey.keyF:
        paint();
        break;
      case PhysicalKeyboardKey.keyE:
        copyBelow();
        break;
      case PhysicalKeyboardKey.keyR:
        selectPaintType();
        break;
      case PhysicalKeyboardKey.keyG:
        cameraCenterOnNodeSelectedIndex();
        break;
      case PhysicalKeyboardKey.digit1:
        setNode(index: selectedIndex, variation: 0);
        break;
      case PhysicalKeyboardKey.digit2:
        setNode(index: selectedIndex, variation: 1);
        break;
      case PhysicalKeyboardKey.digit3:
        setNode(index: selectedIndex, variation: 2);
        break;
      case PhysicalKeyboardKey.digit4:
        setNode(index: selectedIndex, variation: 3);
        break;
      case PhysicalKeyboardKey.digit5:
        setNode(index: selectedIndex, variation: 4);
        break;
      case PhysicalKeyboardKey.digit6:
        setNode(index: selectedIndex, variation: 5);
        break;
      case PhysicalKeyboardKey.digit7:
        setNode(index: selectedIndex, variation: 6);
        break;
      default:
        break;
    }

  }

  void onKeyPressedEditorMarks(PhysicalKeyboardKey key) {
    switch (key){
      case PhysicalKeyboardKey.digit1:
        addMark(
          index: editor.nodeSelectedIndex.value,
          markType: MarkType.values[0],
        );
        break;
      case PhysicalKeyboardKey.digit2:
        addMark(
          index: editor.nodeSelectedIndex.value,
          markType: MarkType.values[1],
        );
        break;
      case PhysicalKeyboardKey.digit3:
        addMark(
          index: editor.nodeSelectedIndex.value,
          markType: MarkType.values[2],
        );
        break;
      case PhysicalKeyboardKey.digit4:
        addMark(
          index: editor.nodeSelectedIndex.value,
          markType: MarkType.values[3],
        );
        break;
      case PhysicalKeyboardKey.digit5:
        addMark(
          index: editor.nodeSelectedIndex.value,
          markType: MarkType.values[4],
        );
        break;
      case PhysicalKeyboardKey.digit6:
        addMark(
          index: editor.nodeSelectedIndex.value,
          markType: MarkType.values[5],
        );
        break;
    }
  }

  void randomize() =>
      server.sendNetworkRequest(
          NetworkRequest.Edit,
          NetworkRequestEdit.Randomize.index,
      );

  void copyBelow() {
    final indexBelow = nodeSelectedIndex.value - scene.area;
    if (indexBelow < 0){
      return;
    }
    setNode(
      index: nodeSelectedIndex.value,
      type: scene.nodeTypes[indexBelow],
      orientation: scene.nodeOrientations[indexBelow],
    );
  }
}
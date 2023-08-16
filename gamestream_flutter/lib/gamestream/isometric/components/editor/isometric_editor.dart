
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/library.dart';

import '../../../../isometric/classes/gameobject.dart';
import '../../enums/editor_dialog.dart';
import '../../enums/emission_type.dart';
import 'isometric_editor_tab.dart';


class IsometricEditor with IsometricComponent {

  final windowEnabledScene = Watch(false);
  final windowEnabledCanvasSize = Watch(false);
  final windowEnabledGenerate = WatchBool(false);

  final generateRows = WatchInt(50, min: 5, max: 200);
  final generateColumns = WatchInt(50, min: 5, max: 200);
  final generateHeight = WatchInt(8, min: 5, max: 20);
  final generateOctaves = WatchInt(8, min: 0, max: 100);
  final generateFrequency = WatchInt(1, min: 0, max: 100);

  final selectedMarkListValue = Watch(0);
  final selectedMarkNodeIndex = Watch(0);
  final selectedMarkListIndex = Watch(0);
  final selectedMarkType = Watch(0);

  final selectedSceneName = Watch<String?>(null);
  final gameObject = Watch<GameObject?>(null);
  final gameObjectSelected = Watch(false);
  final gameObjectSelectedType = Watch(0);
  final gameObjectSelectedSubType = Watch(0);
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

  late final gameObjectSelectedEmissionIntensity = Watch(
      1.0, onChanged: (double value) {
    gameObject.value?.emissionIntensity = value;
  });

  late final editorDialog = Watch<EditorDialog?>(
      null, onChanged: onChangedEditorDialog);
  late final editTab = Watch(
      IsometricEditorTab.Grid, onChanged: onChangedEditTab);
  late final nodeSelectedType = Watch<int>(
      0, onChanged: onChangedSelectedNodeType);
  final nodeSelectedOrientation = Watch(NodeOrientation.None);
  final nodeOrientationVisible = Watch(true);
  final isActiveEditTriggers = Watch(true);

  late var nodeSelectedIndex = Watch(0, clamp: (int value) {
    if (value < 0) return 0;
    if (value >= scene.totalNodes) return scene.totalNodes - 1;
    return value;
  }, onChanged: onChangedSelectedNodeIndex);

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
      selectedMarkNodeIndex.value = value & 0xFFFF;
      selectedMarkType.value = (value >> 16) & 0xFF;
    });

    selectedMarkNodeIndex.onChanged((index) {
      camera.clearTarget();
      camera.setPositionIndex(index);
    });
  }

  void refreshSelectedMarkListValue() {
    selectedMarkListValue.value = scene.marks[selectedMarkListIndex.value];
  }

  double get posX => row * Node_Size + Node_Size_Half;

  double get posY => column * Node_Size + Node_Size_Half;

  double get posZ => z * Node_Height;


  void onKeyPressedModeEdit(int key) {
    switch (key) {
      case KeyCode.V:
        sendGameObjectRequestDuplicate();
        break;
      case KeyCode.F:
        paint();
        break;
      case KeyCode.G:
        if (gameObjectSelected.value) {
          sendGameObjectRequestMoveToMouse();
        } else {
          camera.cameraSetPositionGrid(row, column, z);
        }
        break;
      case KeyCode.R:
        selectPaintType();
        break;
      case KeyCode.Arrow_Up:
        if (engine.keyPressedShiftLeft) {
          if (gameObjectSelected.value) {
            translate(x: 0, y: 0, z: 1);
            return;
          }
          cursorZIncrease();
          return;
        }
        if (gameObjectSelected.value) {
          translate(x: -1, y: -1, z: 0);
          return;
        }
        cursorRowDecrease();
        return;
      case KeyCode.Arrow_Right:
        if (gameObjectSelected.value) {
          return translate(x: 1, y: -1, z: 0);
        }
        cursorColumnDecrease();
        break;
      case KeyCode.Arrow_Down:
        if (engine.keyPressedShiftLeft) {
          if (gameObjectSelected.value) {
            return translate(x: 0, y: 0, z: -1);
          }
          cursorZDecrease();
        } else {
          if (gameObjectSelected.value) {
            return translate(x: 1, y: 1, z: 0);
          }
          cursorRowIncrease();
        }
        break;
      case KeyCode.Arrow_Left:
        if (gameObjectSelected.value) {
          return translate(x: -1, y: 1, z: 0);
        }
        cursorColumnIncrease();
        break;
    }
  }


  void refreshNodeSelectedIndex() {
    nodeSelectedType.value = scene.nodeTypes[nodeSelectedIndex.value];
    nodeSelectedOrientation.value =
    scene.nodeOrientations[nodeSelectedIndex.value];
  }

  void deselectGameObject() {
    sendGameObjectRequestDeselect();
  }

  void translate({ double x = 0, double y = 0, double z = 0}) {
    assert (gameObjectSelected.value);
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
    paint(selectPlayerIfPlay: false);
  }

  void selectMouseBlock() {
    io.mouseRaycast(selectBlock);
  }

  void selectMouseGameObject() {
    sendGameObjectRequestSelect();
  }

  void paintTorch() {
    paint(nodeType: NodeType.Torch);
  }

  void paintTree() {
    paint(nodeType: NodeType.Tree_Bottom);
  }

  void paintLongGrass() {
    paint(nodeType: NodeType.Grass_Long);
  }

  void paintBricks() {
    paint(nodeType: NodeType.Brick);
  }

  void paintGrass() {
    paint(nodeType: NodeType.Grass);
  }

  void paintWater() {
    paint(nodeType: NodeType.Water);
  }

  void selectBlock(int z, int row, int column) {
    nodeSelectedIndex.value = scene.getIndexZRC(z, row, column);
  }

  void deleteGameObjectSelected() {
    sendGameObjectRequestDelete();
  }

  void cameraCenterSelectedObject() =>
      engine.cameraCenter(
        gameObject.value!.renderX,
        gameObject.value!.renderY,
      );

  void delete() {
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

  void raise() {
    final nodeIndex = nodeSelectedIndex.value;
    if (nodeIndex <= scene.area) return;
    final nodeIndexBelow = nodeIndex - scene.area;
    sendClientRequestSetBlock(
      index: nodeSelectedIndex.value,
      type: scene.nodeTypes[nodeIndexBelow],
      orientation: scene.nodeOrientations[nodeIndexBelow],
    );
  }

  void selectPaintType() {
    paintType.value = nodeSelectedType.value;
    paintOrientation.value = nodeSelectedOrientation.value;
  }

  void paint({int? nodeType, bool selectPlayerIfPlay = true}) {
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

    return sendClientRequestSetBlock(
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
    nodeSelectedOrientation.value = scene.nodeOrientations[index];
    nodeSelectedType.value = scene.nodeTypes[index];
    gameObjectSelected.value = false;
    refreshNodeSelectedIndex();
    deselectGameObject();
  }

  void onChangedSelectedNodeType(int nodeType) {
    nodeOrientationVisible.value = true;
  }

  void onChangedEditorDialog(EditorDialog? value) {
    if (value == EditorDialog.Scene_Load) {

    }
  }

  void actionGameDialogShowSceneSave() {
    editorDialog.value = EditorDialog.Scene_Save;
  }

  void actionGameDialogClose() {
    editorDialog.value = null;
  }

  void setTabGrid() {
    editTab.value = IsometricEditorTab.Grid;
  }

  // EVENTS

  void onChangedEditTab(IsometricEditorTab editTab) {
    deselectGameObject();
  }

  void setSelectedObjectedIntensity(double value) {
    gameObject.value?.emissionIntensity = value;
  }

  void onMouseLeftClicked() {
    switch (editTab.value) {
      case IsometricEditorTab.File:
        setTabGrid();
        selectMouseBlock();
        break;
      case IsometricEditorTab.Grid:
        selectMouseBlock();
        actionRecenterCamera();
        break;
      case IsometricEditorTab.Objects:
        selectMouseGameObject();
        break;
      case IsometricEditorTab.Marks:
        selectMouseMark();
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

  void sendGameObjectRequestToggleStrikable() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Strikable);

  void sendGameObjectRequestToggleGravity() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Gravity);

  void sendGameObjectRequestToggleFixed() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Fixed);

  void sendGameObjectRequestToggleCollectable() =>
      sendGameObjectRequest(
          IsometricEditorGameObjectRequest.Toggle_Collectable);

  void selectedGameObjectTogglePhysical() =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Toggle_Physical);

  void selectedGameObjectTogglePersistable() =>
      sendGameObjectRequest(
          IsometricEditorGameObjectRequest.Toggle_Persistable);

  void actionAddGameObject(int type) =>
      sendGameObjectRequest(IsometricEditorGameObjectRequest.Add,
          '${nodeSelectedIndex.value} $type');

  void sendGameObjectRequest(IsometricEditorGameObjectRequest gameObjectRequest,
      [dynamic message]) =>
      sendEditorRequest(
        EditorRequest.GameObject,
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
      EditorRequest.Load_Scene,
      bytes.join(' '),
    );
  }

  void sendClientRequestSetBlock({
    required int index,
    required int type,
    required int orientation,
  }) =>
      sendEditorRequest(
        EditorRequest.Set_Node,
        '$index $type $orientation',
      );

  void downloadScene() =>
      sendEditorRequest(EditorRequest.Download);

  void toggleGameRunning() =>
      sendEditorRequest(EditorRequest.Toggle_Game_Running);

  void sendClientRequestModifyCanvasSize(RequestModifyCanvasSize request) =>
      sendEditorRequest(EditorRequest.Modify_Canvas_Size, request.index);

  void sendClientRequestEditGenerateScene({
    required int rows,
    required int columns,
    required int height,
    required int octaves,
    required int frequency,
  }) =>
      sendEditorRequest(
          EditorRequest.Generate_Scene,
          '$rows $columns $height $octaves $frequency'
      );

  void sendClientRequestEditSceneSetFloorTypeStone() =>
      sendClientRequestEditSceneSetFloorType(NodeType.Concrete);

  void sendClientRequestEditSceneSetFloorType(int nodeType) =>
      sendEditorRequest(EditorRequest.Scene_Set_Floor_Type, nodeType);

  void editSceneReset() =>
      sendEditorRequest(EditorRequest.Scene_Reset);

  void editSceneClearSpawnedAI() {
    sendEditorRequest(EditorRequest.Clear_Spawned);
  }

  void editSceneSpawnAI() =>
      sendEditorRequest(EditorRequest.Spawn_AI);

  void saveScene() => sendEditorRequest(EditorRequest.Save);

  void sendEditorRequest(EditorRequest request, [dynamic message]) =>
      network.send(
        ClientRequest.Editor_Request,
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
      action.showMessage('result == null');
      return;
    }
    final sceneBytes = result.files[0].bytes;
    if (sceneBytes == null) {
      action.showMessage('contents == null');
      return;
    }
    loadScene(sceneBytes);
  }

  void toggleWindowEnabledScene() {
    windowEnabledScene.value = !windowEnabledScene.value;
  }

  void toggleWindowEnabledCanvasSize() {
    windowEnabledCanvasSize.value = !windowEnabledCanvasSize.value;
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
      network.sendArgs2(
        ClientRequest.Editor_Request,
        EditorRequest.Mark_Add.index,
        value,
      );

  void markDelete() =>
      network.send(
        ClientRequest.Editor_Request,
        EditorRequest.Mark_Delete.index,
      );

  void markSelect(int index) =>
      network.sendArgs2(
        ClientRequest.Editor_Request,
        EditorRequest.Mark_Select.index,
        index,
      );

  void markSetType(int markType) =>
      network.sendArgs2(
        ClientRequest.Editor_Request,
        EditorRequest.Mark_Set_Type.index,
        markType,
      );

  void selectMouseMark() {
    final nearestIndex = scene.findNearestMark(
      x: mouse.positionX,
      y: mouse.positionY,
      z: mouse.positionZ,
      minRadius: 50.0,
    );
    if (nearestIndex != -1) {
      markSelect(nearestIndex);
    }
  }
}
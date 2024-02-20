import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:lemon_bit/src.dart';
import 'package:lemon_byte/src.dart';

import '../../common/src.dart';
import 'gameobject.dart';
import 'scene.dart';

class SceneReader extends ByteReader {

  static final decoder = ZLibDecoder();
  static final _instance = SceneReader();

  var gameObjectsId = 0;
  var totalZ = 0;
  var totalRows = 0;
  var totalColumns = 0;
  var nodeTypes = Uint8List(0);
  var variations = Uint8List(0);
  var nodeOrientations = Uint8List(0);
  var playerSpawnPoints = Uint16List(0);
  var spawnPoints = Uint16List(0);
  var marks = <int>[];
  var keys = <String, int> {};
  var gameObjects = <GameObject>[];

  static Scene readScene(Uint8List bytes, {int startIndex = 0}) =>
      _instance._readScene(bytes, startIndex: startIndex);

  Scene _readScene(Uint8List bytes, {int startIndex = 0}){
    index = startIndex;
    totalColumns = 0;
    totalRows = 0;
    totalColumns = 0;
    variations = Uint8List(0);
    nodeTypes = Uint8List(0);
    nodeOrientations = Uint8List(0);
    playerSpawnPoints = Uint16List(0);
    spawnPoints = Uint16List(0);
    gameObjects = <GameObject>[];
    values = bytes;
    readLoop();

    final scene = Scene(
      name: 'test',
      nodeTypes: nodeTypes,
      nodeOrientations: nodeOrientations,
      height: totalZ,
      rows: totalRows,
      columns: totalColumns,
      gameObjects: gameObjects,
      variations: variations,
      marks: marks,
      keys: keys,
      locations: {},
    );

    for (final mark in marks) {
      final markType = MarkType.getType(mark);
      if (markType == MarkType.Rune){
        final markIndex = MarkType.getIndex(mark);
        gameObjects.add(GameObject(
          x: scene.getIndexX(markIndex),
          y: scene.getIndexY(markIndex),
          z: scene.getIndexZ(markIndex),
          team: TeamType.Neutral,
          itemType: ItemType.Object,
          subType: GameObjectType.Rune,
          id: gameObjectsId++,
        )
          ..persistable = false
          ..fixed = true
          ..collectable = false
          ..interactable = true
        );
      }
    }
    return scene;
  }

  void readLoop() {
    while (index < values.length){
      final scenePart = readByte();
      switch (scenePart){
        case ScenePart.Nodes:
          readNodes();
          break;
        case ScenePart.GameObjects:
          readGameObjects();
          break;
        case ScenePart.Marks:
          readMarks();
          break;
        case ScenePart.Keys:
          readKeys();
          break;
        case ScenePart.Variations:
          readVariations();
          break;
        case ScenePart.End:
          return;
        default:
          throw Exception("could not read scene. index: $index");
      }
    }
  }

  void readGameObjects() {
    gameObjects.clear();
    final total = readUInt16();
    for (var i = 0; i < total; i++){
      final type = readByte();
      final subType = readByte();
      final team = readByte();
      final properties = readByte();

      final collidable = readBitFromByte(properties, 0);
      final collectable = readBitFromByte(properties, 1);
      final fixed = readBitFromByte(properties, 2);
      final gravity = readBitFromByte(properties, 3);
      final hitable = readBitFromByte(properties, 4);
      final physical = readBitFromByte(properties, 5);
      final interactable = readBitFromByte(properties, 6);
      final destroyable = readBitFromByte(properties, 7);

      final x = readUInt16().toDouble();
      final y = readUInt16().toDouble();
      final z = readUInt16().toDouble();
      gameObjects.add(
          GameObject(
            x: x,
            y: y,
            z: z,
            itemType: type,
            subType: subType,
            id: gameObjectsId++,
            team: team,
          )
            ..collidable = collidable
            ..collectable = collectable
            ..fixed = fixed
            ..gravity = gravity
            ..hitable = hitable
            ..physical = physical
            ..interactable = interactable
            ..destroyable = destroyable
            ..persistable = true
      );
    }
  }

  void readMarks(){
    final length = readUInt16();
    marks = readUint32List(length).toList(growable: true);
  }

  void readKeys(){
    final length = readUInt16();
    keys = {};
    for (var i = 0; i < length; i++){
      final name = readString();
      final index = readUInt16();
      keys[name] = index;
    }
  }

  void readNodes() {
    totalZ = readUInt16();
    totalRows = readUInt16();
    totalColumns = readUInt16();
    final compressedNodeTypeLength = readUInt24();
    final compressedNodeOrientationLength = readUInt24();
    final compressedNodeTypes = readUint8List(compressedNodeTypeLength);
    final compressedNodeOrientations = readUint8List(
        compressedNodeOrientationLength
    );
    nodeTypes = Uint8List.fromList(decoder.decodeBytes(compressedNodeTypes));
    nodeOrientations = Uint8List.fromList(decoder.decodeBytes(compressedNodeOrientations));
  }

  void readVariations(){
    final length = readUInt24();
    final compressedValues = readUint8List(length);
    variations = Uint8List.fromList(decoder.decodeBytes(compressedValues));
  }
}
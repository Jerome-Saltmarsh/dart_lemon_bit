
import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/classes/sprite2.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/src.dart';
import 'classes/sprite_group.dart';
import 'render/classes/sprite_group2.dart';
import 'render/types/animation_mode.dart';
import 'types/sprite_group_type.dart';


class IsometricImages with IsometricComponent {

  var imagesCached = false;

  final totalImages = Watch(0);
  final totalImagesLoaded = Watch(0);
  final values = <Image>[];
  final _completerImages = Completer();

  final spriteGroup2ArmsLeft = <int, SpriteGroup2> {};
  final spriteGroup2ArmsRight = <int, SpriteGroup2> {};
  final spriteGroup2Body = <int, SpriteGroup2> {};
  final spriteGroup2BodyArms = <int, SpriteGroup2> {};
  final spriteGroup2HandsLeft = <int, SpriteGroup2> {};
  final spriteGroup2HandsRight = <int, SpriteGroup2> {};
  final spriteGroup2Heads = <int, SpriteGroup2> {};
  final spriteGroup2Helms = <int, SpriteGroup2> {};
  final spriteGroup2Legs = <int, SpriteGroup2> {};
  final spriteGroup2Shadow = <int, SpriteGroup2> {};
  final spriteGroup2Torso = <int, SpriteGroup2> {};
  final spriteGroup2Weapons = <int, SpriteGroup2> {};

  late final SpriteGroup2 spriteGroup2KidShadow;
  late final SpriteGroup2 fallenSpriteGroup2;
  late final Sprite2 flame0;
  late final Sprite2 flame1;
  late final Sprite2 flame2;
  late final Sprite2 rainFalling;

  late final spriteGroup2Types = {
    SpriteGroupType.Arms_Left: spriteGroup2ArmsLeft,
    SpriteGroupType.Arms_Right: spriteGroup2ArmsRight,
    SpriteGroupType.Body: spriteGroup2Body,
    SpriteGroupType.Body_Arms: spriteGroup2BodyArms,
    SpriteGroupType.Hands_Left: spriteGroup2HandsLeft,
    SpriteGroupType.Hands_Right: spriteGroup2HandsRight,
    SpriteGroupType.Heads: spriteGroup2Heads,
    SpriteGroupType.Helms: spriteGroup2Helms,
    SpriteGroupType.Legs: spriteGroup2Legs,
    SpriteGroupType.Shadow: spriteGroup2Shadow,
    SpriteGroupType.Torso: spriteGroup2Torso,
    SpriteGroupType.Weapons: spriteGroup2Weapons,
  };

  late final SpriteGroup2 spriteGroup2Empty;
  late final SpriteGroup spriteGroupEmpty;

  late final Sprite spriteEmpty;
  late final dstEmpty = Uint16List(0);

  late final Image empty;
  late final Image shades;
  late final Image pixel;
  late final Image atlas_projectiles;
  late final Image zombie;
  late final Image zombie_shadow;
  late final Image character_dog;
  late final Image atlas_particles;
  late final Image atlas_helms;
  late final Image atlas_hands;
  late final Image atlas_body;
  late final Image atlas_legs;
  late final Image atlas_gameobjects;
  late final Image atlas_gameobjects_transparent;
  late final Image atlas_nodes;
  late final Image atlas_nodes_transparent;
  late final Image atlas_characters;
  late final Image atlas_icons;
  late final Image atlas_consumables;
  late final Image atlas_treasures;
  late final Image atlas_nodes_mini;
  late final Image atlas_weapons;
  late final Image atlas_talents;
  late final Image sprite_stars;
  late final Image sprite_shield;
  late final Image square;
  late final Image template_spinning;

  late final Sprite2 emptySprite2;

  late final Map<int, Image> itemTypeAtlases;

  @override
  Future onComponentInit(SharedPreferences sharedPreferences) async {
    print('isometric.images.onComponentInitialize()');

    empty = await loadPng('empty');
    loadPng('shades').then((value) => shades = value);
    loadPng('square').then((value) => square = value);
    loadPng('atlas_nodes').then((value) => atlas_nodes = value);
    loadPng('atlas_characters').then((value) => atlas_characters = value);
    loadPng('atlas_zombie').then((value) => zombie = value);
    loadPng('atlas_zombie_shadow').then((value) => zombie_shadow = value);
    loadPng('atlas_gameobjects').then((value) => atlas_gameobjects = value);
    loadPng('atlas_gameobjects_transparent').then((value) => atlas_gameobjects_transparent = value);
    loadPng('atlas_particles').then((value) => atlas_particles = value);
    loadPng('atlas_projectiles').then((value) => atlas_projectiles = value);
    loadPng('atlas_nodes_transparent').then((value) => atlas_nodes_transparent = value);
    loadPng('atlas_nodes_mini').then((value) => atlas_nodes_mini = value);
    loadPng('atlas_weapons').then((value) => atlas_weapons = value);
    loadPng('atlas_talents').then((value) => atlas_talents = value);
    loadPng('atlas_icons').then((value) => atlas_icons = value);
    loadPng('atlas_consumables').then((value) => atlas_consumables = value);
    loadPng('atlas_treasures').then((value) => atlas_treasures = value);
    loadPng('atlas_helms').then((value) => atlas_helms = value);
    loadPng('atlas_hands').then((value) => atlas_hands = value);
    loadPng('atlas_body').then((value) => atlas_body = value);
    loadPng('atlas_legs').then((value) => atlas_legs = value);

    // loadPng('characters/fallen').then((value) => character_fallen = value);
    loadPng('character-dog').then((value) => character_dog = value);
    loadPng('sprites/sprite-stars').then((value) => sprite_stars = value);
    loadPng('sprites/sprite-shield').then((value) => sprite_shield = value);

    emptySprite2 = Sprite2(
        image: empty,
        values: Float32List(0),
        rows: 0,
        columns: 0,
        mode: 0,
        srcWidth: 0,
        srcHeight: 0,
    );

    totalImagesLoaded.onChanged((totalImagesLoaded) {
      if (totalImagesLoaded < totalImages.value)
        return;

      _completerImages.complete(true);
    });

    spriteEmpty = Sprite(
        image: empty,
        values: Float32List(0),
        width: 0,
        height: 0,
        rows: 0,
        columns: 0,
        y: 0,
        mode: AnimationMode.Single,
    );

    spriteGroupEmpty = SpriteGroup(
      idle: spriteEmpty,
      running: spriteEmpty,
      strike: spriteEmpty,
      hurt: spriteEmpty,
      dead: spriteEmpty,
      fire: spriteEmpty,
      change: spriteEmpty,
    );

    spriteGroup2Empty = SpriteGroup2(
        idle: emptySprite2,
        running: emptySprite2,
        change: emptySprite2,
        dead: emptySprite2,
        fire: emptySprite2,
        strike: emptySprite2,
        hurt: emptySprite2,
    );


    spriteGroup2HandsLeft[HandType.None] = spriteGroup2Empty;
    spriteGroup2HandsRight[HandType.None] = spriteGroup2Empty;
    spriteGroup2Weapons[WeaponType.Unarmed] = spriteGroup2Empty;
    spriteGroup2Helms[HelmType.None] = spriteGroup2Empty;
    spriteGroup2Body[BodyType.None] = spriteGroup2Empty;
    spriteGroup2Legs[LegType.None] = spriteGroup2Empty;
    spriteGroup2BodyArms[BodyType.None] = spriteGroup2Empty;

    loadSpriteGroup2(type: SpriteGroupType.Arms_Left, subType: ArmType.regular, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Arms_Right, subType: ArmType.regular, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Body, subType: BodyType.Shirt_Blue, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Body_Arms, subType: BodyType.Shirt_Blue, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Hands_Left, subType: HandType.Gauntlets, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Hands_Right, subType: HandType.Gauntlets, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Heads, subType: HeadType.regular, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Helms, subType: HelmType.Steel, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Legs, subType: LegType.Brown, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Shadow, subType: ShadowType.regular, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Torso, subType: TorsoType.regular, skipHurt: true);
    loadSpriteGroup2(type: SpriteGroupType.Weapons, subType: WeaponType.Bow, skipHurt: true, skipStrike: true);
    loadSpriteGroup2(type: SpriteGroupType.Weapons, subType: WeaponType.Staff, skipHurt: true, skipFire: true);
    loadSpriteGroup2(type: SpriteGroupType.Weapons, subType: WeaponType.Sword, skipHurt: true, skipFire: true);

    await _completerImages.future;

    itemTypeAtlases = {
      ItemType.Weapon: atlas_weapons,
      ItemType.Object: atlas_gameobjects,
      ItemType.Helm: atlas_helms,
      ItemType.Body: atlas_body,
      ItemType.Legs: atlas_legs,
      ItemType.Consumable: atlas_consumables,
      ItemType.Hand: atlas_hands,
      ItemType.Treasure: atlas_treasures,
    };

    fallenSpriteGroup2 = SpriteGroup2(
      idle: await loadSprite2(fileName: 'sprites_2/fallen/idle', mode: AnimationMode.Bounce, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
      running: await loadSprite2(fileName: 'sprites_2/fallen/running', mode: AnimationMode.Loop, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
      dead: await loadSprite2(fileName: 'sprites_2/fallen/dead', mode: AnimationMode.Single, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
      strike: await loadSprite2(fileName: 'sprites_2/fallen/strike', mode: AnimationMode.Single, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
      hurt: await loadSprite2(fileName: 'sprites_2/fallen/hurt', mode: AnimationMode.Single, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
      fire: emptySprite2,
      change: emptySprite2,
    );

    flame0 = Sprite2.fromList(
      image: atlas_nodes,
      list: await loadDst2('sprites_2/flame/flame_0.dst').catchError((_) => dstEmpty),
      rows: 1,
      columns: 10,
      mode: AnimationMode.Loop,
      srcWidth: 64,
      srcHeight: 64,
      x: 664,
      y: 1764,
    );

    flame1 = Sprite2.fromList(
      image: atlas_nodes,
      list: await loadDst2('sprites_2/flame/flame_1.dst').catchError((_) => dstEmpty),
      rows: 1,
      columns: 10,
      mode: AnimationMode.Loop,
      srcWidth: 64,
      srcHeight: 64,
      x: 822,
      y: 1764,
    );

    flame2 = Sprite2.fromList(
      image: atlas_nodes,
      list: await loadDst2('sprites_2/flame/flame_2.dst').catchError((_) => dstEmpty),
      rows: 1,
      columns: 10,
      mode: AnimationMode.Loop,
      srcWidth: 64,
      srcHeight: 64,
      x: 1048,
      y: 1764,
    );

    rainFalling = Sprite2.fromList(
      image: atlas_nodes,
      list: await loadDst2('sprites_2/nodes/rain_falling.dst'),
      rows: 6,
      columns: 6,
      mode: AnimationMode.Loop,
      srcWidth: 48,
      srcHeight: 72,
      x: 664,
      y: 1916,
    );

  }

  void loadSpriteGroup2({
    required int type,
    required int subType,
    bool skipIdle = false,
    bool skipRunning = false,
    bool skipChange = false,
    bool skipDead = false,
    bool skipFire = false,
    bool skipStrike = false,
    bool skipHurt = false,
  }) async {
    final typeName = SpriteGroupType.getName(type).toLowerCase();
    final subTypeName = SpriteGroupType.getSubTypeName(type, subType).toLowerCase();
    final spriteGroup2Type = spriteGroup2Types[type] ?? (throw Exception());
    final directory = 'sprites_2/kid/$typeName/$subTypeName';

    spriteGroup2Type[subType] = SpriteGroup2(
        idle: skipIdle ? emptySprite2 : await loadSprite2(fileName: '$directory/idle', mode: AnimationMode.Bounce, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
        running: skipRunning ? emptySprite2 : await loadSprite2(fileName: '$directory/running', mode: AnimationMode.Loop, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
        change: skipChange ? emptySprite2 : await loadSprite2(fileName: '$directory/change', mode: AnimationMode.Single, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
        dead: skipDead ? emptySprite2 : await loadSprite2(fileName: '$directory/dead', mode: AnimationMode.Single, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
        fire: skipFire ? emptySprite2 : await loadSprite2(fileName: '$directory/fire', mode: AnimationMode.Single, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
        strike: skipStrike ? emptySprite2 : await loadSprite2(fileName: '$directory/strike', mode: AnimationMode.Single, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
        hurt: skipHurt ? emptySprite2 : await loadSprite2(fileName: '$directory/hurt', mode: AnimationMode.Single, srcWidth: 256, srcHeight: 256, rows: 8, columns: 8),
    );
  }
  
  Future<Sprite2> loadSprite2({
    required String fileName,
    required int mode,
    required double srcWidth,
    required double srcHeight,
    required int rows,
    required int columns,

  }) async => Sprite2.fromList(
        image: await loadImageAsset('$fileName.png').catchError((_) => empty),
        list: await loadDst2('$fileName.dst').catchError((_) => dstEmpty),
        rows: rows,
        columns: columns,
        mode: mode,
        srcWidth: srcWidth,
        srcHeight: srcHeight,
    );

  // void loadAtlas({
  //   required int type,
  //   required int subType,
  // }) async {
  //   totalImages.value++;
  //   final typeName = SpriteGroupType.getName(type).toLowerCase();
  //   final subTypeName = SpriteGroupType.getSubTypeName(type, subType).toLowerCase();
  //   final json = await loadAssetJson('sprites/kid/$typeName/$subTypeName.json');
  //   final image = await loadImageAsset('sprites/kid/$typeName/$subTypeName.png');
  //   final spriteGroupType = spriteGroupTypes[type] ?? (throw Exception());
  //   spriteGroupType[subType] = loadSpriteGroupFromJson(
  //       image,
  //       json,
  //   );
  //   totalImagesLoaded.value++;
  // }

  SpriteGroup loadSpriteGroupFromJson(Image image, Map<String, dynamic> json) => SpriteGroup(
        idle: loadSpriteFromJson(json: json, name: 'idle', image: image, mode: AnimationMode.Bounce),
        running: loadSpriteFromJson(json: json, name: 'running', image: image, mode: AnimationMode.Loop),
        hurt: loadSpriteFromJson(json: json, name: 'hurt', image: image, mode: AnimationMode.Single),
        strike: loadSpriteFromJson(json: json, name: 'strike', image: image, mode: AnimationMode.Single),
        dead: loadSpriteFromJson(json: json, name: 'dead', image: image, mode: AnimationMode.Single),
        fire: loadSpriteFromJson(json: json, name: 'fire', image: image, mode: AnimationMode.Single),
        change: loadSpriteFromJson(json: json, name: 'change', image: image, mode: AnimationMode.Bounce),
    );

  Sprite loadSpriteFromJson({
    required Map<String, dynamic> json,
    required String name,
    required Image image,
    required int mode,
  }){
    if (!json.containsKey(name)){
      print('images missing sprite $name');
      return spriteEmpty;
    }

    final jsonBody = json[name];
    final y = jsonBody['y'] as int;
    final bytes = Uint8List.fromList((jsonBody['bytes'] as List<dynamic>).cast<int>());
    return Sprite.fromBytes(bytes, image: image, y: y, mode: mode);
  }

   Future<Image> loadPng(String fileName) async => loadImage('$fileName.png');

   Future<Image> loadImage(String fileName) async {
     totalImages.value++;
     final image = await loadImageAsset('images/$fileName');
     values.add(image);
     totalImagesLoaded.value++;
     return image;
   }

  void cacheImages() {

    if (imagesCached)
      return;

    print('images.cacheImages()');
    imagesCached = true;
    for (final image in images.values) {
      engine.renderSprite(
        image: image,
        srcX: 0,
        srcY: 0,
        srcWidth: 1,
        srcHeight: 1,
        dstX: 0,
        dstY: 0,
      );
    }
  }

  Future<Uint8List> loadSpriteBytes(String fileName) =>
      loadAssetBytes('sprites/$fileName.sprite');

  Future<Uint8List?> tryLoadSpriteBytes(String fileName) =>
      tryLoadAssetBytes('sprites/$fileName.sprite');

  Future<Uint16List> loadDst(String name) async => (await loadAssetBytes(name)).buffer.asUint16List();

  final byteDataEmpty = ByteData(0);

  Future<Uint16List> loadDst2(String url) async {
    try {
      final bytes = await rootBundle.load(url).catchError((e) {
        return byteDataEmpty;
      });
      return Uint8List
          .view(bytes.buffer)
          .buffer
          .asUint16List();
    } catch (e) {
      return dstEmpty;
    }
  }


}




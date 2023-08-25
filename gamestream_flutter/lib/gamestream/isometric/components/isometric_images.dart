
import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:gamestream_flutter/functions/parse.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/sprites/character_sprites.dart';
import 'package:gamestream_flutter/gamestream/sprites/kid_character_sprites.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/helm_type.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/leg_type.dart';
import 'package:lemon_sprite/lib.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'types/sprite_group_type.dart';

class IsometricImages with IsometricComponent {

  var imagesCached = false;
  
  final byteDataEmpty = ByteData(0);
  final kidCharacterSprites = KidCharacterSprites();
  final totalImages = Watch(0);
  final totalImagesLoaded = Watch(0);
  final values = <Image>[];
  final _completerImages = Completer();

  late final CharacterSpriteGroup spriteGroup2KidShadow;
  late final CharacterSpriteGroup fallenSpriteGroup2;

  late final Sprite flame0;
  late final Sprite flame1;
  late final Sprite flame2;

  late final CharacterSpriteGroup spriteGroup2Empty;

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

  late final Sprite emptySprite;

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

    loadPng('character-dog').then((value) => character_dog = value);
    loadPng('sprites/sprite-stars').then((value) => sprite_stars = value);
    loadPng('sprites/sprite-shield').then((value) => sprite_shield = value);

    emptySprite = Sprite(
        image: empty,
        src: Float32List(0),
        dst: Float32List(0),
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
        src: Float32List(0),
        dst: Float32List(0),
        srcWidth: 0,
        srcHeight: 0,
        rows: 0,
        columns: 0,
        mode: AnimationMode.single,
    );

    spriteGroup2Empty = CharacterSpriteGroup(
        idle: emptySprite,
        running: emptySprite,
        change: emptySprite,
        dead: emptySprite,
        fire: emptySprite,
        strike: emptySprite,
        hurt: emptySprite,
    );
    kidCharacterSprites.handLeft[HandType.None] = spriteGroup2Empty;
    kidCharacterSprites.handRight[HandType.None] = spriteGroup2Empty;
    kidCharacterSprites.weapons[WeaponType.Unarmed] = spriteGroup2Empty;
    kidCharacterSprites.helm[HelmType.None] = spriteGroup2Empty;
    kidCharacterSprites.body[BodyType.None] = spriteGroup2Empty;
    kidCharacterSprites.bodyArms[BodyType.None] = spriteGroup2Empty;
    kidCharacterSprites.legs[LegType.None] = spriteGroup2Empty;

    loadSpriteGroup(type: SpriteGroupType.Arms_Left, subType: ArmType.regular, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Arms_Right, subType: ArmType.regular, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Body, subType: BodyType.Shirt_Blue, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Body_Arms, subType: BodyType.Shirt_Blue, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Hands_Left, subType: HandType.Gauntlets, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Hands_Right, subType: HandType.Gauntlets, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Heads, subType: HeadType.regular, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Helms, subType: HelmType.Steel, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Legs, subType: LegType.Brown, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Shadow, subType: ShadowType.regular, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Torso, subType: TorsoType.regular, skipHurt: true);
    loadSpriteGroup(type: SpriteGroupType.Weapons, subType: WeaponType.Bow, skipHurt: true, skipStrike: true);
    loadSpriteGroup(type: SpriteGroupType.Weapons, subType: WeaponType.Staff, skipHurt: true, skipFire: true);
    loadSpriteGroup(type: SpriteGroupType.Weapons, subType: WeaponType.Sword, skipHurt: true, skipFire: true);

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

    fallenSpriteGroup2 = CharacterSpriteGroup(
      idle: await loadSprite(name: 'sprites/fallen/idle', mode: AnimationMode.bounce),
      running: await loadSprite(name: 'sprites/fallen/running', mode: AnimationMode.loop),
      dead: await loadSprite(name: 'sprites/fallen/dead', mode: AnimationMode.single),
      strike: await loadSprite(name: 'sprites/fallen/strike', mode: AnimationMode.single),
      hurt: await loadSprite(name: 'sprites/fallen/hurt', mode: AnimationMode.single),
      fire: emptySprite,
      change: emptySprite,
    );

    flame0 = await loadSprite(
        name: 'sprites/flame/wind0',
        mode: AnimationMode.loop,
        atlasX: 664,
        atlasY: 1681,
        image: atlas_nodes,
    );
    flame1 = await loadSprite(
        name: 'sprites/flame/wind1',
        mode: AnimationMode.loop,
        atlasX: 664,
        atlasY: 1733,
        image: atlas_nodes,
    );
    flame2 = await loadSprite(
        name: 'sprites/flame/wind2',
        mode: AnimationMode.loop,
        atlasX: 664,
        atlasY: 1778,
        image: atlas_nodes,
    );
  }

  void loadSpriteGroup({
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
    final kidCharacterSpriteGroup = kidCharacterSprites.values[type] ?? (throw Exception('images.loadSpriteGroup2($typeName, $subTypeName)'));
    final directory = 'sprites/kid/$typeName/$subTypeName';

    kidCharacterSpriteGroup[subType] = CharacterSpriteGroup(
        idle: skipIdle ? emptySprite : await loadSprite(name: '$directory/idle', mode: AnimationMode.bounce),
        running: skipRunning ? emptySprite : await loadSprite(name: '$directory/running', mode: AnimationMode.loop),
        change: skipChange ? emptySprite : await loadSprite(name: '$directory/change', mode: AnimationMode.bounce),
        dead: skipDead ? emptySprite : await loadSprite(name: '$directory/dead', mode: AnimationMode.single),
        fire: skipFire ? emptySprite : await loadSprite(name: '$directory/fire', mode: AnimationMode.single),
        strike: skipStrike ? emptySprite : await loadSprite(name: '$directory/strike', mode: AnimationMode.single),
        hurt: skipHurt ? emptySprite : await loadSprite(name: '$directory/hurt', mode: AnimationMode.single),
    );
  }

  parseListDouble(List<dynamic> values) =>
      (values.cast<num>()).map((e) => e.toDouble()).toList(growable: false);

  List<double> readDoubles(dynamic values)=> parseListDouble(values as List);

  Float32List readFloat32List(dynamic values) => Float32List.fromList(readDoubles(values));

  Future<Sprite> loadSprite({
    required String name,
    required int mode,
    Image? image,
    int atlasX = 0,
    int atlasY = 0,
  }) async {
    image = image ?? await loadImageAsset('$name.png');
    final json = await loadAssetJson('$name.json');

    return Sprite(
      image: image,
      src: parse(json['src']),
      dst: parse(json['dst']),
      rows: parse(json['rows']),
      columns: parse(json['columns']),
      srcWidth: parse(json['width']),
      srcHeight: parse(json['height']),
      mode: mode,
      atlasX: atlasX,
      atlasY: atlasY,
    );
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

  Future<Uint16List> loadDst(String url) async {
    final bytes = await rootBundle.load(url);
    return Uint8List.view(bytes.buffer).buffer.asUint16List();
  }
}





import 'dart:async';
import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/src.dart';
import 'classes/sprite_group.dart';
import 'render/renderer_characters.dart';
import 'types/sprite_group_type.dart';

class IsometricImages with IsometricComponent {

  var imagesCached = false;

  final totalImages = Watch(0);
  final totalImagesLoaded = Watch(0);
  final values = <Image>[];
  final _completerImages = Completer();

  final spriteGroupArmsLeft = <int, SpriteGroup> {};
  final spriteGroupArmsRight = <int, SpriteGroup> {};
  final spriteGroupBody = <int, SpriteGroup> {};
  final spriteGroupBodyArms = <int, SpriteGroup> {};
  final spriteGroupHandsLeft = <int, SpriteGroup> {};
  final spriteGroupHandsRight = <int, SpriteGroup> {};
  final spriteGroupHeads = <int, SpriteGroup> {};
  final spriteGroupHelms = <int, SpriteGroup> {};
  final spriteGroupLegs = <int, SpriteGroup> {};
  final spriteGroupTorso = <int, SpriteGroup> {};
  final spriteGroupWeapons = <int, SpriteGroup> {};

  late final spriteGroupTypes = {
    SpriteGroupType.Arms_Left: spriteGroupArmsLeft,
    SpriteGroupType.Arms_Right: spriteGroupArmsRight,
    SpriteGroupType.Body: spriteGroupBody,
    SpriteGroupType.Body_Arms: spriteGroupBodyArms,
    SpriteGroupType.Hands_Left: spriteGroupHandsLeft,
    SpriteGroupType.Hands_Right: spriteGroupHandsRight,
    SpriteGroupType.Heads: spriteGroupHeads,
    SpriteGroupType.Helms: spriteGroupHelms,
    SpriteGroupType.Legs: spriteGroupLegs,
    SpriteGroupType.Torso: spriteGroupTorso,
    SpriteGroupType.Weapons: spriteGroupWeapons,
  };

  late final SpriteGroup spriteGroupEmpty;
  late final SpriteGroup spriteFallen;
  late final SpriteGroup spriteGroupKidShadow;

  late final Sprite spriteEmpty;
  late final Sprite spriteFlame;
  late final Sprite spriteRainFalling;

  late final Image empty;
  late final Image shades;
  late final Image pixel;
  late final Image atlas_projectiles;
  late final Image zombie;
  late final Image zombie_shadow;
  late final Image character_dog;
  late final Image character_fallen;
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
  late final Image atlas_items;
  late final Image atlas_treasures;
  late final Image atlas_nodes_mini;
  late final Image atlas_weapons;
  late final Image atlas_talents;
  late final Image sprite_stars;
  late final Image sprite_shield;
  late final Image template_spinning;

  @override
  Future onComponentInit(SharedPreferences sharedPreferences) async {
    print('isometric.images.onComponentInitialize()');

    empty = await loadPng('empty');
    loadPng('shades').then((value) => shades = value);
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
    loadPng('atlas_items').then((value) => atlas_items = value);
    loadPng('atlas_treasures').then((value) => atlas_treasures = value);
    loadPng('atlas_helms').then((value) => atlas_helms = value);
    loadPng('atlas_hands').then((value) => atlas_hands = value);
    loadPng('atlas_body').then((value) => atlas_body = value);
    loadPng('atlas_legs').then((value) => atlas_legs = value);

    loadPng('characters/fallen').then((value) => character_fallen = value);
    loadPng('character-dog').then((value) => character_dog = value);
    loadPng('sprites/sprite-stars').then((value) => sprite_stars = value);
    loadPng('sprites/sprite-shield').then((value) => sprite_shield = value);

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


    spriteGroupHandsLeft[HandType.None] = spriteGroupEmpty;
    spriteGroupHandsRight[HandType.None] = spriteGroupEmpty;
    spriteGroupWeapons[WeaponType.Unarmed] = spriteGroupEmpty;
    spriteGroupHelms[HelmType.None] = spriteGroupEmpty;
    spriteGroupBody[BodyType.None] = spriteGroupEmpty;
    spriteGroupLegs[LegType.None] = spriteGroupEmpty;
    spriteGroupBodyArms[BodyType.None] = spriteGroupEmpty;

    loadAtlas(type: SpriteGroupType.Arms_Left, subType: ComplexionType.Fair);
    loadAtlas(type: SpriteGroupType.Arms_Right, subType: ComplexionType.Fair);
    loadAtlas(type: SpriteGroupType.Body, subType: BodyType.Shirt_Blue);
    loadAtlas(type: SpriteGroupType.Body_Arms, subType: BodyType.Shirt_Blue);
    loadAtlas(type: SpriteGroupType.Hands_Left, subType: HandType.Gauntlets);
    loadAtlas(type: SpriteGroupType.Hands_Right, subType: HandType.Gauntlets);
    loadAtlas(type: SpriteGroupType.Heads, subType: ComplexionType.Fair);
    loadAtlas(type: SpriteGroupType.Helms, subType: HelmType.Steel);
    loadAtlas(type: SpriteGroupType.Legs, subType: LegType.Brown);
    loadAtlas(type: SpriteGroupType.Torso, subType: ComplexionType.Fair);
    loadAtlas(type: SpriteGroupType.Weapons, subType: WeaponType.Bow);
    loadAtlas(type: SpriteGroupType.Weapons, subType: WeaponType.Staff);
    loadAtlas(type: SpriteGroupType.Weapons, subType: WeaponType.Sword);

    spriteGroupKidShadow = loadSpriteGroupFromJson(
      await loadImageAsset('sprites/kid/shadow.png'),
      await loadAssetJson('sprites/kid/shadow.json'),
    );

    await _completerImages.future;

    final fallenIdle = await loadSpriteBytes('fallen/idle');
    final fallenRunning = await loadSpriteBytes('fallen/run');
    final fallenStrike = await loadSpriteBytes('fallen/strike');
    final fallenHurt = await loadSpriteBytes('fallen/hurt');
    final fallenDeath = await loadSpriteBytes('fallen/death');

    spriteFallen = SpriteGroup(
      idle: Sprite.fromBytes(fallenIdle, image: character_fallen, y: 0, mode: AnimationMode.Bounce),
      running: Sprite.fromBytes(fallenRunning, image: character_fallen, y: 157, mode: AnimationMode.Loop),
      strike: Sprite.fromBytes(fallenStrike, image: character_fallen, y: 338, mode: AnimationMode.Single),
      hurt: Sprite.fromBytes(fallenHurt, image: character_fallen, y: 524, mode: AnimationMode.Single),
      dead: Sprite.fromBytes(fallenDeath, image: character_fallen, y: 707, mode: AnimationMode.Single),
      change: spriteEmpty,
      fire: spriteEmpty,
    );

    final spriteBytesFlame = await loadSpriteBytes('particles/flame');
    spriteFlame = Sprite.fromBytes(
      spriteBytesFlame,
      image: atlas_nodes,
      x: 664,
      y: 1916,
      mode: AnimationMode.Loop
    );

    final spriteRainFallingBytes = await loadSpriteBytes('particles/rain_falling');
    spriteRainFalling = Sprite.fromBytes(
      spriteRainFallingBytes,
      image: atlas_nodes,
      x: 664,
      y: 1874,
      mode: AnimationMode.Loop
    );
  }

  void loadAtlas({
    required int type,
    required int subType,
  }) async {
    totalImages.value++;
    final typeName = SpriteGroupType.getName(type).toLowerCase();
    final subTypeName = SpriteGroupType.getSubTypeName(type, subType).toLowerCase();
    final json = await loadAssetJson('sprites/kid/$typeName/$subTypeName.json');
    final image = await loadImageAsset('sprites/kid/$typeName/$subTypeName.png');
    final spriteGroupType = spriteGroupTypes[type] ?? (throw Exception());
    spriteGroupType[subType] = loadSpriteGroupFromJson(
        image,
        json,
    );
    totalImagesLoaded.value++;
  }

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
}





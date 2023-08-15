
import 'dart:async';
import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/src.dart';
import 'classes/sprite_group.dart';
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
  late final Image kid_shadow;
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
  late final Image atlas_nodes_mini;
  late final Image atlas_weapons;
  late final Image atlas_talents;
  late final Image sprite_stars;
  late final Image sprite_shield;
  late final Image template_spinning;

  late final Image kid_arms_fair_left;
  late final Image kid_arms_fair_right;
  late final Image kid_body_shirt_blue;
  late final Image kid_body_arms_shirt_blue;
  late final Image kid_hands_left_gauntlets;
  late final Image kid_hands_right_gauntlets;
  late final Image kid_head_fair;
  late final Image kid_helms_steel;
  late final Image kid_legs_brown;
  late final Image kid_torso_fair;
  late final Image kid_weapons_staff;
  late final Image kid_weapons_sword;
  late final Image kid_weapons_bow;

   Future<SpriteGroup> loadSpriteGroup({
     required Image image,
     required int type,
     required int subType,
     required double yIdle,
     required double yRunning,
     double? yStrike,
     double? yFire,
     double? yHurt,
     double? yDead,
    }) async {

     final typeName = SpriteGroupType.getName(type);
     final subTypeName = SpriteGroupType.getSubTypeName(type, subType);

     if (yHurt == null){
       print('isometric_images_sprite_missing: "kid/$typeName/$subTypeName/hurt.sprite"');
     }
     if (yDead == null){
       print('isometric_images_sprite_missing: "kid/$typeName/$subTypeName/dead.sprite"');
     }

     return SpriteGroup(
         idle: Sprite.fromBytes(
             await loadSpriteBytes('kid/$typeName/$subTypeName/idle'),
             image: image,
             y: yIdle,
             loop: true,
         ),
         running: Sprite.fromBytes(
             await loadSpriteBytes('kid/$typeName/$subTypeName/running'),
             image: image,
             y: yRunning,
             loop: true,
         ),
         strike: yStrike == null ? spriteEmpty : Sprite.fromBytes(
           await loadSpriteBytes('kid/$typeName/$subTypeName/strike'),
           image: image,
           y: yStrike,
           loop: false,
         ),
         fire: yFire == null ? spriteEmpty : Sprite.fromBytes(
           await loadSpriteBytes('kid/$typeName/$subTypeName/fire'),
           image: image,
           y: yFire,
           loop: false,
         ),
         hurt: yHurt == null ? spriteEmpty : Sprite.fromBytes(
             await loadSpriteBytes('kid/$typeName/$subTypeName/hurt'),
             image: image,
             y: yHurt,
             loop: false,
         ),
         death: yDead == null ? spriteEmpty : Sprite.fromBytes(
           await loadSpriteBytes('kid/$typeName/$subTypeName/dead'),
           image: image,
           y: yDead,
           loop: false,
         ),
     );
   }

  @override
  Future onComponentInit(SharedPreferences sharedPreferences) async {
    print('isometric.images.onComponentInitialize()');

    loadPng('empty').then((value) => empty = value);
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
    loadPng('atlas_helms').then((value) => atlas_helms = value);
    loadPng('atlas_hands').then((value) => atlas_hands = value);
    loadPng('atlas_body').then((value) => atlas_body = value);
    loadPng('atlas_legs').then((value) => atlas_legs = value);

    loadPng('characters/fallen').then((value) => character_fallen = value);
    loadPng('characters/kid_shadow').then((value) => kid_shadow = value);

    loadPng('kid/arms/fair/left').then((value) => kid_arms_fair_left = value);
    loadPng('kid/arms/fair/right').then((value) => kid_arms_fair_right = value);
    loadPng('kid/body/shirt_blue').then((value) => kid_body_shirt_blue = value);
    loadPng('kid/body_arms/shirt_blue').then((value) => kid_body_arms_shirt_blue = value);
    loadPng('kid/hands/left/gauntlets').then((value) => kid_hands_left_gauntlets = value);
    loadPng('kid/hands/right/gauntlets').then((value) => kid_hands_right_gauntlets = value);
    loadPng('kid/head/fair').then((value) => kid_head_fair = value);
    loadPng('kid/helms/steel').then((value) => kid_helms_steel = value);
    loadPng('kid/legs/brown').then((value) => kid_legs_brown = value);
    loadPng('kid/torso/fair').then((value) => kid_torso_fair = value);
    loadPng('kid/weapons/staff').then((value) => kid_weapons_staff = value);
    loadPng('kid/weapons/sword').then((value) => kid_weapons_sword = value);
    loadPng('kid/weapons/bow').then((value) => kid_weapons_bow = value);

    loadPng('character-dog').then((value) => character_dog = value);
    loadPng('sprites/sprite-stars').then((value) => sprite_stars = value);
    loadPng('sprites/sprite-shield').then((value) => sprite_shield = value);

    totalImagesLoaded.onChanged((totalImagesLoaded) {
      if (totalImagesLoaded < totalImages.value)
        return;

      _completerImages.complete(true);
    });

    print('awaiting images completer');
    await _completerImages.future;


    spriteEmpty = Sprite(
        image: empty,
        values: Float32List(0),
        width: 0,
        height: 0,
        rows: 0,
        columns: 0,
        y: 0,
        loop: true,
    );

    spriteGroupEmpty = SpriteGroup(
        idle: spriteEmpty,
        running: spriteEmpty,
        strike: spriteEmpty,
        hurt: spriteEmpty,
        death: spriteEmpty,
        fire: spriteEmpty,
    );

    spriteGroupHandsLeft[HandType.None] = spriteGroupEmpty;
    spriteGroupHandsRight[HandType.None] = spriteGroupEmpty;
    spriteGroupWeapons[WeaponType.Unarmed] = spriteGroupEmpty;
    spriteGroupHelms[HelmType.None] = spriteGroupEmpty;
    spriteGroupBody[BodyType.None] = spriteGroupEmpty;
    spriteGroupLegs[LegType.None] = spriteGroupEmpty;
    spriteGroupBodyArms[BodyType.None] = spriteGroupEmpty;

    final fallenIdle = await loadSpriteBytes('fallen/idle');
    final fallenRunning = await loadSpriteBytes('fallen/run');
    final fallenStrike = await loadSpriteBytes('fallen/strike');
    final fallenHurt = await loadSpriteBytes('fallen/hurt');
    final fallenDeath = await loadSpriteBytes('fallen/death');

    spriteFallen = SpriteGroup(
      idle: Sprite.fromBytes(fallenIdle, image: character_fallen, y: 0, loop: true),
      running: Sprite.fromBytes(fallenRunning, image: character_fallen, y: 157, loop: true),
      strike: Sprite.fromBytes(fallenStrike, image: character_fallen, y: 338, loop: false),
      hurt: Sprite.fromBytes(fallenHurt, image: character_fallen, y: 524, loop: false),
      death: Sprite.fromBytes(fallenDeath, image: character_fallen, y: 707, loop: false),
      fire: spriteEmpty,
    );

    final kidShadowIdle = await loadSpriteBytes('kid/shadow/idle');
    final kidShadowRun = await loadSpriteBytes('kid/shadow/run');
    final kidShadowStrike = await loadSpriteBytes('kid/shadow/strike');
    final kidShadowFire = await loadSpriteBytes('kid/shadow/fire');

    spriteGroupKidShadow = SpriteGroup(
        idle: Sprite.fromBytes(kidShadowIdle, image: kid_shadow, y: 0, loop: true),
        running: Sprite.fromBytes(kidShadowRun, image: kid_shadow, y: 57, loop: true),
        strike: Sprite.fromBytes(kidShadowStrike, image: kid_shadow, y: 297, loop: false),
        fire: Sprite.fromBytes(kidShadowFire, image: kid_shadow, y: 439, loop: false),
        hurt: spriteEmpty,
        death: spriteEmpty,
    );

    final spriteBytesFlame = await loadSpriteBytes('particles/flame');
    spriteFlame = Sprite.fromBytes(
        spriteBytesFlame,
        image: atlas_nodes,
        x: 664,
        y: 1916,
        loop: true,
    );

    final spriteRainFallingBytes = await loadSpriteBytes('particles/rain_falling');
    spriteRainFalling = Sprite.fromBytes(
      spriteRainFallingBytes,
        image: atlas_nodes,
        x: 664,
        y: 1874,
        loop: true,
    );

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 44,
      yStrike: 91,
      yFire: 141,
      image: kid_arms_fair_left,
      type: SpriteGroupType.Arms_Left,
      subType: ComplexionType.Fair,
    ).then((value) {
      spriteGroupArmsLeft[ComplexionType.Fair] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 44,
      yStrike: 91,
      yFire: 139,
      image: kid_arms_fair_right,
      type: SpriteGroupType.Arms_Right,
      subType: ComplexionType.Fair,
    ).then((value) {
      spriteGroupArmsRight[ComplexionType.Fair] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 51,
      yStrike: 153,
      yFire: 277,
      image: kid_body_shirt_blue,
      type: SpriteGroupType.Body,
      subType: BodyType.Shirt_Blue,
    ).then((value) {
      spriteGroupBody[BodyType.Shirt_Blue] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 41,
      yStrike: 83,
      yFire: 179,
      image: kid_body_arms_shirt_blue,
      type: SpriteGroupType.Body_Arms,
      subType: BodyType.Shirt_Blue,
    ).then((value) {
      spriteGroupBodyArms[BodyType.Shirt_Blue] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 31,
      yStrike: 60,
      yFire: 93,
      image: kid_hands_left_gauntlets,
      type: SpriteGroupType.Hands_Left,
      subType: HandType.Gauntlet,
    ).then((value) {
      spriteGroupHandsLeft[HandType.Gauntlet] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 29,
      yStrike: 57,
      yFire: 86,
      image: kid_hands_right_gauntlets,
      type: SpriteGroupType.Hands_Right,
      subType: HandType.Gauntlet,
    ).then((value) {
      spriteGroupHandsRight[HandType.Gauntlet] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 28,
      yStrike: 57,
      yFire: 87,
      image: kid_head_fair,
      type: SpriteGroupType.Heads,
      subType: ComplexionType.Fair,
    ).then((value) {
      spriteGroupHeads[ComplexionType.Fair] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 26,
      yStrike: 53,
      yFire: 80,
      image: kid_helms_steel,
      type: SpriteGroupType.Helms,
      subType: HelmType.Steel,
    ).then((value) {
      spriteGroupHelms[HelmType.Steel] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 71,
      yStrike: 233,
      yFire: 373,
      image: kid_legs_brown,
      type: SpriteGroupType.Legs,
      subType: LegType.Brown,
    ).then((value) {
      spriteGroupLegs[LegType.Brown] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 205,
      yStrike: 436,
      yFire: 664,
      image: kid_torso_fair,
      type: SpriteGroupType.Torso,
      subType: ComplexionType.Fair,
    ).then((value) {
      spriteGroupTorso[ComplexionType.Fair] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 81,
      yStrike: 187,
      image: kid_weapons_staff,
      type: SpriteGroupType.Weapons,
      subType: WeaponType.Staff,
    ).then((value) {
      spriteGroupWeapons[WeaponType.Staff] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 63,
      yStrike: 114,
      image: kid_weapons_sword,
      type: SpriteGroupType.Weapons,
      subType: WeaponType.Sword,
    ).then((value) {
      spriteGroupWeapons[WeaponType.Sword] = value;
    });

    loadSpriteGroup(
      yIdle: 0,
      yRunning: 116,
      yFire: 255,
      image: kid_weapons_bow,
      type: SpriteGroupType.Weapons,
      subType: WeaponType.Bow,
    ).then((value) {
      spriteGroupWeapons[WeaponType.Bow] = value;
    });
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





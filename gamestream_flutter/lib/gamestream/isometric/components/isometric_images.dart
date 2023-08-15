
import 'dart:async';
import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/src.dart';
import 'classes/sprite_group.dart';

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
  late final Image atlas_head;
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

   Future loadSpriteGroupArmsLeft({
     required int complexion,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required double yFire,
     required Image image,
    }) async {
     final name = ComplexionType.getName(complexion).toLowerCase();
     final idle = await loadSpriteBytes('kid/arms_left/$name/idle');
     final running = await loadSpriteBytes('kid/arms_left/$name/running');
     final strike = await loadSpriteBytes('kid/arms_left/$name/strike');
     final fire = await loadSpriteBytes('kid/arms_left/$name/fire');
     spriteGroupArmsLeft[complexion] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         fire: Sprite.fromBytes(fire, image: image, y: yFire, loop: false),
         hurt: spriteEmpty,
         death: spriteEmpty,
     );
   }

   Future loadSpriteGroupArmsRight({
     required int complexion,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required double yFire,
     required Image image,
    }) async {
     final name = ComplexionType.getName(complexion).toLowerCase();
     final idle = await loadSpriteBytes('kid/arms_right/$name/idle');
     final running = await loadSpriteBytes('kid/arms_right/$name/running');
     final strike = await loadSpriteBytes('kid/arms_right/$name/strike');
     final fire = await loadSpriteBytes('kid/arms_right/$name/fire');
     spriteGroupArmsRight[complexion] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         fire: Sprite.fromBytes(fire, image: image, y: yFire, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupBody({
     required int bodyType,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required double yFire,
     required Image image,
    }) async {
     final name = BodyType.getName(bodyType).toLowerCase();
     final idle = await loadSpriteBytes('kid/body/$name/idle');
     final running = await loadSpriteBytes('kid/body/$name/running');
     final strike = await loadSpriteBytes('kid/body/$name/strike');
     final fire = await loadSpriteBytes('kid/body/$name/fire');
     spriteGroupBody[bodyType] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         fire: Sprite.fromBytes(fire, image: image, y: yFire, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupBodyArms({
     required int bodyType,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required double yFire,
     required Image image,
    }) async {
     final name = BodyType.getName(bodyType).toLowerCase();
     final idle = await loadSpriteBytes('kid/body_arms/$name/idle');
     final running = await loadSpriteBytes('kid/body_arms/$name/running');
     final strike = await loadSpriteBytes('kid/body_arms/$name/strike');
     final fire = await loadSpriteBytes('kid/body_arms/$name/fire');
     spriteGroupBodyArms[bodyType] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         fire: Sprite.fromBytes(fire, image: image, y: yFire, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupHandsLeft({
     required int handType,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required double yFire,
     required Image image,
    }) async {
     final name = HandType.getName(handType).toLowerCase();
     final idle = await loadSpriteBytes('kid/hands_left/$name/idle');
     final running = await loadSpriteBytes('kid/hands_left/$name/running');
     final strike = await loadSpriteBytes('kid/hands_left/$name/strike');
     final fire = await loadSpriteBytes('kid/hands_left/$name/fire');
     spriteGroupHandsLeft[handType] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         fire: Sprite.fromBytes(fire, image: image, y: yFire, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupHandsRight({
     required int handType,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required double yFire,
     required Image image,
    }) async {
     final name = HandType.getName(handType).toLowerCase();
     final idle = await loadSpriteBytes('kid/hands_right/$name/idle');
     final running = await loadSpriteBytes('kid/hands_right/$name/running');
     final strike = await loadSpriteBytes('kid/hands_right/$name/strike');
     final fire = await loadSpriteBytes('kid/hands_right/$name/fire');
     spriteGroupHandsRight[handType] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         fire: Sprite.fromBytes(fire, image: image, y: yFire, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupHead({
     required int complexion,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required double yFire,
     required Image image,
    }) async {
     final name = ComplexionType.getName(complexion).toLowerCase();
     final idle = await loadSpriteBytes('kid/heads/$name/idle');
     final running = await loadSpriteBytes('kid/heads/$name/running');
     final strike = await loadSpriteBytes('kid/heads/$name/strike');
     final fire = await loadSpriteBytes('kid/heads/$name/fire');
     spriteGroupHeads[complexion] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         fire: Sprite.fromBytes(fire, image: image, y: yFire, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupHelm({
     required int type,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required double yFire,
     required Image image,
    }) async {
     final name = HelmType.getName(type).toLowerCase();
     final idle = await loadSpriteBytes('kid/helms/$name/idle');
     final running = await loadSpriteBytes('kid/helms/$name/running');
     final strike = await loadSpriteBytes('kid/helms/$name/strike');
     final fire = await loadSpriteBytes('kid/helms/$name/fire');
     spriteGroupHelms[type] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         fire: Sprite.fromBytes(fire, image: image, y: yFire, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   // Future loadSpriteGroupLegs({
   //   required int legType,
   //   required double yIdle,
   //   required double yRunning,
   //   required double yStrike,
   //   required double yFire,
   //   required Image image,
   //  }) async {
   //   final name = LegType.getName(legType).toLowerCase();
   //   final idle = await loadSpriteBytes('kid/legs/$name/idle');
   //   final running = await loadSpriteBytes('kid/legs/$name/running');
   //   final strike = await loadSpriteBytes('kid/legs/$name/strike');
   //   final fire = await loadSpriteBytes('kid/legs/$name/fire');
   //   spriteGroupLegs[legType] = SpriteGroup(
   //       idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
   //       running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
   //       strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
   //       fire: Sprite.fromBytes(fire, image: image, y: yFire, loop: false),
   //       hurt: spriteEmpty,
   //     death: spriteEmpty,
   //   );
   // }

   Future loadSpriteGroupTorso({
     required int complexion,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required double yFire,
     required Image image,
    }) async {
     final name = ComplexionType.getName(complexion).toLowerCase();
     final idle = await loadSpriteBytes('kid/torso/$name/idle');
     final running = await loadSpriteBytes('kid/torso/$name/running');
     final strike = await loadSpriteBytes('kid/torso/$name/strike');
     final fire = await loadSpriteBytes('kid/torso/$name/fire');
     spriteGroupTorso[complexion] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         fire: Sprite.fromBytes(fire, image: image, y: yFire, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future<SpriteGroup> loadSpriteGroup({
     required Image image,
     required String type,
     required String name,
     required double yIdle,
     required double yRunning,
     double? yStrike,
     double? yFire,
     double? yHurt,
     double? yDead,
    }) async {

     return SpriteGroup(
         idle: Sprite.fromBytes(
             await loadSpriteBytes('kid/$type/$name/idle'),
             image: image,
             y: yIdle,
             loop: true,
         ),
         running: Sprite.fromBytes(
             await loadSpriteBytes('kid/$type/$name/running'),
             image: image,
             y: yRunning,
             loop: true,
         ),
         strike: yStrike == null ? spriteEmpty : Sprite.fromBytes(
           await loadSpriteBytes('kid/$type/$name/strike'),
           image: image,
           y: yStrike,
           loop: false,
         ),
         fire: yFire == null ? spriteEmpty : Sprite.fromBytes(
           await loadSpriteBytes('kid/$type/$name/fire'),
           image: image,
           y: yFire,
           loop: false,
         ),
         hurt: yHurt == null ? spriteEmpty : Sprite.fromBytes(
             await loadSpriteBytes('kid/$type/$name/hurt'),
             image: image,
             y: yHurt,
             loop: false,
         ),
         death: yDead == null ? spriteEmpty : Sprite.fromBytes(
           await loadSpriteBytes('kid/$type/$name/dead'),
           image: image,
           y: yDead,
           loop: false,
         ),
     );
   }

  Future loadSpriteGroupWeapon({
    required int type,
    required double yIdle,
    required double yRunning,
    required Image image,
    double? yStrike,
    double? yFire,
  }) async {
    final name = WeaponType.getName(type).toLowerCase();
    final idle = await loadSpriteBytes('kid/weapons/$name/idle');
    final running = await loadSpriteBytes('kid/weapons/$name/running');

    Sprite spriteFire;
    Sprite spriteStrike;

    if (yFire != null){
      final fire = await loadSpriteBytes('kid/weapons/$name/fire');
      spriteFire = Sprite.fromBytes(fire, image: image, y: yFire, loop: false);
    } else {
      spriteFire = spriteEmpty;
    }

    if (yStrike != null){
      final strike = await loadSpriteBytes('kid/weapons/$name/strike');
      spriteStrike = Sprite.fromBytes(strike, image: image, y: yStrike, loop: false);
    } else {
      spriteStrike = spriteEmpty;
    }

    spriteGroupWeapons[type] = SpriteGroup(
      idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
      running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
      strike: spriteStrike,
      fire: spriteFire,
      hurt: spriteEmpty,
      death: spriteEmpty,

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
    loadPng('atlas_head').then((value) => atlas_head = value);
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

    await loadSpriteGroupArmsLeft(
        complexion: ComplexionType.Fair,
        yIdle: 0,
        yRunning: 44,
        yStrike: 91,
        yFire: 141,
        image: kid_arms_fair_left,
    );

    await loadSpriteGroupArmsRight(
        complexion: ComplexionType.Fair,
        yIdle: 0,
        yRunning: 44,
        yStrike: 91,
        yFire: 139,
        image: kid_arms_fair_right,
    );

    await loadSpriteGroupBody(
        bodyType: BodyType.Shirt_Blue,
        yIdle: 0,
        yRunning: 51,
        yStrike: 153,
        yFire: 277,
        image: kid_body_shirt_blue,
    );

    await loadSpriteGroupBodyArms(
        bodyType: BodyType.Shirt_Blue,
        yIdle: 0,
        yRunning: 41,
        yStrike: 83,
        yFire: 179,
        image: kid_body_arms_shirt_blue,
    );

    await loadSpriteGroupHandsLeft(
        handType: HandType.Gauntlet,
        yIdle: 0,
        yRunning: 31,
        yStrike: 60,
        yFire: 93,
        image: kid_hands_left_gauntlets,
    );

    await loadSpriteGroupHandsRight(
        handType: HandType.Gauntlet,
        yIdle: 0,
        yRunning: 29,
        yStrike: 57,
        yFire: 86,
        image: kid_hands_right_gauntlets,
    );

    await loadSpriteGroupHead(
        complexion: ComplexionType.Fair,
        yIdle: 0,
        yRunning: 28,
        yStrike: 57,
        yFire: 87,
        image: kid_head_fair,
    );

    await loadSpriteGroupHelm(
        type: HelmType.Steel,
        yIdle: 0,
        yRunning: 26,
        yStrike: 53,
        yFire: 80,
        image: kid_helms_steel,
    );

    loadSpriteGroup(
        yIdle: 0,
        yRunning: 71,
        yStrike: 233,
        yFire: 373,
        image: kid_legs_brown,
        type: 'legs',
        name: 'brown',
    ).then((value) {
      spriteGroupLegs[LegType.Brown] = value;
    });

    await loadSpriteGroupTorso(
        complexion: ComplexionType.Fair,
        yIdle: 0,
        yRunning: 205,
        yStrike: 436,
        yFire: 664,
        image: kid_torso_fair,
    );

    await loadSpriteGroupWeapon(
        type: WeaponType.Staff,
        yIdle: 0,
        yRunning: 81,
        yStrike: 187,
        image: kid_weapons_staff,
    );

    await loadSpriteGroupWeapon(
        type: WeaponType.Sword,
        yIdle: 0,
        yRunning: 63,
        yStrike: 114,
        image: kid_weapons_sword,
    );

    await loadSpriteGroupWeapon(
        type: WeaponType.Bow,
        yIdle: 0,
        yRunning: 116,
        yFire: 255,
        image: kid_weapons_bow,
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

  Future<Uint8List?> tryLoadSpriteBytes(String fileName) =>
      tryLoadAssetBytes('sprites/$fileName.sprite');
}





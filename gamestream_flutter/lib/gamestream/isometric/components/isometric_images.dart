
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

   Future loadSpriteGroupArmsLeft({
     required int complexion,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required Image image,
    }) async {
     final name = ComplexionType.getName(complexion).toLowerCase();
     final idle = await loadSprite('arm/left/$name/idle');
     final running = await loadSprite('arm/left/$name/running');
     final strike = await loadSprite('arm/left/$name/strike');
     spriteGroupArmsLeft[complexion] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         hurt: spriteEmpty,
         death: spriteEmpty,
     );
   }

   Future loadSpriteGroupArmsRight({
     required int complexion,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required Image image,
    }) async {
     final name = ComplexionType.getName(complexion).toLowerCase();
     final idle = await loadSprite('arm/right/$name/idle');
     final running = await loadSprite('arm/right/$name/running');
     final strike = await loadSprite('arm/right/$name/strike');
     spriteGroupArmsRight[complexion] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupBody({
     required int bodyType,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required Image image,
    }) async {
     final name = BodyType.getName(bodyType).toLowerCase();
     final idle = await loadSprite('body/$name/idle');
     final running = await loadSprite('body/$name/running');
     final strike = await loadSprite('body/$name/strike');
     spriteGroupBody[bodyType] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupBodyArms({
     required int bodyType,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required Image image,
    }) async {
     final name = BodyType.getName(bodyType).toLowerCase();
     final idle = await loadSprite('body_arms/$name/idle');
     final running = await loadSprite('body_arms/$name/running');
     final strike = await loadSprite('body_arms/$name/strike');
     spriteGroupBodyArms[bodyType] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupHandsLeft({
     required int handType,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required Image image,
    }) async {
     final name = HandType.getName(handType).toLowerCase();
     final idle = await loadSprite('hands/left/$name/idle');
     final running = await loadSprite('hands/left/$name/running');
     final strike = await loadSprite('hands/left/$name/strike');
     spriteGroupHandsLeft[handType] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupHandsRight({
     required int handType,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required Image image,
    }) async {
     final name = HandType.getName(handType).toLowerCase();
     final idle = await loadSprite('hands/right/$name/idle');
     final running = await loadSprite('hands/right/$name/running');
     final strike = await loadSprite('hands/right/$name/strike');
     spriteGroupHandsRight[handType] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupHead({
     required int complexion,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required Image image,
    }) async {
     final name = ComplexionType.getName(complexion).toLowerCase();
     final idle = await loadSprite('heads/$name/idle');
     final running = await loadSprite('heads/$name/running');
     final strike = await loadSprite('heads/$name/strike');
     spriteGroupHeads[complexion] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupHelm({
     required int type,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required Image image,
    }) async {
     final name = HelmType.getName(type).toLowerCase();
     final idle = await loadSprite('helms/$name/idle');
     final running = await loadSprite('helms/$name/running');
     final strike = await loadSprite('helms/$name/strike');
     spriteGroupHelms[type] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupLegs({
     required int legType,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required Image image,
    }) async {
     final name = LegType.getName(legType).toLowerCase();
     final idle = await loadSprite('legs/$name/idle');
     final running = await loadSprite('legs/$name/running');
     final strike = await loadSprite('legs/$name/strike');
     spriteGroupLegs[legType] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

   Future loadSpriteGroupTorso({
     required int complexion,
     required double yIdle,
     required double yRunning,
     required double yStrike,
     required Image image,
    }) async {
     final name = ComplexionType.getName(complexion).toLowerCase();
     final idle = await loadSprite('torso/$name/idle');
     final running = await loadSprite('torso/$name/running');
     final strike = await loadSprite('torso/$name/strike');
     spriteGroupTorso[complexion] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
         running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
         strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
         hurt: spriteEmpty,
       death: spriteEmpty,
     );
   }

  Future loadSpriteGroupWeapon({
    required int type,
    required double yIdle,
    required double yRunning,
    required double yStrike,
    required Image image,
  }) async {
    final name = WeaponType.getName(type).toLowerCase();
    final idle = await loadSprite('weapons/$name/idle');
    final running = await loadSprite('weapons/$name/running');
    final strike = await loadSprite('weapons/$name/strike');
    spriteGroupWeapons[type] = SpriteGroup(
      idle: Sprite.fromBytes(idle, image: image, y: yIdle, loop: true),
      running: Sprite.fromBytes(running, image: image, y: yRunning, loop: true),
      strike: Sprite.fromBytes(strike, image: image, y: yStrike, loop: false),
      hurt: spriteEmpty,
      death: spriteEmpty,

    );
  }

  Future<Uint8List> loadSprite(String fileName) =>
      loadAssetBytes('sprites/$fileName.sprite');

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
    );

    spriteGroupHandsLeft[HandType.None] = spriteGroupEmpty;
    spriteGroupHandsRight[HandType.None] = spriteGroupEmpty;
    spriteGroupWeapons[WeaponType.Unarmed] = spriteGroupEmpty;
    spriteGroupHelms[HelmType.None] = spriteGroupEmpty;
    spriteGroupBody[BodyType.None] = spriteGroupEmpty;
    spriteGroupLegs[LegType.None] = spriteGroupEmpty;
    spriteGroupBodyArms[BodyType.None] = spriteGroupEmpty;

    // loadSp

    final fallenIdle = await loadSprite('fallen/idle');
    final fallenRunning = await loadSprite('fallen/run');
    final fallenStrike = await loadSprite('fallen/strike');
    final fallenHurt = await loadSprite('fallen/hurt');
    final fallenDeath = await loadSprite('fallen/death');

    spriteFallen = SpriteGroup(
      idle: Sprite.fromBytes(fallenIdle, image: character_fallen, y: 0, loop: true),
      running: Sprite.fromBytes(fallenRunning, image: character_fallen, y: 157, loop: true),
      strike: Sprite.fromBytes(fallenStrike, image: character_fallen, y: 338, loop: false),
      hurt: Sprite.fromBytes(fallenHurt, image: character_fallen, y: 524, loop: false),
      death: Sprite.fromBytes(fallenDeath, image: character_fallen, y: 707, loop: false),
    );

    final kidShadowIdle = await loadSprite('shadow/idle');
    final kidShadowRun = await loadSprite('shadow/run');
    final kidShadowStrike = await loadSprite('shadow/strike');

    spriteGroupKidShadow = SpriteGroup(
        idle: Sprite.fromBytes(kidShadowIdle, image: kid_shadow, y: 0, loop: true),
        running: Sprite.fromBytes(kidShadowRun, image: kid_shadow, y: 57, loop: true),
        strike: Sprite.fromBytes(kidShadowStrike, image: kid_shadow, y: 297, loop: false),
        hurt: spriteEmpty,
        death: spriteEmpty,
    );

    await loadSpriteGroupArmsLeft(
        complexion: ComplexionType.Fair,
        yIdle: 0,
        yRunning: 44,
        yStrike: 91,
        image: kid_arms_fair_left,
    );

    await loadSpriteGroupArmsRight(
        complexion: ComplexionType.Fair,
        yIdle: 0,
        yRunning: 44,
        yStrike: 91,
        image: kid_arms_fair_right,
    );

    await loadSpriteGroupBody(
        bodyType: BodyType.Shirt_Blue,
        yIdle: 0,
        yRunning: 51,
        yStrike: 153,
        image: kid_body_shirt_blue,
    );

    await loadSpriteGroupBodyArms(
        bodyType: BodyType.Shirt_Blue,
        yIdle: 0,
        yRunning: 41,
        yStrike: 83,
        image: kid_body_arms_shirt_blue,
    );

    await loadSpriteGroupHandsLeft(
        handType: HandType.Gauntlet,
        yIdle: 0,
        yRunning: 31,
        yStrike: 60,
        image: kid_hands_left_gauntlets,
    );

    await loadSpriteGroupHandsRight(
        handType: HandType.Gauntlet,
        yIdle: 0,
        yRunning: 29,
        yStrike: 57,
        image: kid_hands_right_gauntlets,
    );

    await loadSpriteGroupHead(
        complexion: ComplexionType.Fair,
        yIdle: 0,
        yRunning: 28,
        yStrike: 57,
        image: kid_head_fair,
    );

    await loadSpriteGroupHelm(
        type: HelmType.Steel,
        yIdle: 0,
        yRunning: 26,
        yStrike: 53,
        image: kid_helms_steel,
    );

    await loadSpriteGroupLegs(
        legType: LegType.Brown,
        yIdle: 0,
        yRunning: 71,
        yStrike: 233,
        image: kid_legs_brown,
    );

    await loadSpriteGroupTorso(
        complexion: ComplexionType.Fair,
        yIdle: 0,
        yRunning: 205,
        yStrike: 436,
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
}







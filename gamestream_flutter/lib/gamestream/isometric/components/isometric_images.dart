
import 'dart:async';
import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/src.dart';
import 'classes/sprite_group.dart';
import 'classes/sprite_group_sided.dart';

class IsometricImages with IsometricComponent {

  var imagesCached = true;

  final totalImages = Watch(0);
  final totalImagesLoaded = Watch(0);
  final totalSprites = Watch(0);
  final totalSpritesLoaded = Watch(0);
  final values = <Image>[];
  final _completerImages = Completer();
  final _completerSprites = Completer();

  final spriteGroupWeapons = <int, SpriteGroup> {};
  final spriteGroupGloves = <int, SpriteGroupSided> {};
  final spriteGroupArms = <int, SpriteGroupSided> {};
  final spriteGroupLegs = <int, SpriteGroup> {};
  final spriteGroupBody = <int, SpriteGroup> {};
  final spriteGroupBodyArms = <int, SpriteGroup> {};
  final spriteGroupHelms = <int, SpriteGroup> {};

  late final SpriteGroup spriteGroupEmpty;
  late final SpriteGroupSided spriteGroupSidedEmpty;

  late final Sprite spriteEmpty;
  late final Sprite spriteHeadIdle;
  late final Sprite spriteHeadRunning;
  late final Sprite spriteKidTorsoIdle;
  late final Sprite spriteKidTorsoRunning;
  late final Sprite spriteKidBodyArmShirtBlueIdle;
  late final Sprite spriteKidBodyArmShirtBlueRunning;
  late final Sprite spriteKidLegsBrownIdle;
  late final Sprite spriteKidLegsBrownRunning;

  late final Image empty;
  late final Image shades;
  late final Image pixel;
  late final Image atlas_projectiles;
  late final Image zombie;
  late final Image zombie_shadow;
  late final Image character_dog;
  late final Image atlas_particles;
  late final Image template_shadow;
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

  late final Image kid_weapons;
  late final Image kid_body;
  late final Image kid_skin;
  late final Image kid_legs;
  late final Image kid_gloves;
  late final Image kid_helms;

  late final Image template_head_none;
  late final Image template_head_rogue;
  late final Image template_head_steel;
  late final Image template_head_swat;
  late final Image template_head_wizard;
  late final Image template_head_blonde;

  late final Image template_body_none;
  late final Image template_body_blue;
  late final Image template_body_red;
  late final Image template_body_cyan;
  late final Image template_body_swat;
  late final Image template_body_tunic;

  late final Image template_legs_none;
  late final Image template_legs_blue;
  late final Image template_legs_white;
  late final Image template_legs_green;
  late final Image template_legs_brown;
  late final Image template_legs_red;
  late final Image template_legs_swat;

  late final Image template_weapon_bow;
  late final Image template_weapon_grenade;
  late final Image template_weapon_shotgun;
  late final Image template_weapon_desert_eagle;
  late final Image template_weapon_plasma_pistol;
  late final Image template_weapon_plasma_rifle;
  late final Image template_weapon_handgun_black;
  late final Image template_weapon_handgun_flintlock;
  late final Image template_weapon_sniper_rifle;
  late final Image template_weapon_ak47;
  late final Image template_weapon_mp5;
  late final Image template_weapon_staff;
  late final Image template_weapon_sword_steel;
  late final Image template_weapon_sword_wooden;
  late final Image template_weapon_pickaxe;
  late final Image template_weapon_axe;
  late final Image template_weapon_hammer;
  late final Image template_weapon_knife;
  late final Image template_weapon_flamethrower;
  late final Image template_weapon_bazooka;
  late final Image template_weapon_minigun;
  late final Image template_weapon_m4;
  late final Image template_weapon_revolver;
  late final Image template_weapon_winchester;
  late final Image template_weapon_musket;
  late final Image template_weapon_crowbar;
  late final Image template_weapon_portal_gun;

  Image getImageForHeadType(int headType) => switch (headType) {
         HeadType.None => template_head_none,
         HeadType.Rogue_Hood => template_head_rogue,
         HeadType.Steel_Helm => template_head_steel,
         HeadType.Wizards_Hat => template_head_wizard,
         HeadType.Blonde => template_head_blonde,
         HeadType.Swat => template_head_swat,
         _ => throw Exception('GameImages.getImageForHeadType($headType)')
      };

   Image getImageForBodyType(int bodyType) => switch (bodyType) {
        BodyType.None => template_body_none,
        BodyType.Shirt_Blue => template_body_blue,
        BodyType.Shirt_Red => template_body_red,
        BodyType.Shirt_Cyan => template_body_cyan,
        BodyType.Swat => template_body_swat,
        BodyType.Tunic_Padded => template_body_tunic,
        _ => throw Exception('GameImages.getImageForBodyType($bodyType)')
      };

  Image getImageForLegType(int legType) => switch (legType) {
    LegType.None => template_legs_none,
    LegType.White => template_legs_white,
    LegType.Blue => template_legs_blue,
    LegType.Green => template_legs_green,
    LegType.Brown => template_legs_brown,
    LegType.Red => template_legs_red,
    LegType.Swat => template_legs_swat,
         _ => throw Exception('GameImages.getImageForLegType(${legType})')
      };

   Image getImageForWeaponType(int weaponType) => switch (weaponType) {
         WeaponType.Machine_Gun => template_weapon_ak47,
         WeaponType.Plasma_Rifle => template_weapon_plasma_rifle,
         WeaponType.Knife => template_weapon_knife,
         WeaponType.Sniper_Rifle => template_weapon_sniper_rifle,
         WeaponType.Minigun => template_weapon_minigun,
         WeaponType.Musket => template_weapon_musket,
         WeaponType.Rifle => template_weapon_winchester,
         WeaponType.Smg => template_weapon_mp5,
         WeaponType.Plasma_Pistol => template_weapon_plasma_pistol,
         WeaponType.Handgun => template_weapon_handgun_black,
         WeaponType.Pistol => template_weapon_handgun_flintlock,
         WeaponType.Revolver => template_weapon_revolver,
         WeaponType.Shotgun => template_weapon_shotgun,
         WeaponType.Bow => template_weapon_bow,
         WeaponType.Staff => template_weapon_staff,
         WeaponType.Sword => template_weapon_sword_steel,
         WeaponType.Pickaxe => template_weapon_pickaxe,
         WeaponType.Axe => template_weapon_axe,
         WeaponType.Hammer => template_weapon_hammer,
         WeaponType.Crowbar => template_weapon_crowbar,
         WeaponType.Flame_Thrower => template_weapon_flamethrower,
         WeaponType.Bazooka => template_weapon_bazooka,
         WeaponType.Grenade => template_weapon_grenade,

         _ => throw Exception('GameImages.getImageForWeaponType($weaponType)')
      };

   Future<Sprite> loadSprite(String fileName, Image image, double y) async {
     totalSprites.value++;
     final bytes = await loadAssetBytes('sprites/$fileName.sprite');
     totalSpritesLoaded.value++;
     return Sprite.fromBytes(bytes, image: image, y: y);
   }

   Future loadSpriteWeapon({
     required int type,
     required double yIdle,
     required double yRunning,
    }) async {
     totalSprites.value++;
     final name = WeaponType.getName(type).toLowerCase();
     final idle = await loadAssetBytes('sprites/weapons/idle/${name}.sprite');
     final running = await loadAssetBytes('sprites/weapons/running/${name}.sprite');
     spriteGroupWeapons[type] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: kid_weapons, y: yIdle),
         running: Sprite.fromBytes(running, image: kid_weapons, y: yRunning),
     );
     totalSpritesLoaded.value++;
   }

   Future loadSpriteHelm({
     required int type,
     required double yIdle,
     required double yRunning,
    }) async {
     totalSprites.value++;
     final name = HelmType.getName(type).toLowerCase();
     final idle = await loadAssetBytes('sprites/helms/idle/${name}.sprite');
     final running = await loadAssetBytes('sprites/helms/running/${name}.sprite');
     spriteGroupHelms[type] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: kid_helms, y: yIdle),
         running: Sprite.fromBytes(running, image: kid_helms, y: yRunning),
     );
     totalSpritesLoaded.value++;
   }

   Future loadSpriteBody({
     required int type,
     required double yIdle,
     required double yRunning,
    }) async {
     totalSprites.value++;
     final name = BodyType.getName(type).toLowerCase();
     final idle = await loadAssetBytes('sprites/body/idle/${name}.sprite');
     final running = await loadAssetBytes('sprites/body/running/${name}.sprite');
     spriteGroupBody[type] = SpriteGroup(
         idle: Sprite.fromBytes(idle, image: kid_body, y: yIdle),
         running: Sprite.fromBytes(running, image: kid_body, y: yRunning),
     );
     totalSpritesLoaded.value++;
   }

   Future loadSpriteHands({
     required int type,
     required double yLeftIdle,
     required double yLeftRunning,
     required double yRightIdle,
     required double yRightRunning,
   }) async {
     totalSprites.value++;
     final name = HandType.getName(type).toLowerCase();
     final leftIdle = await loadAssetBytes('sprites/hands/left/${name}_idle.sprite');
     final leftRunning = await loadAssetBytes('sprites/hands/left/${name}_running.sprite');
     final rightIdle = await loadAssetBytes('sprites/hands/right/${name}_idle.sprite');
     final rightRunning = await loadAssetBytes('sprites/hands/right/${name}_running.sprite');
     spriteGroupGloves[type] = SpriteGroupSided(
         left: SpriteGroup(
           idle: Sprite.fromBytes(leftIdle, image: kid_gloves, y: yLeftIdle),
           running: Sprite.fromBytes(leftRunning, image: kid_gloves, y: yLeftRunning),
         ),
         right: SpriteGroup(
           idle: Sprite.fromBytes(rightIdle, image: kid_gloves, y: yRightIdle),
           running: Sprite.fromBytes(rightRunning, image: kid_gloves, y: yRightRunning),
         ),
     );
     totalSpritesLoaded.value++;
   }

   Future loadSpriteArms({
     required int complexion,
     required double yLeftIdle,
     required double yLeftRunning,
     required double yRightIdle,
     required double yRightRunning,
   }) async {
     totalSprites.value++;
     final name = ComplexionType.getName(complexion).toLowerCase();
     final leftIdle = await loadAssetBytes('sprites/arm/left/${name}_idle.sprite');
     final leftRunning = await loadAssetBytes('sprites/arm/left/${name}_running.sprite');
     final rightIdle = await loadAssetBytes('sprites/arm/right/${name}_idle.sprite');
     final rightRunning = await loadAssetBytes('sprites/arm/right/${name}_running.sprite');
     spriteGroupArms[complexion] = SpriteGroupSided(
         left: SpriteGroup(
           idle: Sprite.fromBytes(leftIdle, image: kid_skin, y: yLeftIdle),
           running: Sprite.fromBytes(leftRunning, image: kid_skin, y: yLeftRunning),
         ),
         right: SpriteGroup(
           idle: Sprite.fromBytes(rightIdle, image: kid_skin, y: yRightIdle),
           running: Sprite.fromBytes(rightRunning, image: kid_skin, y: yRightRunning),
         ),
     );
     totalSpritesLoaded.value++;
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
    loadPng('template/template_spinning').then((value) => template_spinning = value);

    loadPng('kid/kid_weapons').then((value) => kid_weapons = value);
    loadPng('kid/kid_body').then((value) => kid_body = value);
    loadPng('kid/kid_skin').then((value) => kid_skin = value);
    loadPng('kid/kid_legs').then((value) => kid_legs = value);
    loadPng('kid/kid_gloves').then((value) => kid_gloves = value);
    loadPng('kid/kid_helms').then((value) => kid_helms = value);

    loadPng('character-dog').then((value) => character_dog = value);
    loadPng('template/template-shadow').then((value) => template_shadow = value);

    loadPng('template/head/template-head-plain').then((value) => template_head_none = value);
    loadPng('template/head/template-head-rogue').then((value) => template_head_rogue = value);
    loadPng('template/head/template-head-steel').then((value) => template_head_steel = value);
    loadPng('template/head/template-head-swat').then((value) => template_head_swat = value);
    loadPng('template/head/template-head-wizard').then((value) => template_head_wizard = value);
    loadPng('template/head/template-head-blonde').then((value) => template_head_blonde = value);
    loadPng('template/body/template-body-blue').then((value) => template_body_blue = value);
    loadPng('template/body/template-body-red').then((value) => template_body_red = value);
    loadPng('template/body/template-body-cyan').then((value) => template_body_cyan = value);
    loadPng('template/body/template-body-swat').then((value) => template_body_swat = value);
    loadPng('template/body/template-body-tunic').then((value) => template_body_tunic = value);
    loadPng('template/body/template-body-empty').then((value) => template_body_none = value);
    loadPng('template/legs/template-legs-none').then((value) => template_legs_none = value);
    loadPng('template/legs/template-legs-blue').then((value) => template_legs_blue = value);
    loadPng('template/legs/template-legs-white').then((value) => template_legs_white = value);
    loadPng('template/legs/template-legs-green').then((value) => template_legs_green = value);
    loadPng('template/legs/template-legs-brown').then((value) => template_legs_brown = value);
    loadPng('template/legs/template-legs-red').then((value) => template_legs_red = value);
    loadPng('template/legs/template-legs-swat').then((value) => template_legs_swat = value);
    loadPng('template/weapons/template-weapons-bow').then((value) => template_weapon_bow = value);
    loadPng('template/weapons/template-weapons-grenade').then((value) => template_weapon_grenade = value);
    loadPng('template/weapons/template-weapons-desert-eagle').then((value) => template_weapon_desert_eagle = value);
    loadPng('template/weapons/template-weapons-plasma-pistol').then((value) => template_weapon_plasma_pistol = value);
    loadPng('template/weapons/template-weapons-plasma-rifle').then((value) => template_weapon_plasma_rifle = value);
    loadPng('template/weapons/template-weapons-handgun-black').then((value) => template_weapon_handgun_black = value);
    loadPng('template/weapons/template-weapons-pistol-flintlock').then((value) => template_weapon_handgun_flintlock = value);
    loadPng('template/weapons/template-weapons-sniper-rifle').then((value) => template_weapon_sniper_rifle = value);
    loadPng('template/weapons/template-weapons-ak47').then((value) => template_weapon_ak47 = value);
    loadPng('template/weapons/template-weapons-shotgun').then((value) => template_weapon_shotgun = value);
    loadPng('template/weapons/template-weapons-staff-wooden').then((value) => template_weapon_staff = value);
    loadPng('template/weapons/template-weapons-sword-steel').then((value) => template_weapon_sword_steel = value);
    loadPng('template/weapons/template-weapons-axe').then((value) => template_weapon_axe = value);
    loadPng('template/weapons/template-weapons-pickaxe').then((value) => template_weapon_pickaxe = value);
    loadPng('template/weapons/template-weapons-hammer').then((value) => template_weapon_hammer = value);
    loadPng('template/weapons/template-weapons-knife').then((value) => template_weapon_knife = value);
    loadPng('template/weapons/template-weapons-flamethrower').then((value) => template_weapon_flamethrower = value);
    loadPng('template/weapons/template-weapons-bazooka').then((value) => template_weapon_bazooka = value);
    loadPng('template/weapons/template-weapons-mp5').then((value) => template_weapon_mp5 = value);
    loadPng('template/weapons/template-weapons-minigun').then((value) => template_weapon_minigun = value);
    loadPng('template/weapons/template-weapons-m4').then((value) => template_weapon_m4 = value);
    loadPng('template/weapons/template-weapons-revolver').then((value) => template_weapon_revolver = value);
    loadPng('template/weapons/template-weapons-winchester').then((value) => template_weapon_winchester = value);
    loadPng('template/weapons/template-weapons-blunderbuss').then((value) => template_weapon_musket = value);
    loadPng('template/weapons/template-weapons-crowbar').then((value) => template_weapon_crowbar = value);
    loadPng('template/weapons/template-weapons-portal-gun').then((value) => template_weapon_portal_gun = value);

    loadPng('sprites/sprite-stars').then((value) => sprite_stars = value);
    loadPng('sprites/sprite-shield').then((value) => sprite_shield = value);

    totalImagesLoaded.onChanged((totalImagesLoaded) {
      if (totalImagesLoaded < totalImages.value)
        return;

      _completerImages.complete(true);
    });

    await _completerImages.future;

    loadSpriteHands(
      type: HandType.Gauntlet,
      yLeftIdle: 87,
      yLeftRunning: 58,
      yRightIdle: 31,
      yRightRunning: 0,
    );

    loadSpriteWeapon(
      type: WeaponType.Sword,
      yIdle: 51,
      yRunning: 0,
    );

    loadSpriteWeapon(
      type: WeaponType.Staff,
      yIdle: 114,
      yRunning: 195,
    );

    loadSpriteHelm(
      type: HelmType.Steel,
      yIdle: 27,
      yRunning: 0,
    );

    loadSpriteBody(
      type: BodyType.Shirt_Blue,
      yIdle: 0,
      yRunning: 51,
    );

    loadSpriteArms(
      complexion: ComplexionType.Fair,
      yLeftIdle: 57,
      yLeftRunning: 101,
      yRightIdle: 148,
      yRightRunning: 190,
    );

    loadSprite('kid_body_arm_shirt_blue_idle', kid_body, 153).then((value){
      spriteKidBodyArmShirtBlueIdle = value;
    });
    loadSprite('kid_body_arm_shirt_blue_running', kid_body, 194).then((value){
      spriteKidBodyArmShirtBlueRunning = value;
    });
    loadSprite('kid_legs_brown_idle', kid_legs, 0).then((value){
      spriteKidLegsBrownIdle = value;
    });
    loadSprite('kid_legs_brown_running', kid_legs, 71).then((value){
      spriteKidLegsBrownRunning = value;
    });
    loadSprite('kid_head_idle', kid_skin, 0).then((value){
      spriteHeadIdle = value;
    });
    loadSprite('kid_head_running', kid_skin, 28).then((value){
      spriteHeadRunning = value;
    });
    loadSprite('kid_torso_idle', kid_skin, 236).then((value){
      spriteKidTorsoIdle = value;
    });
    loadSprite('kid_torso_running', kid_skin, 441).then((value){
      spriteKidTorsoRunning = value;
    });

    spriteEmpty = Sprite(
        image: empty,
        values: Float32List(0),
        width: 0,
        height: 0,
        rows: 0,
        columns: 0,
        y: 0,
    );

    totalSpritesLoaded.onChanged((total) {
      if (total < totalSprites.value)
        return;

      _completerSprites.complete(true);
    });

    await _completerSprites.future;


    spriteGroupEmpty = SpriteGroup(
        idle: spriteEmpty,
        running: spriteEmpty,
    );

    spriteGroupSidedEmpty = SpriteGroupSided(
        left: spriteGroupEmpty,
        right: spriteGroupEmpty,
    );

    spriteGroupGloves[HandType.None] = spriteGroupSidedEmpty;
    spriteGroupWeapons[WeaponType.Unarmed] = spriteGroupEmpty;
    spriteGroupHelms[HelmType.None] = spriteGroupEmpty;
    spriteGroupBody[BodyType.None] = spriteGroupEmpty;
    spriteGroupLegs[LegType.None] = spriteGroupEmpty;
    spriteGroupBodyArms[BodyType.None] = spriteGroupEmpty;

    spriteGroupLegs[LegType.Brown] = SpriteGroup(
        idle: spriteKidLegsBrownIdle,
        running: spriteKidLegsBrownRunning,
    );

    spriteGroupBodyArms[BodyType.Shirt_Blue] = SpriteGroup(
        idle: spriteKidBodyArmShirtBlueIdle,
        running: spriteKidBodyArmShirtBlueRunning,
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







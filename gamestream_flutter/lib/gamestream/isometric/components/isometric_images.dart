
import 'dart:async';
import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/components/classes/image_group.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/src.dart';




class ImageGroupBody {
  final Image idle;
  final Image running;
  final Image armsIdle;
  final Image armsRunning;

  ImageGroupBody({
    required this.idle,
    required this.running,
    required this.armsIdle,
    required this.armsRunning,
  });
}


class IsometricImages with IsometricComponent {

  var imagesCached = true;

  final totalImages = Watch(0);
  final totalImagesLoaded = Watch(0);
  final totalSprites = Watch(0);
  final totalSpritesLoaded = Watch(0);
  final values = <Image>[];
  final _completerImages = Completer();
  final _completerSprites = Completer();

  final imageGroupsBody = <int, ImageGroupBody> {};
  final imageGroupsHands = <int, ImageGroupHands> {};


  late final Sprite spriteShirtBlueIdle;
  late final Sprite spriteShirtBlueRunning;

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
  late final Image kid_idle;
  late final Image kid_idle_shadow;
  late final Image kid_running;
  late final Image kid_running_shadow;

  late final Image kid_body_shirt_blue;
  late final Image kid_body_shirt_blue_idle;
  late final Image kid_body_shirt_blue_running;

  late final Image kid_body_arms_shirt_blue_idle;
  late final Image kid_body_arms_shirt_blue_running;

  late final Image kid_head_light_idle;
  late final Image kid_head_light_running;

  late final Image kid_head_dark_idle;
  late final Image kid_head_dark_running;

  late final Image kid_legs_brown_idle;
  late final Image kid_legs_brown_running;

  late final Image kid_hands_gauntlet_left_idle;
  late final Image kid_hands_gauntlet_left_running;

  late final Image kid_hands_gauntlet_right_idle;
  late final Image kid_hands_gauntlet_right_running;

  late final Image kid_arm_left_idle;
  late final Image kid_arm_left_running;

  late final Image kid_arm_right_idle;
  late final Image kid_arm_right_running;

  late final Image kid_torso_light_idle;
  late final Image kid_torso_light_running;

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

   // Future<Sprite> loadSprite(String fileName) async {
   //   totalImages.value++;
   //   final image = await loadImageAsset('sprites/$fileName.png');
   //   final bytes = await loadAssetBytes('sprites/$fileName.sprite');
   //   values.add(image);
   //   totalImagesLoaded.value++;
   //   return Sprite.fromBytes(bytes, image: image, y: 0);
   // }

   Future<Sprite> loadSprite(String fileName, Image image, double y) async {
     totalSprites.value++;
     final bytes = await loadAssetBytes('sprites/$fileName.sprite');
     totalSpritesLoaded.value++;
     return Sprite.fromBytes(bytes, image: image, y: y);
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

    loadPng('kid/kid_idle').then((value) => kid_idle = value);
    loadPng('kid/kid_idle_shadow').then((value) => kid_idle_shadow = value);

    loadPng('kid/kid_running').then((value) => kid_running = value);
    loadPng('kid/kid_running_shadow').then((value) => kid_running_shadow = value);

    loadPng('kid/arms/kid_arm_left_idle').then((value) => kid_arm_left_idle = value);
    loadPng('kid/arms/kid_arm_left_running').then((value) => kid_arm_left_running = value);

    loadPng('kid/hands/gauntlet/left/idle').then((value) => kid_hands_gauntlet_left_idle = value);
    loadPng('kid/hands/gauntlet/left/running').then((value) => kid_hands_gauntlet_left_running = value);

    loadPng('kid/hands/gauntlet/right/idle').then((value) => kid_hands_gauntlet_right_idle = value);
    loadPng('kid/hands/gauntlet/right/running').then((value) => kid_hands_gauntlet_right_running = value);

    loadPng('kid/arms/kid_arm_right_idle').then((value) => kid_arm_right_idle = value);
    loadPng('kid/arms/kid_arm_right_running').then((value) => kid_arm_right_running = value);

    loadPng('kid/torso/torso_light_idle').then((value) => kid_torso_light_idle = value);
    loadPng('kid/torso/torso_light_running').then((value) => kid_torso_light_running = value);

    loadPng('kid/body/shirt_blue').then((value) => kid_body_shirt_blue = value);

    loadPng('kid/body/idle/shirt_blue').then((value) => kid_body_shirt_blue_idle = value);
    loadPng('kid/body/running/shirt_blue').then((value) => kid_body_shirt_blue_running = value);

    loadPng('kid/body_arms/idle/shirt_blue').then((value) => kid_body_arms_shirt_blue_idle = value);
    loadPng('kid/body_arms/running/shirt_blue').then((value) => kid_body_arms_shirt_blue_running = value);

    loadPng('kid/head/kid_head_light_idle').then((value) => kid_head_light_idle = value);
    loadPng('kid/head/kid_head_light_running').then((value) => kid_head_light_running = value);

    loadPng('kid/head/kid_head_dark_idle').then((value) => kid_head_dark_idle = value);
    loadPng('kid/head/kid_head_dark_running').then((value) => kid_head_dark_running = value);

    loadPng('kid/legs/kid_legs_brown_idle').then((value) => kid_legs_brown_idle = value);
    loadPng('kid/legs/kid_legs_brown_running').then((value) => kid_legs_brown_running = value);

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

    loadSprite('shirt_blue_idle', kid_body_shirt_blue, 0).then((value){
      spriteShirtBlueIdle = value;
    });
    loadSprite('shirt_blue_running', kid_body_shirt_blue, 51).then((value){
      spriteShirtBlueRunning = value;
    });

    totalSpritesLoaded.onChanged((total) {
      if (total < totalSprites.value)
        return;

      _completerSprites.complete(true);
    });

    await _completerSprites.future;

    imageGroupsBody[BodyType.None] = ImageGroupBody(
      idle: empty,
      running: empty,
      armsIdle: empty,
      armsRunning: empty,
    );

    imageGroupsBody[BodyType.Shirt_Blue] = ImageGroupBody(
      idle: kid_body_shirt_blue_idle,
      running: kid_body_shirt_blue_running,
      armsIdle: kid_body_arms_shirt_blue_idle,
      armsRunning: kid_body_arms_shirt_blue_running,
    );

    imageGroupsHands[HandType.None] = ImageGroupHands(
       leftIdle: empty,
       leftRunning: empty,
       rightIdle: empty,
       rightRunning: empty,
    );

    imageGroupsHands[HandType.Gauntlet] = ImageGroupHands(
       leftIdle: kid_hands_gauntlet_left_idle,
       leftRunning: kid_hands_gauntlet_left_running,
       rightIdle: kid_hands_gauntlet_right_idle,
       rightRunning: kid_hands_gauntlet_right_running,
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








import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';

class Images {
   late final Image shades;
   late final Image pixel;
   late final Image atlas_projectiles;
   late final Image zombie;
   late final Image zombie_shadow;
   late final Image character_dog;
   late final Image atlas_particles;
   late final Image template_shadow;
   late final Image atlas_head;
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

   late final Image template_head_plain;
   late final Image template_head_rogue;
   late final Image template_head_steel;
   late final Image template_head_swat;
   late final Image template_head_wizard;
   late final Image template_head_blonde;

   late final Image template_body_empty;
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
         HeadType.Plain => template_head_plain,
         HeadType.Rogue_Hood => template_head_rogue,
         HeadType.Steel_Helm => template_head_steel,
         HeadType.Wizards_Hat => template_head_wizard,
         HeadType.Blonde => template_head_blonde,
         HeadType.Swat => template_head_swat,
         _ => throw Exception('GameImages.getImageForHeadType($headType)')
      };

   Image getImageForBodyType(int bodyType) => switch (bodyType) {
        BodyType.Nothing => template_body_empty,
        BodyType.Shirt_Blue => template_body_blue,
        BodyType.Shirt_Red => template_body_red,
        BodyType.Shirt_Cyan => template_body_cyan,
        BodyType.Swat => template_body_swat,
        BodyType.Tunic_Padded => template_body_tunic,
        _ => throw Exception('GameImages.getImageForBodyType($bodyType)')
      };

  Image getImageForLegType(int legType) => switch (legType) {
    LegType.Nothing => template_legs_none,
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

   final totalImages = Watch(0);
   final totalImagesLoaded = Watch(0);

   Future<Image> loadImage(String fileName) async {
     totalImages.value++;
     final image = await loadImageAsset('images/$fileName');
     totalImagesLoaded.value++;

     return image;
   }


   void load(Isometric isometric){
     print('isometric.images.load()');

     loadImage('shades.png').then((value) => shades = value);
     loadImage('atlas_nodes.png').then((value) => atlas_nodes = value);
     loadImage('atlas_characters.png').then((value) => atlas_characters = value);
     loadImage('atlas_zombie.png').then((value) => zombie = value);
     loadImage('atlas_zombie_shadow.png').then((value) => zombie_shadow = value);
     loadImage('atlas_gameobjects.png').then((value) => atlas_gameobjects = value);
     loadImage('atlas_gameobjects_transparent.png').then((value) => atlas_gameobjects_transparent = value);
     loadImage('atlas_particles.png').then((value) => atlas_particles = value);
     loadImage('atlas_projectiles.png').then((value) => atlas_projectiles = value);
     loadImage('atlas_nodes_transparent.png').then((value) => atlas_nodes_transparent = value);
     loadImage('atlas_nodes_mini.png').then((value) => atlas_nodes_mini = value);
     loadImage('atlas_weapons.png').then((value) => atlas_weapons = value);
     loadImage('atlas_talents.png').then((value) => atlas_talents = value);
     loadImage('atlas_icons.png').then((value) => atlas_icons = value);
     loadImage('atlas_items.png').then((value) => atlas_items = value);
     loadImage('atlas_head.png').then((value) => atlas_head = value);
     loadImage('atlas_body.png').then((value) => atlas_body = value);
     loadImage('atlas_legs.png').then((value) => atlas_legs = value);
     loadImage('character-dog.png').then((value) => character_dog = value);
     loadImage('template/template-shadow.png').then((value) => template_shadow = value);
     loadImage('template/head/template-head-plain.png').then((value) => template_head_plain = value);
     loadImage('template/head/template-head-rogue.png').then((value) => template_head_rogue = value);
     loadImage('template/head/template-head-steel.png').then((value) => template_head_steel = value);
     loadImage('template/head/template-head-swat.png').then((value) => template_head_swat = value);
     loadImage('template/head/template-head-wizard.png').then((value) => template_head_wizard = value);
     loadImage('template/head/template-head-blonde.png').then((value) => template_head_blonde = value);
     loadImage('template/body/template-body-blue.png').then((value) => template_body_blue = value);
     loadImage('template/body/template-body-red.png').then((value) => template_body_red = value);
     loadImage('template/body/template-body-cyan.png').then((value) => template_body_cyan = value);
     loadImage('template/body/template-body-swat.png').then((value) => template_body_swat = value);
     loadImage('template/body/template-body-tunic.png').then((value) => template_body_tunic = value);
     loadImage('template/body/template-body-empty.png').then((value) => template_body_empty = value);
     loadImage('template/legs/template-legs-none.png').then((value) => template_legs_none = value);
     loadImage('template/legs/template-legs-blue.png').then((value) => template_legs_blue = value);
     loadImage('template/legs/template-legs-white.png').then((value) => template_legs_white = value);
     loadImage('template/legs/template-legs-green.png').then((value) => template_legs_green = value);
     loadImage('template/legs/template-legs-brown.png').then((value) => template_legs_brown = value);
     loadImage('template/legs/template-legs-red.png').then((value) => template_legs_red = value);
     loadImage('template/legs/template-legs-swat.png').then((value) => template_legs_swat = value);
     loadImage('template/weapons/template-weapons-bow.png').then((value) => template_weapon_bow = value);
     loadImage('template/weapons/template-weapons-grenade.png').then((value) => template_weapon_grenade = value);
     loadImage('template/weapons/template-weapons-desert-eagle.png').then((value) => template_weapon_desert_eagle = value);
     loadImage('template/weapons/template-weapons-plasma-pistol.png').then((value) => template_weapon_plasma_pistol = value);
     loadImage('template/weapons/template-weapons-plasma-rifle.png').then((value) => template_weapon_plasma_rifle = value);
     loadImage('template/weapons/template-weapons-handgun-black.png').then((value) => template_weapon_handgun_black = value);
     loadImage('template/weapons/template-weapons-pistol-flintlock.png').then((value) => template_weapon_handgun_flintlock = value);
     loadImage('template/weapons/template-weapons-sniper-rifle.png').then((value) => template_weapon_sniper_rifle = value);
     loadImage('template/weapons/template-weapons-ak47.png').then((value) => template_weapon_ak47 = value);
     loadImage('template/weapons/template-weapons-shotgun.png').then((value) => template_weapon_shotgun = value);
     loadImage('template/weapons/template-weapons-staff-wooden.png').then((value) => template_weapon_staff = value);
     loadImage('template/weapons/template-weapons-sword-steel.png').then((value) => template_weapon_sword_steel = value);
     loadImage('template/weapons/template-weapons-axe.png').then((value) => template_weapon_axe = value);
     loadImage('template/weapons/template-weapons-pickaxe.png').then((value) => template_weapon_pickaxe = value);
     loadImage('template/weapons/template-weapons-hammer.png').then((value) => template_weapon_hammer = value);
     loadImage('template/weapons/template-weapons-knife.png').then((value) => template_weapon_knife = value);
     loadImage('template/weapons/template-weapons-flamethrower.png').then((value) => template_weapon_flamethrower = value);
     loadImage('template/weapons/template-weapons-bazooka.png').then((value) => template_weapon_bazooka = value);
     loadImage('template/weapons/template-weapons-mp5.png').then((value) => template_weapon_mp5 = value);
     loadImage('template/weapons/template-weapons-minigun.png').then((value) => template_weapon_minigun = value);
     loadImage('template/weapons/template-weapons-m4.png').then((value) => template_weapon_m4 = value);
     loadImage('template/weapons/template-weapons-revolver.png').then((value) => template_weapon_revolver = value);
     loadImage('template/weapons/template-weapons-winchester.png').then((value) => template_weapon_winchester = value);
     loadImage('template/weapons/template-weapons-blunderbuss.png').then((value) => template_weapon_musket = value);
     loadImage('template/weapons/template-weapons-crowbar.png').then((value) => template_weapon_crowbar = value);
     loadImage('template/weapons/template-weapons-portal-gun.png').then((value) => template_weapon_portal_gun = value);

     loadImage('sprites/sprite-stars.png').then((value) => sprite_stars = value);
     loadImage('sprites/sprite-shield.png').then((value) => sprite_shield = value);

     totalImagesLoaded.onChanged((totalImagesLoaded) {
       if (totalImagesLoaded < totalImages.value)
         return;

       isometric.notifyLoadImagesCompleted();
     });
   }
}







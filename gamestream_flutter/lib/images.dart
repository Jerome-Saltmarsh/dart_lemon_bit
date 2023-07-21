
import 'dart:ui';
import 'package:gamestream_flutter/common.dart';
import 'package:lemon_engine/lemon_engine.dart';

class Images {
   static late Image shades;
   static late Image pixel;
   static late Image projectiles;
   static late Image zombie;
   static late Image zombie_shadow;
   static late Image character_dog;
   static late Image atlas_particles;
   static late Image template_shadow;
   static late Image atlas_head;
   static late Image atlas_body;
   static late Image atlas_legs;
   static late Image atlas_gameobjects;
   static late Image atlas_gameobjects_transparent;
   static late Image atlas_nodes;
   static late Image atlas_nodes_transparent;
   static late Image atlas_characters;
   static late Image atlas_icons;
   static late Image atlas_items;
   static late Image atlas_fight2d;
   static late Image atlas_fight2d_character;
   static late Image atlas_fight2d_nodes;
   static late Image atlas_nodes_mini;
   static late Image atlas_weapons;
   static late Image atlas_talents;
   static late Image sprite_stars;
   static late Image sprite_shield;

   static late Image template_head_plain;
   static late Image template_head_rogue;
   static late Image template_head_steel;
   static late Image template_head_swat;
   static late Image template_head_wizard;
   static late Image template_head_blonde;

   static late Image template_body_empty;
   static late Image template_body_blue;
   static late Image template_body_red;
   static late Image template_body_cyan;
   static late Image template_body_swat;
   static late Image template_body_tunic;

   static late Image template_legs_none;
   static late Image template_legs_blue;
   static late Image template_legs_white;
   static late Image template_legs_green;
   static late Image template_legs_brown;
   static late Image template_legs_red;
   static late Image template_legs_swat;

   static late Image template_weapon_bow;
   static late Image template_weapon_grenade;
   static late Image template_weapon_shotgun;
   static late Image template_weapon_desert_eagle;
   static late Image template_weapon_plasma_pistol;
   static late Image template_weapon_plasma_rifle;
   static late Image template_weapon_handgun_black;
   static late Image template_weapon_handgun_flintlock;
   static late Image template_weapon_sniper_rifle;
   static late Image template_weapon_ak47;
   static late Image template_weapon_mp5;
   static late Image template_weapon_staff;
   static late Image template_weapon_sword_steel;
   static late Image template_weapon_sword_wooden;
   static late Image template_weapon_pickaxe;
   static late Image template_weapon_axe;
   static late Image template_weapon_hammer;
   static late Image template_weapon_knife;
   static late Image template_weapon_flamethrower;
   static late Image template_weapon_bazooka;
   static late Image template_weapon_minigun;
   static late Image template_weapon_m4;
   static late Image template_weapon_revolver;
   static late Image template_weapon_winchester;
   static late Image template_weapon_musket;
   static late Image template_weapon_crowbar;
   static late Image template_weapon_portal_gun;

   static Image getImageForHeadType(int headType) => switch (headType) {
         HeadType.Plain => template_head_plain,
         HeadType.Rogue_Hood => template_head_rogue,
         HeadType.Steel_Helm => template_head_steel,
         HeadType.Wizards_Hat => template_head_wizard,
         HeadType.Blonde => template_head_blonde,
         HeadType.Swat => template_head_swat,
         _ => throw Exception('GameImages.getImageForHeadType($headType)')
      };

   static Image getImageForBodyType(int bodyType) => switch (bodyType) {
        BodyType.Nothing => template_body_empty,
        BodyType.Shirt_Blue => template_body_blue,
        BodyType.Shirt_Red => template_body_red,
        BodyType.Shirt_Cyan => template_body_cyan,
        BodyType.Swat => template_body_swat,
        BodyType.Tunic_Padded => template_body_tunic,
        _ => throw Exception('GameImages.getImageForBodyType($bodyType)')
      };

  static Image getImageForLegType(int legType) => switch (legType) {
    LegType.Nothing => template_legs_none,
    LegType.White => template_legs_white,
    LegType.Blue => template_legs_blue,
    LegType.Green => template_legs_green,
    LegType.Brown => template_legs_brown,
    LegType.Red => template_legs_red,
    LegType.Swat => template_legs_swat,
         _ => throw Exception('GameImages.getImageForLegType(${legType})')
      };

   static Image getImageForWeaponType(int weaponType) => switch (weaponType) {
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

   static void loadImages() {
      Engine.loadImageAsset('images/shades.png').then((value) => shades = value);
      Engine.loadImageAsset('images/atlas-characters.png').then((value) => atlas_characters = value);
      Engine.loadImageAsset('images/atlas-zombie.png').then((value) => zombie = value);
      Engine.loadImageAsset('images/atlas-zombie-shadow.png').then((value) => zombie_shadow = value);
      Engine.loadImageAsset('images/atlas-gameobjects.png').then((value) => atlas_gameobjects = value);
      Engine.loadImageAsset('images/atlas-gameobjects-transparent.png').then((value) => atlas_gameobjects_transparent = value);
      Engine.loadImageAsset('images/atlas-particles.png').then((value) => atlas_particles = value);
      Engine.loadImageAsset('images/atlas-projectiles.png').then((value) => projectiles = value);
      Engine.loadImageAsset('images/atlas-nodes.png').then((value) => atlas_nodes = value);
      Engine.loadImageAsset('images/atlas-nodes-transparent.png').then((value) => atlas_nodes_transparent = value);
      Engine.loadImageAsset('images/atlas-nodes-mini.png').then((value) => atlas_nodes_mini = value);
      Engine.loadImageAsset('images/atlas_weapons.png').then((value) => atlas_weapons = value);
      Engine.loadImageAsset('images/atlas_talents.png').then((value) => atlas_talents = value);
      Engine.loadImageAsset('images/atlas-icons.png').then((value) => atlas_icons = value);
      Engine.loadImageAsset('images/atlas_items.png').then((value) => atlas_items = value);
      Engine.loadImageAsset('images/atlas_head.png').then((value) => atlas_head = value);
      Engine.loadImageAsset('images/atlas_body.png').then((value) => atlas_body = value);
      Engine.loadImageAsset('images/atlas_legs.png').then((value) => atlas_legs = value);
      Engine.loadImageAsset('images/character-dog.png').then((value) => character_dog = value);
      Engine.loadImageAsset('images/template/template-shadow.png').then((value) => template_shadow = value);
      Engine.loadImageAsset('images/template/head/template-head-plain.png').then((value) => template_head_plain = value);
      Engine.loadImageAsset('images/template/head/template-head-rogue.png').then((value) => template_head_rogue = value);
      Engine.loadImageAsset('images/template/head/template-head-steel.png').then((value) => template_head_steel = value);
      Engine.loadImageAsset('images/template/head/template-head-swat.png').then((value) => template_head_swat = value);
      Engine.loadImageAsset('images/template/head/template-head-wizard.png').then((value) => template_head_wizard = value);
      Engine.loadImageAsset('images/template/head/template-head-blonde.png').then((value) => template_head_blonde = value);
      Engine.loadImageAsset('images/template/body/template-body-blue.png').then((value) => template_body_blue = value);
      Engine.loadImageAsset('images/template/body/template-body-red.png').then((value) => template_body_red = value);
      Engine.loadImageAsset('images/template/body/template-body-cyan.png').then((value) => template_body_cyan = value);
      Engine.loadImageAsset('images/template/body/template-body-swat.png').then((value) => template_body_swat = value);
      Engine.loadImageAsset('images/template/body/template-body-tunic.png').then((value) => template_body_tunic = value);
      Engine.loadImageAsset('images/template/body/template-body-empty.png').then((value) => template_body_empty = value);
      Engine.loadImageAsset('images/template/legs/template-legs-none.png').then((value) => template_legs_none = value);
      Engine.loadImageAsset('images/template/legs/template-legs-blue.png').then((value) => template_legs_blue = value);
      Engine.loadImageAsset('images/template/legs/template-legs-white.png').then((value) => template_legs_white = value);
      Engine.loadImageAsset('images/template/legs/template-legs-green.png').then((value) => template_legs_green = value);
      Engine.loadImageAsset('images/template/legs/template-legs-brown.png').then((value) => template_legs_brown = value);
      Engine.loadImageAsset('images/template/legs/template-legs-red.png').then((value) => template_legs_red = value);
      Engine.loadImageAsset('images/template/legs/template-legs-swat.png').then((value) => template_legs_swat = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-bow.png').then((value) => template_weapon_bow = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-grenade.png').then((value) => template_weapon_grenade = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-desert-eagle.png').then((value) => template_weapon_desert_eagle = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-plasma-pistol.png').then((value) => template_weapon_plasma_pistol = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-plasma-rifle.png').then((value) => template_weapon_plasma_rifle = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-handgun-black.png').then((value) => template_weapon_handgun_black = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-pistol-flintlock.png').then((value) => template_weapon_handgun_flintlock = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-sniper-rifle.png').then((value) => template_weapon_sniper_rifle = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-ak47.png').then((value) => template_weapon_ak47 = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-shotgun.png').then((value) => template_weapon_shotgun = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-staff-wooden.png').then((value) => template_weapon_staff = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-sword-steel.png').then((value) => template_weapon_sword_steel = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-axe.png').then((value) => template_weapon_axe = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-pickaxe.png').then((value) => template_weapon_pickaxe = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-hammer.png').then((value) => template_weapon_hammer = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-knife.png').then((value) => template_weapon_knife = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-flamethrower.png').then((value) => template_weapon_flamethrower = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-bazooka.png').then((value) => template_weapon_bazooka = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-mp5.png').then((value) => template_weapon_mp5 = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-minigun.png').then((value) => template_weapon_minigun = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-m4.png').then((value) => template_weapon_m4 = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-revolver.png').then((value) => template_weapon_revolver = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-winchester.png').then((value) => template_weapon_winchester = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-blunderbuss.png').then((value) => template_weapon_musket = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-crowbar.png').then((value) => template_weapon_crowbar = value);
      Engine.loadImageAsset('images/template/weapons/template-weapons-portal-gun.png').then((value) => template_weapon_portal_gun = value);

      Engine.loadImageAsset('images/sprites/sprite-stars.png').then((value) => sprite_stars = value);
      Engine.loadImageAsset('images/sprites/sprite-shield.png').then((value) => sprite_shield = value);

      Engine.loadImageAsset('images/atlas-fight2d.png').then((value) => atlas_fight2d = value);
      Engine.loadImageAsset('images/atlas-fight2d-nodes.png').then((value) => atlas_fight2d_nodes = value);
      Engine.loadImageAsset('images/atlas-fight2d-character.png').then((value) => atlas_fight2d_character = value);
   }

   static Image getImageForGameObject(int type){
     switch(type){
       case GameObjectType.Weapon:
         return atlas_weapons;
       default:
         throw Exception();
     }
   }
}







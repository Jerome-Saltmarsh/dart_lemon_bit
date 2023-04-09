
import 'dart:ui';

import 'package:bleed_common/src.dart';
import 'package:lemon_engine/lemon_engine.dart';

class GameImages {
   static late Image shades;
   static late Image pixel;
   static late Image projectiles;
   static late Image zombie;
   static late Image zombie_shadow;
   static late Image character_dog;
   static late Image atlas_particles;
   static late Image template_shadow;
   static late Image atlas_gameobjects;
   static late Image atlas_gameobjects_transparent;
   static late Image atlas_nodes;
   static late Image atlas_nodes_transparent;
   static late Image atlas_characters;
   static late Image atlas_icons;
   static late Image atlas_items;
   static late Image atlas_nodes_mini;
   static late Image atlas_weapons;
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

   static Image getImageForHeadType(int headType) {
      switch (headType) {
         case ItemType.Empty:
            return template_head_plain;
         case ItemType.Head_Rogues_Hood:
            return template_head_rogue;
         case ItemType.Head_Steel_Helm:
            return template_head_steel;
         case ItemType.Head_Wizards_Hat:
            return template_head_wizard;
         case ItemType.Head_Blonde:
            return template_head_blonde;
         case ItemType.Head_Swat:
            return template_head_swat;
         default:
            throw Exception('GameImages.getImageForHeadType(${ItemType.getName(headType)})');
      }
   }

   static Image getImageForBodyType(int bodyType) {
      switch (bodyType) {
         case ItemType.Empty:
            return template_body_empty;
         case ItemType.Body_Shirt_Blue:
            return template_body_blue;
         case ItemType.Body_Shirt_Cyan:
            return template_body_cyan;
         case ItemType.Body_Swat:
            return template_body_swat;
         case ItemType.Body_Tunic_Padded:
            return template_body_tunic;
         default:
            throw Exception('GameImages.getImageForBodyType(${ItemType.getName(bodyType)})');
      }
   }

   static Image getImageForLegType(int legType) {
      switch (legType) {
         case ItemType.Empty:
            return template_legs_none;
         case ItemType.Legs_White:
            return template_legs_white;
         case ItemType.Legs_Blue:
            return template_legs_blue;
         case ItemType.Legs_Green:
            return template_legs_green;
         case ItemType.Legs_Brown:
            return template_legs_brown;
         case ItemType.Legs_Red:
            return template_legs_red;
         case ItemType.Legs_Swat:
            return template_legs_swat;
         default:
            throw Exception('GameImages.getImageForLegType(${ItemType.getName(legType)})');
      }
   }

   static Image getImageForWeaponType(int weaponType) {
      switch (weaponType) {
         case ItemType.Weapon_Ranged_Machine_Gun:
            return template_weapon_ak47;
         case ItemType.Weapon_Ranged_Teleport:
            return template_weapon_portal_gun;
         case ItemType.Weapon_Ranged_Plasma_Rifle:
            return template_weapon_plasma_rifle;
         case ItemType.Weapon_Melee_Knife:
            return template_weapon_knife;
         case ItemType.Weapon_Ranged_Sniper_Rifle:
            return template_weapon_sniper_rifle;
         case ItemType.Weapon_Ranged_Minigun:
            return template_weapon_minigun;
         case ItemType.Weapon_Ranged_Musket:
            return template_weapon_musket;
         case ItemType.Weapon_Ranged_Rifle:
            return template_weapon_winchester;
         case ItemType.Weapon_Ranged_Smg:
            return template_weapon_mp5;
         case ItemType.Weapon_Ranged_Desert_Eagle:
            return template_weapon_desert_eagle;
         case ItemType.Weapon_Ranged_Plasma_Pistol:
            return template_weapon_plasma_pistol;
         case ItemType.Weapon_Ranged_Handgun:
            return template_weapon_handgun_black;
         case ItemType.Weapon_Ranged_Pistol:
            return template_weapon_handgun_flintlock;
         case ItemType.Weapon_Ranged_Revolver:
            return template_weapon_revolver;
         case ItemType.Weapon_Ranged_Shotgun:
            return template_weapon_shotgun;
         case ItemType.Weapon_Ranged_Bow:
            return template_weapon_bow;
         case ItemType.Weapon_Melee_Staff:
            return template_weapon_staff;
         case ItemType.Weapon_Melee_Sword:
            return template_weapon_sword_steel;
         case ItemType.Weapon_Melee_Pickaxe:
            return template_weapon_pickaxe;
         case ItemType.Weapon_Melee_Axe:
            return template_weapon_axe;
         case ItemType.Weapon_Melee_Hammer:
            return template_weapon_hammer;
         case ItemType.Weapon_Melee_Crowbar:
            return template_weapon_crowbar;
         case ItemType.Weapon_Ranged_Minigun:
            return template_weapon_minigun;
         case ItemType.Weapon_Ranged_Revolver:
            return template_weapon_revolver;
         case ItemType.Weapon_Ranged_Flamethrower:
            return template_weapon_flamethrower;
         case ItemType.Weapon_Ranged_Bazooka:
            return template_weapon_bazooka;
         case ItemType.Weapon_Thrown_Grenade:
            return template_weapon_grenade;

         default:
            throw Exception("GameImages.getImageForWeaponType(${ItemType.getName(weaponType)})");
      }
   }

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
      Engine.loadImageAsset('images/atlas-weapons.png').then((value) => atlas_weapons = value);
      Engine.loadImageAsset('images/atlas-icons.png').then((value) => atlas_icons = value);
      Engine.loadImageAsset('images/atlas-items.png').then((value) => atlas_items = value);
      Engine.loadImageAsset('images/character-dog.png').then((value) => character_dog = value);
      Engine.loadImageAsset('images/template/template-shadow.png').then((value) => template_shadow = value);
      Engine.loadImageAsset('images/template/head/template-head-plain.png').then((value) => template_head_plain = value);
      Engine.loadImageAsset('images/template/head/template-head-rogue.png').then((value) => template_head_rogue = value);
      Engine.loadImageAsset('images/template/head/template-head-steel.png').then((value) => template_head_steel = value);
      Engine.loadImageAsset('images/template/head/template-head-swat.png').then((value) => template_head_swat = value);
      Engine.loadImageAsset('images/template/head/template-head-wizard.png').then((value) => template_head_wizard = value);
      Engine.loadImageAsset('images/template/head/template-head-blonde.png').then((value) => template_head_blonde = value);
      Engine.loadImageAsset('images/template/body/template-body-blue.png').then((value) => template_body_blue = value);
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
   }
}







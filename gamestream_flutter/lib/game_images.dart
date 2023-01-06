
import 'dart:ui';

import 'package:bleed_common/library.dart';
import 'package:lemon_engine/engine.dart';

class GameImages {
   static late Image pixel;
   static late Image minimap;
   static late Image projectiles;
   static late Image zombie;
   static late Image zombie_shadow;
   static late Image character_dog;
   static late Image particles;
   static late Image template_shadow;
   static late Image atlas_gameobjects;
   static late Image atlas_nodes;
   static late Image atlas_nodes_transparent;
   static late Image atlas_characters;
   static late Image atlas_icons;
   static late Image atlas_items;
   static late Image atlas_nodes_mini;

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
   static late Image template_weapon_handgun;
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
   static late Image template_weapon_blunderbuss;

   static late Image template;

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
      if (ItemType.isTypeWeaponThrown(weaponType)){
         return template_weapon_grenade;
      }
      switch (weaponType) {
         case ItemType.Weapon_Melee_Knife:
            return template_weapon_knife;
         case ItemType.Weapon_Rifle_Sniper:
            return template_weapon_sniper_rifle;
         case ItemType.Weapon_Rifle_AK_47:
            return template_weapon_ak47;
         case ItemType.Weapon_Rifle_M4:
            return template_weapon_m4;
         case ItemType.Weapon_Rifle_Arquebus:
            return template_weapon_blunderbuss;
         case ItemType.Weapon_Rifle_Musket:
            return template_weapon_winchester;
         case ItemType.Weapon_Rifle_Blunderbuss:
            return template_weapon_blunderbuss;
         case ItemType.Weapon_Rifle_Jager:
            return template_weapon_winchester;
         case ItemType.Weapon_Smg_Mp5:
            return template_weapon_mp5;
         case ItemType.Weapon_Handgun_Desert_Eagle:
            return template_weapon_handgun;
         case ItemType.Weapon_Handgun_Glock:
            return template_weapon_handgun_black;
         case ItemType.Weapon_Handgun_Flint_Lock_Old:
            return template_weapon_handgun_flintlock;
         case ItemType.Weapon_Handgun_Flint_Lock:
            return template_weapon_handgun_flintlock;
         case ItemType.Weapon_Handgun_Flint_Lock_Superior:
            return template_weapon_handgun_flintlock;
         case ItemType.Weapon_Handgun_Revolver:
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
         case ItemType.Weapon_Special_Minigun:
            return template_weapon_minigun;
         case ItemType.Weapon_Handgun_Revolver:
            return template_weapon_revolver;
         case ItemType.Weapon_Flamethrower:
            return template_weapon_flamethrower;
         case ItemType.Weapon_Special_Bazooka:
            return template_weapon_bazooka;
         default:
            throw Exception("GameImages.getImageForWeaponType(${ItemType.getName(weaponType)})");
      }
   }
   
   static Future loadImages() async {
      atlas_characters
      = await Engine.loadImageAsset('images/atlas-characters.png');
      zombie
      = await Engine.loadImageAsset('images/atlas-zombie.png');
      zombie_shadow
      = await Engine.loadImageAsset('images/atlas-zombie-shadow.png');
      atlas_gameobjects
      = await Engine.loadImageAsset('images/atlas-gameobjects.png');
      particles
      = await Engine.loadImageAsset('images/atlas-particles.png');
      projectiles
      = await Engine.loadImageAsset('images/atlas-projectiles.png');
      template_shadow
      = await Engine.loadImageAsset('images/template/template-shadow.png');
      minimap
      = await Engine.loadImageAsset('images/atlas-map.png');
      atlas_nodes
      = await Engine.loadImageAsset('images/atlas-nodes.png');
      atlas_nodes_transparent
      = await Engine.loadImageAsset('images/atlas-nodes-transparent.png');
      atlas_nodes_mini
      = await Engine.loadImageAsset('images/atlas-nodes-mini.png');
      atlas_icons
      = await Engine.loadImageAsset('images/atlas-icons.png');
      atlas_items
      = await Engine.loadImageAsset('images/atlas-items.png');

      template_head_plain = await Engine.loadImageAsset('images/template/head/template-head-plain.png');
      template_head_rogue = await Engine.loadImageAsset('images/template/head/template-head-rogue.png');
      template_head_steel = await Engine.loadImageAsset('images/template/head/template-head-steel.png');
      template_head_swat = await Engine.loadImageAsset('images/template/head/template-head-swat.png');
      template_head_wizard = await Engine.loadImageAsset('images/template/head/template-head-wizard.png');
      template_head_blonde = await Engine.loadImageAsset('images/template/head/template-head-blonde.png');

      template_body_blue = await Engine.loadImageAsset('images/template/body/template-body-blue.png');
      template_body_cyan = await Engine.loadImageAsset('images/template/body/template-body-cyan.png');
      template_body_swat = await Engine.loadImageAsset('images/template/body/template-body-swat.png');
      template_body_tunic = await Engine.loadImageAsset('images/template/body/template-body-tunic.png');
      template_body_empty = await Engine.loadImageAsset('images/template/body/template-body-empty.png');

      template_legs_none = await Engine.loadImageAsset('images/template/legs/template-legs-none.png');
      template_legs_blue = await Engine.loadImageAsset('images/template/legs/template-legs-blue.png');
      template_legs_white = await Engine.loadImageAsset('images/template/legs/template-legs-white.png');
      template_legs_green = await Engine.loadImageAsset('images/template/legs/template-legs-green.png');
      template_legs_brown = await Engine.loadImageAsset('images/template/legs/template-legs-brown.png');
      template_legs_red = await Engine.loadImageAsset('images/template/legs/template-legs-red.png');
      template_legs_swat = await Engine.loadImageAsset('images/template/legs/template-legs-swat.png');

      template_weapon_bow = await Engine.loadImageAsset('images/template/weapons/template-weapons-bow.png');
      template_weapon_grenade = await Engine.loadImageAsset('images/template/weapons/template-weapons-grenade.png');
      template_weapon_handgun = await Engine.loadImageAsset('images/template/weapons/template-weapons-handgun.png');
      template_weapon_handgun_black = await Engine.loadImageAsset('images/template/weapons/template-weapons-handgun-black.png');
      template_weapon_handgun_flintlock = await Engine.loadImageAsset('images/template/weapons/template-weapons-pistol-flintlock.png');
      template_weapon_sniper_rifle = await Engine.loadImageAsset('images/template/weapons/template-weapons-sniper-rifle.png');
      template_weapon_ak47 = await Engine.loadImageAsset('images/template/weapons/template-weapons-ak47.png');
      template_weapon_shotgun = await Engine.loadImageAsset('images/template/weapons/template-weapons-shotgun.png');
      template_weapon_staff = await Engine.loadImageAsset('images/template/weapons/template-weapons-staff-wooden.png');
      template_weapon_sword_steel = await Engine.loadImageAsset('images/template/weapons/template-weapons-sword-steel.png');
      template_weapon_axe = await Engine.loadImageAsset('images/template/weapons/template-weapons-axe.png');
      template_weapon_pickaxe = await Engine.loadImageAsset('images/template/weapons/template-weapons-pickaxe.png');
      template_weapon_hammer = await Engine.loadImageAsset('images/template/weapons/template-weapons-hammer.png');
      template_weapon_knife = await Engine.loadImageAsset('images/template/weapons/template-weapons-knife.png');
      template_weapon_flamethrower = await Engine.loadImageAsset('images/template/weapons/template-weapons-flamethrower.png');
      template_weapon_bazooka = await Engine.loadImageAsset('images/template/weapons/template-weapons-bazooka.png');
      template_weapon_mp5 = await Engine.loadImageAsset('images/template/weapons/template-weapons-mp5.png');
      template_weapon_minigun = await Engine.loadImageAsset('images/template/weapons/template-weapons-minigun.png');
      template_weapon_m4 = await Engine.loadImageAsset('images/template/weapons/template-weapons-m4.png');
      template_weapon_revolver = await Engine.loadImageAsset('images/template/weapons/template-weapons-revolver.png');
      template_weapon_winchester = await Engine.loadImageAsset('images/template/weapons/template-weapons-winchester.png');
      template_weapon_blunderbuss = await Engine.loadImageAsset('images/template/weapons/template-weapons-blunderbuss.png');

      character_dog = await Engine.loadImageAsset('images/character-dog.png');
      template = await Engine.loadImageAsset('images/atlas-character-template.png');
   }
}





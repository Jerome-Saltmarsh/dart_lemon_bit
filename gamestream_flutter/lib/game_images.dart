
import 'dart:ui';

import 'package:bleed_common/library.dart';

class GameImages {
   static late Image pixel;
   static late Image mapAtlas;
   static late Image blocks;
   static late Image characters;
   static late Image projectiles;
   static late Image zombie;
   static late Image templateShadow;
   static late Image gameobjects;
   static late Image particles;

   static late Image template_head_plain;
   static late Image template_head_rogue;
   static late Image template_head_steel;
   static late Image template_head_swat;
   static late Image template_head_wizard;

   static late Image template_body_blue;
   static late Image template_body_cyan;
   static late Image template_body_swat;
   static late Image template_body_tunic;

   static late Image template_legs_blue;
   static late Image template_legs_white;
   static late Image template_legs_green;
   static late Image template_legs_brown;
   static late Image template_legs_red;
   static late Image template_legs_swat;

   static late Image template_weapon_bow;
   static late Image template_weapon_shotgun;
   static late Image template_weapon_handgun;
   static late Image template_weapon_staff;
   static late Image template_weapon_sword_steel;
   static late Image template_weapon_sword_wooden;
   static late Image template_weapon_pickaxe;
   static late Image template_weapon_axe;
   static late Image template_weapon_hammer;

   static Image getImageForHeadType(int headType) {
      switch (headType) {
         case HeadType.None:
            return template_head_plain;
         case HeadType.Rogues_Hood:
            return template_head_rogue;
         case HeadType.Steel_Helm:
            return template_head_steel;
         case HeadType.Wizards_Hat:
            return template_head_wizard;
         default:
            throw Exception('GameImages.getImageForHeadType(${HeadType.getName(headType)})');
      }
   }

   static Image getImageForBodyType(int bodyType) {
      switch (bodyType) {
         case BodyType.shirtBlue:
            return template_body_blue;
         case BodyType.shirtCyan:
            return template_body_cyan;
         case BodyType.swat:
            return template_body_swat;
         case BodyType.tunicPadded:
            return template_body_tunic;
         default:
            throw Exception('GameImages.getImageForBodyType(${BodyType.getName(bodyType)})');
      }
   }

   static Image getImageForLegType(int legType) {
      switch (legType){
         case LegType.white:
            return template_legs_white;
         case LegType.blue:
            return template_legs_blue;
         case LegType.green:
            return template_legs_green;
         case LegType.brown:
            return template_legs_brown;
         case LegType.red:
            return template_legs_red;
         case LegType.swat:
            return template_legs_swat;
         default:
            throw Exception('GameImages.getImageForLegType(${LegType.getName(legType)})');
      }
   }

   static Image getImageForWeaponType(int weaponType) {
      switch (weaponType) {
         case AttackType.Shotgun:
            return template_weapon_shotgun;
         case AttackType.Bow:
            return template_weapon_bow;
         case AttackType.Handgun:
            return template_weapon_handgun;
         case AttackType.Staff:
            return template_weapon_staff;
         case AttackType.Blade:
            return template_weapon_sword_steel;
         case AttackType.Pickaxe:
            return template_weapon_pickaxe;
         case AttackType.Axe:
            return template_weapon_axe;
         case AttackType.Hammer:
            return template_weapon_hammer;
         default:
            throw Exception("ImagesTemplateWeapons.fromWeaponType($weaponType)");
      }
   }
}




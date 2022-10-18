
import 'dart:ui';

import 'package:bleed_common/library.dart';

class GameImages {
   static late Image pixel;
   static late Image mapAtlas;
   static late Image blocks;
   static late Image characters;
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
         default:
            throw Exception('GameImages.getImageForLegType(${LegType.getName(legType)})');
      }
   }
}


class ImagesTemplateWeapons {
   static late Image bow;
   static late Image shotgun;
   static late Image handgun;
   static late Image staff;
   static late Image sword_steel;
   static late Image sword_wooden;
   static late Image pickaxe;
   static late Image axe;
   static late Image hammer;

   static Image fromWeaponType(int weaponType) {
      switch (weaponType) {
         case AttackType.Shotgun:
            return shotgun;
         case AttackType.Bow:
            return bow;
         case AttackType.Handgun:
            return handgun;
         case AttackType.Staff:
            return staff;
         case AttackType.Blade:
            return sword_steel;
         case AttackType.Pickaxe:
            return pickaxe;
         case AttackType.Axe:
            return axe;
         case AttackType.Hammer:
            return hammer;
         default:
            throw Exception("ImagesTemplateWeapons.fromWeaponType($weaponType)");
      }
   }
}


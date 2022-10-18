
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
            throw Exception('GameImages.getImageForHeadType(${HeadType.getName(headType)}');
      }
   }

}

class ImagesTemplateBody {
   static late Image blue;
   static late Image cyan;
   static late Image swat;
   static late Image tunic;

   static Image fromBodyType(int bodyType) {
      switch (bodyType){
         case BodyType.shirtBlue:
            return blue;
         case BodyType.shirtCyan:
            return cyan;
         case BodyType.swat:
            return swat;
         case BodyType.tunicPadded:
            return tunic;
         default:
            return cyan;
      }
   }
}

class ImagesTemplateLegs {
   static late Image blue;
   static late Image white;

   static Image fromLegType(int legType){
       switch (legType){
          case LegType.white:
             return white;
          case LegType.blue:
             return blue;
          default:
             return white;
             // throw Exception("atlases.ImagesTemplateLegs.fromLegType(type: $legType");
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


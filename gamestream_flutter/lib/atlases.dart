
import 'dart:ui';

import 'package:bleed_common/library.dart';

class Images {
   static late Image pixel;
   static late Image mapAtlas;
   static late Image blocks;
   static late Image characters;
   static late Image zombie;
   static late Image templateShadow;
   static late Image gameobjects;
   static late Image particles;
}

class ImagesTemplateHead {
   static late Image plain;
   static late Image rogue;
   static late Image steel;
   static late Image swat;
   static late Image wizard;

   Image fromHeadType(int headType){
       switch(headType){
          case HeadType.None:
             return plain;
          case HeadType.Rogues_Hood:
             return rogue;
          case HeadType.Steel_Helm:
             return steel;
          case HeadType.Wizards_Hat:
             return wizard;
          default:
             return plain;
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
}


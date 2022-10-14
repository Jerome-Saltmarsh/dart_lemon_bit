
import 'dart:ui';

import 'package:bleed_common/head_type.dart';

class Images {
   static late Image pixel;
   static late Image mapAtlas;
   static late Image blocks;
   static late Image characters;
   static late Image zombie;
   static late Image templateShadow;
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
}

class ImagesTemplateLegs {
   static late Image blue;
   static late Image white;
}

class ImagesTemplateWeapons {
   static late Image bow;
   static late Image shotgun;
   static late Image handgun;
}


import 'package:bleed_common/src.dart';

class SrcItems {
  static const Health_Potion = <double>[
    5, // x
    2, // y
    22, // width
    26, // height
    1, // scale
    0.5, // anchorY
  ];

  static const Magic_Potion = <double>[
    37, // x
    2, // y
    22, // width
    26, // height
    1, // scale
    0.5, // anchorY
  ];

  static const Meat_Drumstick = <double>[
    67, // x
    3, // y
    25, // width
    26, // height
    1, // scale
    0.5, // anchorY
  ];

  static const collection = <int, List<double>>{
    ItemType.Health_Potion: Health_Potion,
    ItemType.Magic_Potion: Magic_Potion,
    ItemType.Meat_Drumstick: Meat_Drumstick,
  };
}
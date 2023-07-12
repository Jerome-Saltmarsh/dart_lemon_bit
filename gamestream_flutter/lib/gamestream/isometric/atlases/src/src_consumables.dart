import 'package:bleed_common/src.dart';

class SrcConsumables {
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

  static const collection = <int, List<double>>{
    ConsumableType.Health_Potion: Health_Potion,
    ConsumableType.Magic_Potion: Magic_Potion,
  };
}
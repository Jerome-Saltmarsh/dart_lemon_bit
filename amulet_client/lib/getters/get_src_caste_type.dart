

import 'package:amulet_common/src.dart';

List<double> getSrcCasteType(CasteType casteType){
  const x = 768.0;
  const width = 16.0;
  const height = 16.0;
  return switch (casteType){
    CasteType.Ability => const [
        x,
        144,
        width,
        height,
      ],
    CasteType.Passive => const [
        784,
        128,
        width,
        height,
      ],
  };
}
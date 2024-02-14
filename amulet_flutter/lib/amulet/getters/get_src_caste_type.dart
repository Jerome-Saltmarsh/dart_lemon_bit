

import 'package:amulet_engine/common/src.dart';

List<double> getSrcCasteType(CasteType casteType){
  const x = 768.0;
  const width = 16.0;
  const height = 16.0;
  return switch (casteType){
    CasteType.Sword => const [
        x,
        128,
        width,
        height,
      ],
    CasteType.Bow => const [
        x,
        144,
        width,
        height,
      ],
    CasteType.Staff => const [
        x,
        160,
        width,
        height,
      ],
    CasteType.Caste => const [
        x,
        176,
        width,
        height,
      ],
    CasteType.Melee => const [
        x,
        176,
        width,
        height,
      ],
  };
}

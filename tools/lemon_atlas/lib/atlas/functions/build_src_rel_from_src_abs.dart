

import 'dart:typed_data';

Uint16List buildSrcRelFromSrcAbsolute({
  required Uint16List srcAbs,
  required int spriteWidth,
  required int spriteHeight,
}){
  final srcRel = Uint16List(srcAbs.length);
  var i = 0;
  while (i < srcRel.length){
    srcRel[i + 0] = srcAbs[i + 0] % spriteWidth; // left
    srcRel[i + 1] = srcAbs[i + 1] % spriteHeight; // top
    srcRel[i + 2] = srcAbs[i + 2] % spriteWidth; // right
    srcRel[i + 3] = srcAbs[i + 3] % spriteHeight; // bottom
    i += 4;
  }
  return srcRel;
}
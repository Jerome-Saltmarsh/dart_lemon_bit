//
// int bytesWriteInt1(int bytes, int intValue) =>
//     (bytes & 0xFFFFFFFFFFFFFF00) | (intValue & 0xFF);
//
// int bytesWriteInt2(int bytes, int intValue) =>
//     (bytes & 0xFFFFFFFFFFFF00FF) | ((intValue & 0xFF) << 8);
//
// int bytesWriteInt3(int bytes, int intValue) =>
//     (bytes & 0xFFFFFFFFFF00FFFF) | ((intValue & 0xFF) << 16);
//
// int bytesWriteInt4(int bytes, int intValue) =>
//     (bytes & 0xFFFFFFFF00FFFFFF) | ((intValue & 0xFF) << 24);
//
// int bytesWriteInt5(int bytes, int intValue) =>
//     (bytes & 0xFFFFFF00FFFFFFFF) | ((intValue & 0xFF) << 32);
//
// int bytesWriteInt6(int bytes, int intValue) =>
//     (bytes & 0xFFFF00FFFFFFFFFF) | ((intValue & 0xFF) << 40);
//
// int bytesWriteInt7(int bytes, int intValue) =>
//     (bytes & 0xFF00FFFFFFFFFFFF) | ((intValue & 0xFF) << 48);
//
// int bytesWriteInt8(int bytes, int intValue) =>
//     (bytes & 0x00FFFFFFFFFFFFFF) | ((intValue & 0xFF) << 56);
//
//
//
// int writeBit5SignedInt(int value) {
//   if (value < -16) {
//     value = -16;
//   } else if (value > 15) {
//     value = 15;
//   }
//
//   int binaryValue = value & 0x1F;
//
//   return binaryValue;
// }

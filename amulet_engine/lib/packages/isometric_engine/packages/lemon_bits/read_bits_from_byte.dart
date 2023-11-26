//
//
// int readBitsFromByteAsByte(int byte, int index, int length) {
//   if (byte < 0 || byte > 255 || index < 0 || index >= 8 || length <= 0 || length > 8) {
//     throw ArgumentError('Invalid byte value, index, or length.');
//   }
//   return (byte >> index) & ((1 << length) - 1);
// }

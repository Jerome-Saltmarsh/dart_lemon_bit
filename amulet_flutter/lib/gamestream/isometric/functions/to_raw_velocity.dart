import 'sign_to_byte.dart';

int toRawVelocity(int x, int y, int z) =>
    signToByte(x) |
    (signToByte(y) << 2) |
    (signToByte(z) << 4);

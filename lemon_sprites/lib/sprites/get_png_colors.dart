import 'dart:typed_data';

import 'package:image/image.dart';

Uint32List? decodePngColors(Uint8List pngBytes) =>
    decodePngBuffer(pngBytes)?.asUint32List();

ByteBuffer? decodePngBuffer(Uint8List pngBytes) =>
    decodePng(pngBytes)?.data?.buffer;

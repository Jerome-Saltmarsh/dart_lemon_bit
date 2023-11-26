
import 'dart:typed_data';
import 'dart:ui';

Future<Image> buildImageFromBytes(Uint8List bytes) async {
  final codec = await instantiateImageCodec(bytes);
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
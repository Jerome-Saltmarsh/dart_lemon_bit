import 'package:test/test.dart';
import 'package:gamestream_flutter/common.dart';

void main() {

  test('item_type', () {
    final compressed = GameObjectType.compress(GameObjectType.Hand, HandType.Gauntlets);
    expect(GameObjectType.decompressType(compressed), GameObjectType.Hand);
    expect(GameObjectType.decompressSubType(compressed), HandType.Gauntlets);

  });
}
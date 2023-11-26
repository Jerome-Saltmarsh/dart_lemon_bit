import 'package:test/test.dart';
import 'package:amulet_flutter/packages/common.dart';

void main() {

  test('item_type', () {
    final compressed = ItemType.compress(ItemType.Hand, HandType.Gauntlets);
    expect(ItemType.decompressType(compressed), ItemType.Hand);
    expect(ItemType.decompressSubType(compressed), HandType.Gauntlets);
  });
}
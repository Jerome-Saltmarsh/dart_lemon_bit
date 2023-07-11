
import 'dart:typed_data';

class ItemList {
  final int length;
  late final Uint8List types;
  late final Uint8List subTypes;

  ItemList(this.length) {
    types = Uint8List(length);
    subTypes = Uint8List(length);
  }

  void set({required int index, required int type, required int subType}) {
    if (!isValidItemIndex(index))
      throw Exception('invalid index $index');

    types[index] = type;
    subTypes[index] = subType;
  }

  int getEmptyIndex(){
    for (var i = 0; i < length; i++){
      if (types[i] == 0)
        return i;
    }
    return -1;
  }

  bool isValidItemIndex(int index) => index >= 0 && index < length;
}
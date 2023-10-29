
import 'dart:typed_data';

class BoolList {
  late final Uint8List _list;

  BoolList(int length) {
    _list = Uint8List(length);
  }

  void fill(bool value){
    _list.fillRange(0, _list.length, value ? 1 : 0);
  }

  factory BoolList.fromList(List<bool> sourceList) {
    final length = sourceList.length;
    final uint8List = Uint8List(length);
    for (var i = 0; i < length; i++) {
      uint8List[i] = sourceList[i] ? 1 : 0;
    }
    return BoolList.fromUint8List(uint8List);
  }

  factory BoolList.fromUint8List(Uint8List uint8List) {
    return BoolList(uint8List.length).._list = Uint8List.fromList(uint8List);
  }

  bool operator [](int index) {
    if (index < 0 || index >= _list.length) {
      throw RangeError('Index out of range');
    }
    return _list[index] == 1;
  }

  void operator []=(int index, bool value) {
    if (index < 0 || index >= _list.length) {
      throw RangeError('Index out of range');
    }
    _list[index] = value ? 1 : 0;
  }

  int get length => _list.length;

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  List<bool> toList() {
    final boolList = <bool>[];
    for (var i = 0; i < _list.length; i++) {
      boolList.add(_list[i] == 1);
    }
    return boolList;
  }

  Uint8List toUint8List() => Uint8List.fromList(_list);

  @override
  String toString() => toList().toString();
}

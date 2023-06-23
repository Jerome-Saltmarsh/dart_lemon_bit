import 'dart:typed_data';

class Boolean32List {
  final Uint32List _words;
  final int _length;
  static const int _bitsPerWord = 32;

  Boolean32List(int length)
      : _words = Uint32List((length + _bitsPerWord - 1) ~/ _bitsPerWord),
        _length = length;

  bool operator [](int index) {
    if (index < 0 || index >= _length) {
      throw RangeError.range(index, 0, _length - 1);
    }

    final wordIndex = index ~/ _bitsPerWord;
    final bitIndex = index % _bitsPerWord;
    final word = _words[wordIndex];
    return (word & (1 << bitIndex)) != 0;
  }

  void operator []=(int index, bool value) {
    if (index < 0 || index >= _length) {
      throw RangeError.range(index, 0, _length - 1);
    }

    final wordIndex = index ~/ _bitsPerWord;
    final bitIndex = index % _bitsPerWord;
    final word = _words[wordIndex];
    final mask = 1 << bitIndex;
    if (value) {
      _words[wordIndex] = word | mask;
    } else {
      _words[wordIndex] = word & ~mask;
    }
  }
}
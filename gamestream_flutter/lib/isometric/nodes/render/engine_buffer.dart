import 'dart:typed_data';

final buffer50 = Buffer(50);
final buffer100 = Buffer(100);
final buffer200 = Buffer(200);
final buffer300 = Buffer(300);
final buffer400 = Buffer(400);
var buffer = buffer50;

var renderI = 0;

void performRender(){
  /// the goal is to only send a single render command
  /// currently several render commands are being sent per frame
  /// which may be triggering extra paint jobs before its finished
  /// it attempts to recycle the current buffer by simply using the last one
  /// if the index is greater than the size the next size up is retrieved and the values
  /// are copies across
  if (buffer.length >= renderI){
    if (buffer == buffer50){
       buffer = buffer100;
       // copy bytes from buffer 50 to buffer 100
      return;
    }
    if (buffer == buffer100) {

    }
  }
}

class Buffer {
  final int length;
  late final Float32List dst0;
  late final Float32List dst1;
  late final Float32List dst2;
  late final Float32List dst3;
  Buffer(this.length) {
    dst0 = Float32List(length);
    dst1 = Float32List(length);
    dst2 = Float32List(length);
    dst3 = Float32List(length);
  }
}


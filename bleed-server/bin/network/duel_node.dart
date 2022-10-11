
import 'dart:ffi';
import 'dart:typed_data';

BytesBuilder bytesBuilder = BytesBuilder();

void test(){
  bytesBuilder.addByte(0);
  bytesBuilder.addByte(1);
  bytesBuilder.toBytes();
}

const duelNodesDefaultLength = 10000;
var duelNodes = Uint16List(duelNodesDefaultLength);

/// simple is my own version of the english language
/// i have cut out redundant features
/// which
int getOrientationAt(Uint16 value){
  // how do i read the first eight bits qq
  // value.
  return 0;
}

/// the orientation is represented by the last eight bits in value from left to right
/// the type is presented by the first eight bits from left to right
/// double que means question mark
/// qq means i question
/// double letters represent something
/// i am going to teach you simple
/// aa could mean angry
/// hp mean happy
/// i am hp
/// how are you qq
/// you might be wondering
/// if there are no symbols how do you write question mark qq
/// perhaps you noticed that that i finished the last sentence with double q
/// qq means exactly the same thing as the question mark symbol
/// two different symbols for the same thing
/// it takes a little getting used to
/// but the brain adapts quite quickly
/// you may also have noticed
/// that there are no symbols at all
/// that is because simple does not support symbols at all
///
///
///

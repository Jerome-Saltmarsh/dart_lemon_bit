
import 'dart:typed_data';

T parse<T>(dynamic value){
  if (value is T) {
    return value;
  }

  if (T == Float32List) {
    if (value is List){
      final nums = value.cast<num>();
      final doubles = nums.map((num) => num.toDouble()).toList(growable: false);
      final float32List = Float32List.fromList(doubles);
      return float32List as T;
    }
  }

  throw Exception('parse($value)');
}


import '../packages/isometric_engine/packages/lemon_math/src/functions/random_item.dart';

extension ListExtensions<T> on List<T> {

  T? tryGet(int? index) =>
      index == null ||
          index < 0 ||
          index >= length
          ? null
          : this[index];

  T get random => randomItem(this);
}
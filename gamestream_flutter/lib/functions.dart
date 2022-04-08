
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/modules/isometric/enums.dart';

int compareParticles(Particle a, Particle b) {
  if (!a.active) {
    return -1;
  }
  if (!b.active) {
    return 1;
  }
  if (a.type == ParticleType.Blood) return -1;
  if (b.type == ParticleType.Blood) return 1;

  return a.y > b.y ? 1 : -1;
}

void insertionSort<E>(List<E> elements, {required int Function(E, E) compare, int start = 0, int? end}) {
  end ??= elements.length;
  for (var pos = start + 1; pos < end; pos++) {
    var min = start;
    var max = pos;
    var element = elements[pos];
    while (min < max) {
      var mid = min + ((max - min) >> 1);
      var comparison = compare(element, elements[mid]);
      if (comparison < 0) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }
    elements.setRange(min + 1, pos + 1, elements, min);
    elements[min] = element;
  }
}

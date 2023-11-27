//
// import 'dart:typed_data';
//
// import 'package:amulet_flutter/common.dart';
// import 'package:amulet_flutter/gamestream/isometric/isometric.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:test/test.dart';

void main() {

  test('light', () {

    for (var vx = -1; vx <= 1; vx++) {
      for (var vy = -1; vy <= 1; vy++) {
        for (var vz = -1; vz <= 1; vz++) {

          final velocity = RendererNodes.toRawVelocity(vx, vy, vz);

          final vxRaw = velocity & 0x3;
          final vyRaw = (velocity >> 2) & 0x3;
          final vzRaw = (velocity >> 4) & 0x3;

          final xOut = RendererNodes.parseRaw(vxRaw);
          final yOut = RendererNodes.parseRaw(vyRaw);
          final zOut = RendererNodes.parseRaw(vzRaw);

          expect(xOut, vx);
          expect(yOut, vy);
          expect(zOut, vz);
        }
      }
    }


  });
}

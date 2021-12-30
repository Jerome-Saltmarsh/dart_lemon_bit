import 'dart:ui';

import 'package:bleed_client/cube/cube.dart';
import 'package:bleed_client/cube/v3.dart';
import 'package:bleed_client/document/request_pointer_lock.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:lemon_engine/state/paint.dart';

import 'camera3d.dart';

final cubeFrame = ValueNotifier<int>(0);

Widget buildCube3D() {
  cube(position: v3(0, 0, 0));
  cube(position: v3(1, 0, 0));
  cube(position: v3(1, 0, 0));
  cube(position: v3(-10, 0, 1));
  cube(position: v3(-10, 0, -5));
  cube(position: v3(-5, 0, -10));
  cube(position: v3(5, 0, -10));

  return MaterialApp(
    home: Scaffold(
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        // camera3D.viewportWidth = constraints.maxWidth;
        // camera3D.viewportHeight = constraints.maxHeight;
        return Stack(
          children: [
            CustomPaint(
              painter: _CubePainter(cubeFrame),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
            Positioned(
                top: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: axis.cross.end,
                  children: [
                    // Text("viewport.width: ${camera3D.viewportWidth.toInt()}"),
                    // Text("viewport.height: ${camera3D.viewportHeight.toInt()}"),
                    Refresh((){
                      return Text("camera.position: ${camera3D.position}");
                    }),
                    Refresh((){
                      return Text("camera.rotation: ${camera3D.rotation}");
                    }),
                  ],
                )),
            Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  child: GestureDetector(
                      onTap: requestPointerLock, child: Text("Lock Pointer")),
                ))
          ],
        );
      }),
    ),
  );
}

Paint get globalPaint => paint;

class _CubePainter extends CustomPainter {
  const _CubePainter(Listenable repaint) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    // globalPaint.color = Colors.red;
    scene.render(canvas, size);
    // canvas.drawCircle(Offset(100, 100), 100, globalPaint);
  }

  @override
  bool shouldRepaint(_CubePainter oldDelegate) {
    return true;
  }
}


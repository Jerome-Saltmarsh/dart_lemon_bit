import 'dart:async';

import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/engine/functions/convertScreenToWorld.dart';
import 'package:bleed_client/engine/functions/disableRightClick.dart';
import 'package:bleed_client/engine/properties/mouseWorld.dart';
import 'package:bleed_client/engine/state/backgroundColor.dart';
import 'package:bleed_client/engine/state/buildContext.dart';
import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/mouseDragging.dart';
import 'package:bleed_client/engine/state/onMouseScroll.dart';
import 'package:bleed_client/engine/state/primarySwatch.dart';
import 'package:bleed_client/engine/state/screen.dart';
import 'package:bleed_client/engine/state/size.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:bleed_client/engine/typedefs/DrawCanvas.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';

import 'state/paint.dart';

// private global variables
Offset _mousePosition;
Offset _previousMousePosition;
Offset _mouseDelta;
bool _clickProcessed = true;
StateSetter uiSetState;

// global properties
Offset get mousePosition => _mousePosition;

Offset get previousMousePosition => _previousMousePosition;

Offset get mouseVelocity => _mouseDelta;

double get mouseX => _mousePosition?.dx;

double get mouseY => _mousePosition?.dy;

Offset get mouse => Offset(mouseX, mouseY);

Offset get mouseWorld => Offset(mouseWorldX, mouseWorldY);

Vector2 get mouseWorldV2 => Vector2(mouseWorldX, mouseWorldY);

double get screenCenterX => screenWidth * 0.5;

double get screenCenterY => screenHeight * 0.5;

double get screenWidth => globalSize.width;

double get screenHeight => globalSize.height;

double get screenCenterWorldX => convertScreenToWorldX(screenCenterX);

double get screenCenterWorldY => convertScreenToWorldY(screenCenterY);

Offset get screenCenterWorld => Offset(screenCenterWorldX, screenCenterWorldY);

bool get mouseAvailable => mouseX != null;

bool get mouseClicked => !_clickProcessed;

final Paint paint3 = Paint()
  ..color = Colors.white
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 3;

int _millisecondsSinceLastFrame = 0;
DateTime _previousUpdateTime = DateTime.now();

int get millisecondsSinceLastFrame => _millisecondsSinceLastFrame;

StreamController<bool> onRightClickChanged = StreamController.broadcast();

class GameWidget extends StatefulWidget {
  final String title;
  final Function init;
  final Function update;
  final WidgetBuilder buildUI;
  final DrawCanvas drawCanvas;
  final DrawCanvas drawCanvasForeground;

  GameWidget({
      this.title,
      this.init,
      this.update,
      this.buildUI,
      this.drawCanvas,
      this.drawCanvasForeground
  });

  void _internalUpdate() {
    DateTime now = DateTime.now();
    _millisecondsSinceLastFrame =
        now.difference(_previousUpdateTime).inMilliseconds;
    _previousUpdateTime = now;

    screen.left = camera.x;
    screen.right = camera.x + (screenWidth / zoom);
    screen.top = camera.y;
    screen.bottom = camera.y + (screenHeight / zoom);

    update();
    _clickProcessed = true;
  }

  @override
  _GameWidgetState createState() => _GameWidgetState();
}

void redrawCanvas() {
  _frame.value++;
}

void rebuildUI() {
  uiSetState(_doNothing);
}

void _doNothing() {}

final _frame = ValueNotifier<int>(0);
final _foregroundFrame = ValueNotifier<int>(0);
const int framesPerSecond = 60;
const int millisecondsPerSecond = 1000;
const int millisecondsPerFrame = millisecondsPerSecond ~/ framesPerSecond;
const Duration _updateDuration = Duration(milliseconds: millisecondsPerFrame);

bool _rightClickDown = false;

bool get rightClickDown => _rightClickDown;

class _GameWidgetState extends State<GameWidget> {
  Timer _updateTimer;

  void _update(Timer timer) {
    widget._internalUpdate();
  }

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(_updateDuration, _update);
    disableRightClickContextMenu();
    paint.isAntiAlias = false;
    widget.init();
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return MaterialApp(
      title: widget.title,
      theme: ThemeData(
        primarySwatch: primarySwatch,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            globalSize = MediaQuery.of(context).size;
            return Stack(
              children: [
                _buildBody(context),
                _buildUI(),
              ],
            );
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildBody(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      onHover: (PointerHoverEvent pointerHoverEvent) {
        _previousMousePosition = _mousePosition;
        _mousePosition = pointerHoverEvent.position;
        _mouseDelta = pointerHoverEvent.delta;
      },
      child: PositionedTapDetector(
        onLongPress: (position) {
          _previousMousePosition = _mousePosition;
          _mousePosition = position.relative;
        },
        onTap: (position) {
          _clickProcessed = false;
        },
        child: Listener(
          onPointerSignal: (pointerSignalEvent) {
            if (pointerSignalEvent is PointerScrollEvent) {
              onMouseScroll(pointerSignalEvent.scrollDelta.dy);
            }
          },
          child: GestureDetector(
              onSecondaryTapDown: (_) {
                _rightClickDown = true;
                onRightClickChanged.add(true);
              },
              onSecondaryTapUp: (_) {
                onRightClickChanged.add(false);
                _rightClickDown = false;
              },
              onPanStart: (start) {
                mouseDragging = true;
                _previousMousePosition = _mousePosition;
                _mousePosition = start.globalPosition;
              },
              onPanEnd: (value) {
                mouseDragging = false;
              },
              onPanUpdate: (DragUpdateDetails value) {
                _previousMousePosition = _mousePosition;
                _mousePosition = value.globalPosition;
              },
              child: Container(
                  color: backgroundColor,
                  width: globalSize.width,
                  height: globalSize.height,
                  child: CustomPaint(
                      painter: _GamePainter(
                          drawCanvas: widget.drawCanvas, repaint: _frame),
                      foregroundPainter: widget.drawCanvasForeground != null
                          ? _GamePainter(
                              drawCanvas: widget.drawCanvasForeground,
                              repaint: _foregroundFrame)
                          : null))),
        ),
      ),
    );
  }

  Widget _buildUI() {
    return StatefulBuilder(builder: (context, drawUI) {
      uiSetState = drawUI;
      globalContext = context;
      return widget.buildUI(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _updateTimer.cancel();
  }
}

class _GamePainter extends CustomPainter {
  final DrawCanvas drawCanvas;

  const _GamePainter({this.drawCanvas, Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas _canvas, Size _size) {
    globalCanvas = _canvas;
    globalSize = _size;
    _canvas.scale(zoom, zoom);
    _canvas.translate(-camera.x, -camera.y);
    drawCanvas(_canvas, _size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

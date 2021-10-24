import 'dart:async';

import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/engine/state/buildContext.dart';
import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/size.dart';
import 'package:bleed_client/input.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mat;
import 'package:positioned_tap_detector/positioned_tap_detector.dart';

import 'engine_state.dart';
import 'state/paint.dart';
import 'web_functions.dart';

typedef PaintGame = Function(Canvas canvas, Size size);

// private global variables
Offset _mousePosition;
Offset _previousMousePosition;
Offset _mouseDelta;
bool _clickProcessed = true;

// global properties
Offset get mousePosition => _mousePosition;

Offset get previousMousePosition => _previousMousePosition;

Offset get mouseVelocity => _mouseDelta;

double get mouseX => _mousePosition?.dx;

double get mouseY => _mousePosition?.dy;

Offset get mouse => Offset(mouseX, mouseY);

double get mouseWorldX => convertScreenToWorldX(mouseX ?? 0);

double get mouseWorldY => convertScreenToWorldY(mouseY ?? 0);

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
Color white = mat.Colors.white;
Color red = mat.Colors.red;

// finals

final Paint paint2 = Paint()
  ..color = white
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 2;

final Paint paint3 = Paint()
  ..color = white
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 3;

int _millisecondsSinceLastFrame = 0;

int get millisecondsSinceLastFrame => _millisecondsSinceLastFrame;

abstract class GameWidget extends StatefulWidget {
  final String title;
  Size screenSize;
  DateTime previousUpdateTime = DateTime.now();
  Duration frameDuration = Duration();

  int targetFPS() => 45;

  Future init();

  void _internalUpdate() {
    DateTime now = DateTime.now();
    _millisecondsSinceLastFrame =
        now.difference(previousUpdateTime).inMilliseconds;
    previousUpdateTime = now;
    fixedUpdate();
    _clickProcessed = true;
  }

  /// used to update the game logic
  void fixedUpdate();

  /// used to draw the game
  void draw(Canvas canvas, Size size);

  void drawForeground(Canvas canvas, Size size);

  void onMouseClick() {}

  void onMouseScroll(double amount) {}

  /// used to build the ui
  Widget buildUI(BuildContext context);

  bool uiVisible() => false;

  mat.Color getBackgroundColor() => mat.Colors.black;

  GameWidget({this.title = 'BLEED'});

  @override
  _GameWidgetState createState() => _GameWidgetState();
}

StateSetter uiSetState;

void redrawCanvas() {
  _frame.value++;
}

void rebuildUI() {
  uiSetState(_doNothing);
}

void _doNothing() {}

final _frame = ValueNotifier<int>(0);
final _foregroundFrame = ValueNotifier<int>(0);

class _GameWidgetState extends State<GameWidget> {
  // variables
  Timer updateTimer;

  void _update(Timer timer) {
    widget._internalUpdate();
  }

  @override
  void initState() {
    updateTimer = Timer.periodic(
        Duration(milliseconds: 1000 ~/ widget.targetFPS()), _update);
    widget.init();
    disableRightClick();
    paint.isAntiAlias = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return MaterialApp(
      title: widget.title,
      theme: ThemeData(
        primarySwatch: mat.Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            widget.screenSize = MediaQuery.of(context).size;
            return Stack(
              children: [
                buildBody(context),
                if (widget.uiVisible()) _buildUI(),
              ],
            );
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildUI() {
    return StatefulBuilder(builder: (context, drawUI) {
      uiSetState = drawUI;
      return widget.buildUI(context);
    });
  }

  Widget buildBody(BuildContext context) {
    return MouseRegion(
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
          widget.onMouseClick();
        },
        child: Listener(
          onPointerSignal: (pointerSignalEvent) {
            if (pointerSignalEvent is PointerScrollEvent) {
              widget.onMouseScroll(pointerSignalEvent.scrollDelta.dy);
            }
          },
          child: GestureDetector(
              onSecondaryTapDown: (_) {
                // @on right click down
                inputRequest.sprint = true;
              },
              onSecondaryTapUp: (_) {
                // @on right click up
                inputRequest.sprint = false;
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
                dragUpdateDetails = value;
                _previousMousePosition = _mousePosition;
                _mousePosition = value.globalPosition;
              },
              child: Container(
                color: widget.getBackgroundColor(),
                width: widget.screenSize.width,
                height: widget.screenSize.height,
                child: CustomPaint(
                    painter:
                        GamePainter(paintGame: widget.draw, repaint: _frame),
                    foregroundPainter: GamePainter(
                        paintGame: widget.drawForeground,
                        repaint: _foregroundFrame)),
              )),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    updateTimer.cancel();
  }
}

class GamePainter extends CustomPainter {
  final PaintGame paintGame;

  const GamePainter({this.paintGame, Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas _canvas, Size _size) {
    globalCanvas = _canvas;
    globalSize = _size;
    paintGame(_canvas, _size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CustomCustomPainter extends CustomPainter {
  final PaintGame paintGame;

  CustomCustomPainter(this.paintGame);

  @override
  void paint(Canvas canvas, Size size) {
    paintGame(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


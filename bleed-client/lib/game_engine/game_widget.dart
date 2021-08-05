import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_game_engine/game_engine/web_functions.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';

import 'engine_state.dart';


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
double get mousePosX => _mousePosition?.dx;
double get mousePosY => _mousePosition?.dy;
bool get mouseAvailable => mousePosX != null;
bool get mouseClicked => !_clickProcessed;
Color white = mat.Colors.white;
Color red = mat.Colors.red;

// finals
final Paint globalPaint = Paint()
  ..color = white
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 1;

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

  int targetFPS() => 60;

  Future init();

  void _internalUpdate(){
    DateTime now = DateTime.now();
    _millisecondsSinceLastFrame = now.difference(previousUpdateTime).inMilliseconds;
    previousUpdateTime = now;
    fixedUpdate();
    _clickProcessed = true;
  }

  /// used to update the game logic
  void fixedUpdate();
  /// used to draw the game
  void draw(Canvas canvas, Size size);

  void onMouseClick(){

  }

  /// used to build the ui
  Widget buildUI(BuildContext context);

  bool uiVisible() => false;
  mat.Color getBackgroundColor() => mat.Colors.black;

  GameWidget({this.title = 'BLEED'});

  @override
  _GameWidgetState createState() => _GameWidgetState();
}

void forceRedraw(){
  drawStream.add(true);
}

StreamController drawStream = StreamController();
StateSetter gameSetState;
StateSetter uiSetState;

void redrawGame(){
  gameSetState(_doNothing);
}

void redrawUI(){
  uiSetState(_doNothing);
}

void _doNothing(){

}

class _GameWidgetState extends State<GameWidget> {

  // variables
  FocusNode keyboardFocusNode;
  Timer updateTimer;

  @override
  void initState() {
    drawStream.stream.listen((event) {
      redrawGame();
      redrawUI();
    });
    updateTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ widget.targetFPS()), (timer) {
      widget._internalUpdate();
    });
    keyboardFocusNode = FocusNode();
    widget.init();
    disableRightClick();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (!keyboardFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(keyboardFocusNode);
    }
    return MaterialApp(
      title: widget.title,
      theme: ThemeData(
        primarySwatch: mat.Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RawKeyboardListener(
        focusNode: keyboardFocusNode,
        onKey: (key) {
          // game.handleKeyPressed(key);
        },
        child: Scaffold(
          // appBar: game.buildAppBar(context),
          body: Builder(
            builder: (context){
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
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildUI(){
    return StatefulBuilder(
        builder: (context, drawUI){
          uiSetState = drawUI;
          return widget.buildUI(context);
        });
  }

  Widget buildBody(BuildContext context) {
    return MouseRegion(
      onHover: (PointerHoverEvent pointerHoverEvent){
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
              // game.handleMouseScroll(pointerSignalEvent.scrollDelta.dy);
            }
          },
          child: StatefulBuilder(
            builder: (context, _drawGame){
              gameSetState = _drawGame;
              return Container(
                color: widget.getBackgroundColor(),
                width: widget.screenSize.width,
                height: widget.screenSize.height,
                child: CustomPaint(
                  size: widget.screenSize,
                  painter: GameUIPainter(paintGame: widget.draw),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    updateTimer.cancel();
    keyboardFocusNode.dispose();
  }
}

class GameUIPainter extends CustomPainter {

  final PaintGame paintGame;

  GameUIPainter({this.paintGame});

  @override
  void paint(Canvas canvass, Size size) {
    globalCanvas = canvass;
    paintGame(canvass, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

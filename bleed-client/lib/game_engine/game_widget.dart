import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_game_engine/game_engine/web_functions.dart';
import 'dart:ui' as ui;
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'game_functions.dart';


typedef PaintGame = Function(Canvas canvas, Size size);
Canvas globalCanvas;

// private global variables
Offset _mousePosition;
Offset _previousMousePosition;
Offset _mouseDelta;
DateTime _lastLeftClicked;

double cameraX = 0;
double cameraY = 0;

// global properties
Offset get mousePosition => _mousePosition;
Offset get previousMousePosition => _previousMousePosition;
Offset get mouseVelocity => _mouseDelta;
double get mousePosX => _mousePosition?.dx;
double get mousePosY => _mousePosition?.dy;
bool get mouseAvailable => mousePosX != null;
bool get mouseClicked => _lastLeftClicked != null && millisecondsSince(_lastLeftClicked) < 500;
Color white = mat.Colors.white;
Color red = mat.Colors.red;

// finals
final Paint globalPaint = Paint()
  ..color = white
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 1;

void drawImage(ui.Image image, double x, double y, {double rotation = 0, double anchorX = 0.5, double anchorY = 0.5, double scale = 1.0}){
  globalCanvas.drawAtlas(
      image,
      <RSTransform>[
        RSTransform.fromComponents(
          rotation: rotation,
          scale: scale,
          anchorX: image.width * anchorX,
          anchorY: image.height * anchorY,
          translateX: x - cameraX,
          translateY: y - cameraY,
        )
      ],
      [
        Rect.fromLTWH(
            0, 0, image.width as double, image.height as double)
      ],
      null,
      BlendMode.color,
      null,
      globalPaint);
}


void drawCircle(double x, double y, double radius, Color color){
  globalPaint.color = color;
  globalCanvas.drawCircle(Offset(x - cameraX, y - cameraY), radius, globalPaint);
}

void drawSprite(ui.Image image, int frames, int frame, double x, double y, {double scale = 1.0}){
  double frameWidth = image.width / frames;
  double frameHeight = image.height as double;
  globalCanvas.drawImageRect(image, Rect.fromLTWH(frame * frameWidth, 0, frameWidth, frameHeight),
      Rect.fromCenter(center: Offset(x - cameraX, y - cameraY), width: frameWidth * scale, height: frameHeight * scale), globalPaint);
}

void drawText(String text, double x, double y, Color color){
  TextSpan span = new TextSpan(style: new TextStyle(color: color), text: text);
  TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
  tp.layout();
  tp.paint(globalCanvas, new Offset(x - cameraX, y - cameraY));
}

abstract class GameWidget extends StatefulWidget {

  final int fps;
  final String title;

  Future init();

  /// used to update the game logic
  void fixedUpdate();
  /// used to draw the game
  void draw(Canvas canvas, Size size);

  void onMouseClick(){

  }

  /// used to build the ui
  Widget buildUI(BuildContext context) {
    return Text("ui", style: TextStyle(color: Colors.red),);
  }

  bool uiVisible() => false;
  mat.Color getBackgroundColor() => mat.Colors.black;

  GameWidget({this.fps = 60, this.title = 'BLEED'});

  @override
  _GameWidgetState createState() => _GameWidgetState();

  void forceRedraw(){
    drawStream.add(true);
  }
}

StreamController drawStream = StreamController();

class _GameWidgetState extends State<GameWidget> {

  // variables
  Size screenSize;
  FocusNode keyboardFocusNode;
  Timer updateTimer;

  @override
  void initState() {
    drawStream.stream.listen((event) {
      setState(_doNothing);
    });
    updateTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ widget.fps), (timer) {
      widget.fixedUpdate();
      setState(_doNothing);
    });
    keyboardFocusNode = FocusNode();
    widget.init();
    disableRightClick();
    super.initState();
  }

  void _doNothing(){

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
              screenSize = MediaQuery.of(context).size;
              return Stack(
                children: [
                  buildBody(context),
                  if (widget.uiVisible()) widget.buildUI(context),
                ],
              );
            },
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
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
          _lastLeftClicked = DateTime.now();
          widget.onMouseClick();
        },
        child: Listener(
          onPointerSignal: (pointerSignalEvent) {
            if (pointerSignalEvent is PointerScrollEvent) {
              // game.handleMouseScroll(pointerSignalEvent.scrollDelta.dy);
            }
          },
          child: Container(
            color: widget.getBackgroundColor(),
            width: screenSize.width,
            height: screenSize.height,
            child: CustomPaint(
              size: screenSize,
              painter: GameUIPainter(paintGame: widget.draw),
            ),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'canvas.dart';
import 'enums.dart';
import 'state/paint.dart';

void _defaultDrawCanvasForeground(Canvas canvas, Size size) {
  // do nothing
}

class Game extends StatefulWidget {
  final String title;
  final Map<String, WidgetBuilder>? routes;
  final Function init;
  final WidgetBuilder? buildLoadingScreen;
  final WidgetBuilder buildUI;
  final DrawCanvas drawCanvasForeground;
  final int framesPerSecond;



  Game({
      required this.title,
      required this.init,
      required Function update,
      required this.buildUI,
      this.buildLoadingScreen,
      this.routes,
      this.drawCanvasForeground = _defaultDrawCanvasForeground,
      DrawCanvas? drawCanvas,
      Color backgroundColor = Colors.black,
      bool drawCanvasAfterUpdate = true,
      this.framesPerSecond = 60,
      ThemeData? themeData,
  }){
    engine.backgroundColor.value = backgroundColor;
    engine.drawCanvasAfterUpdate = drawCanvasAfterUpdate;
    engine.themeData.value = themeData;
    engine.onDrawCanvas = drawCanvas;
    engine.update = update;
  }

  @override
  _GameState createState() => _GameState();
}





class _GameState extends State<Game> {
  @override
  void initState() {
    super.initState();
    print("lemon_engine.init()");
    _internalInit();
  }

  Future _internalInit() async {
    engine.disableRightClickContextMenu();
    paint.isAntiAlias = false;
    await widget.init();
    engine.initialized.value = true;
  }

  @override
  Widget build(BuildContext context) {
    engine.buildContext = context;

    return WatchBuilder(engine.themeData, (ThemeData? themeData){
      return MaterialApp(
        title: widget.title,
        routes: widget.routes ?? {},
        theme: themeData,
        home: Scaffold(
          body: WatchBuilder(engine.initialized, (bool? value) {
            if (value != true) {
              WidgetBuilder? buildLoadingScreen = widget.buildLoadingScreen;
              if (buildLoadingScreen != null){
                return buildLoadingScreen(context);
              }
              return Text("Loading");
            }
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                engine.internalSetScreenSize(constraints.maxWidth, constraints.maxHeight);

                engine.screen.width = constraints.maxWidth;
                engine.screen.height = constraints.maxHeight;
                return Stack(
                  children: [
                    buildCanvas(context),
                    widget.buildUI(context),
                  ],
                );
              },
            );
          }),
        ),
        debugShowCheckedModeBanner: false,
      );
    });
  }

  Widget buildCanvas(BuildContext context) {
    final child = Listener(
      onPointerSignal: engine.onPointerSignal,
      onPointerDown: engine.onPointerDown,
      onPointerUp: engine.onPointerUp,
      onPointerHover:engine.onPointerHover,
      onPointerMove: engine.onPointerMove,
      child: GestureDetector(
          onTapDown: engine.onTapDown,
          onLongPress: engine.onLongPress,
          onPanStart: engine.internalOnPanStart,
          onPanUpdate: engine.onPanUpdate,
          onPanEnd: engine.internalOnPanEnd,
          child: WatchBuilder(engine.backgroundColor, (Color backgroundColor){
            return Container(
                color: backgroundColor,
                width: engine.screen.width,
                height: engine.screen.height,
                child: CustomPaint(
                    painter: _GamePainter(repaint: engine.notifierPaintFrame),
                    foregroundPainter: _GameForegroundPainter(
                        repaint: engine.notifierPaintForeground
                    ),
                )
            );
          })),
    );

    return WatchBuilder(engine.cursorType, (CursorType cursorType) =>
      MouseRegion(
        cursor: mapCursorTypeToSystemMouseCursor(cursorType),
        child: child,
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    engine.onDispose?.call();
  }
}

class _GamePainter extends CustomPainter {

  const _GamePainter({required Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas _canvas, Size size) {
    engine.internalPaint(_canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _GameForegroundPainter extends CustomPainter {

  const _GameForegroundPainter({required Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas _canvas, Size _size) {
    engine.onDrawForeground?.call(canvas, _size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


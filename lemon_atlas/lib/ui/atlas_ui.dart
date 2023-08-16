import 'package:flutter/material.dart';
import 'package:lemon_atlas/atlas/atlas.dart';
import 'package:lemon_widgets/lemon_widgets.dart';


class AtlasUI extends StatelessWidget {

  final Atlas atlas;

  const AtlasUI({super.key, required this.atlas});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Lemon Atlas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('LEMON ATLAS'),
          actions: [
            onPressed(
              action: atlas.addFile,
              child: buildText('ADD', color: Colors.black87),
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
            ],
          ),
        ),
      ),
    );
}


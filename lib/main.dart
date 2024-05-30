import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:mini_game_via_flame/flame_layer/flame_layer.dart';
import 'package:mini_game_via_flame/flutter_layer/flutter_layer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.setLandscape();
  Flame.device.fullScreen();
  runApp(const MiniGameApp());
}

class MiniGameApp extends StatelessWidget {
  const MiniGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.blue, fontSize: 20))),
      debugShowCheckedModeBanner: true,
      home: const Scaffold(
        body: Stack(
          children: [
            FlameLayer(),
            FlutterLayer()
          ],
        ),
      ),
    );
  }
}

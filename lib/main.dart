import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
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
      theme: ThemeData(
          textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white, fontSize: 40, fontFamily: 'vinque')),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 30, fontFamily: 'vinque'),
              )),
              iconButtonTheme: IconButtonThemeData(
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                iconSize: 24, 
              )),
              ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider<MiniGameBloc>(
        create: (context) => MiniGameBloc(),
        child: const Scaffold(
          body: Stack(
            children: [FlameLayer(), FlutterLayer()],
          ),
        ),
      ),
    );
  }
}

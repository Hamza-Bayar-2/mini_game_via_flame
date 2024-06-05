import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
import 'package:mini_game_via_flame/flutter_layer/game_page.dart';
import 'package:mini_game_via_flame/flutter_layer/page_manager.dart';

class FlutterLayer extends StatelessWidget {
  const FlutterLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return const PageManager();
    return const PageManager();
  }
}

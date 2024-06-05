import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniGameBloc, MiniGameState>(
      builder: (context, state) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            width: 450,
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'The Hunter',
                  style: TextStyle(
                    fontSize: 40.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text(
                    "Press SPACE to start",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                ),
                const SizedBox(height: 10,),
                TextButton(
                  onPressed: () {
                    context.read<MiniGameBloc>().add(ChangeDifficultyLevelEvent());
                  }, 
                  child: Text("Change difficulty : ${state.difficultyLevel}")
                ),
                const SizedBox(height: 10,),
                TextButton(
                  onPressed: () {
                    context.read<MiniGameBloc>().add(ChangeGameMode());
                  }, 
                  child: Text("Game Mode : ${state.gameMode == 0 ? "Finite Mode" : "Kill Mode"}")
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

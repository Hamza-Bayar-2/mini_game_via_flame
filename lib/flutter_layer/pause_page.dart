import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';

class PausePage extends StatelessWidget {
  const PausePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniGameBloc, MiniGameState>(
      builder: (context, state) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: const Color.fromRGBO(158, 158, 158, 1), borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Game Paused',
                  style: TextStyle(
                    fontSize: 32.0,
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
                    "Press SPACE to resume",
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
                  child: Text("Change Difficulty : ${state.difficultyLevel}")
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

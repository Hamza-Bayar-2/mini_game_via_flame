import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';

class FlutterLayer extends StatelessWidget {
  const FlutterLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniGameBloc, MiniGameState>(
      builder: (context, state) {
        return Column(
          children: [
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Heltheer: ${state.archerHelth}"),
                Text("Kill amount: ${state.monsterKillNumber}"),
                TextButton(
                  onPressed: () {
                    context.read<MiniGameBloc>().add(ChangeDifficultyLevelEvent());
                  }, 
                  child: Text("Change Difficulty : ${state.difficultyLevel}")
                ),
                TextButton(
                  onPressed: () {
                    if(state.isArcherDead){
                      context.read<MiniGameBloc>().add(ResetHealthEvent());
                    }
                  }, 
                  child: const Text("Revive")
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

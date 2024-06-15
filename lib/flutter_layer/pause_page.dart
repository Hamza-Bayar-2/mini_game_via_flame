import 'dart:ui';

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
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Game Paused',
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'difficulty',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<MiniGameBloc>().add(ChangeDifficultyLevelEvent());
                        },
                        child: Text(
                          _difficultyText(state.difficultyLevel),
                          style: const TextStyle(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 42
                      ),
                      children: <TextSpan> [
                        TextSpan(
                          text: "press"
                        ),
                        TextSpan(
                          text: " space ",
                          style: TextStyle(
                            color: Colors.orange,
                          )
                        ),
                        TextSpan(
                          text: "to start"
                        ),
                      ]
                    ),
                  ),
                  const SizedBox(height: 10,),
                  IconButton(
                    onPressed: () {
                      context.read<MiniGameBloc>().add(ResetAllGameEvent());
                    }, 
                    icon: const Icon(
                      Icons.exit_to_app_outlined,
                      color: Colors.red,
                      size: 35,
                    )
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  String _difficultyText(int difficultyLevel) {
    switch (difficultyLevel) {
      case 1:
        return "easy";
      case 2:
        return "normal";
      case 3:
        return "hard";
      default:
        return "easy";
    }
  }
}

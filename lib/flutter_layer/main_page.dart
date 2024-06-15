import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniGameBloc, MiniGameState>(
      builder: (context, state) {
        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                        fontSize: 100,
                        color: Colors.orange,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(-10.0, 10.0),
                            blurRadius: 9.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                        children: <TextSpan> [
                          TextSpan(
                            text: 'the\n',
                            style: TextStyle(
                              fontSize: 72
                            )
                          ),
                          TextSpan(
                            text: 'hunter',
                          )
                        ]
                      )
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: 380,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'game mode',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<MiniGameBloc>().add(ChangeGameMode());
                                },
                                child: Text(
                                  state.gameMode == 0 ? "finite" : "kill",
                                  style: const TextStyle(
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                  ],
                ),
              ],
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

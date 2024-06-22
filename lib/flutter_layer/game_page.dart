import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
    Widget build(BuildContext context) {
    return BlocBuilder<MiniGameBloc, MiniGameState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    alignment: AlignmentDirectional.topStart,
                    onPressed: () {
                      context.read<MiniGameBloc>().add(GoToPausePage());
                    }, 
                    icon: const Icon(
                      Icons.pause
                    ),
                    color: Colors.white,
                    iconSize: 30,
                  ),
                ],
              ),
              state.gameMode == 0 ? 
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("health: ${state.archerHealth}"),
                    const SizedBox(height: 20,),
                    Text("kill: ${state.monsterKillNumber} / 40"),
                    const SizedBox(height: 20,),
                    Text("stage: ${state.gameStage} / 4"),
                  ],
                ),
              ) :
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("health: ${state.archerHealth}"),
                    const SizedBox(height: 20,),
                    Text("kill: ${state.monsterKillNumber}"),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

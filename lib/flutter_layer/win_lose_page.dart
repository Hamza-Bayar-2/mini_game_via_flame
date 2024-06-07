import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';

class WinLosePage extends StatelessWidget {
  const WinLosePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniGameBloc, MiniGameState>(
      builder: (context, state) {
        return _winLose(state.isArcherDead, context, state);
      },
    );
  }
  
  Widget _winLose(bool isArcherDead, BuildContext context, MiniGameState state) {
    return isArcherDead ? Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
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
              child: TextButton(
                onPressed: () {
                  context.read<MiniGameBloc>().add(GoToMainPage());
                  context.read<MiniGameBloc>().add(ResetHealthEvent());
                }, 
                child: const Text(
                  "Go to menu"
                )
              )
            )
          ],
        ),
      ),
    ) :
    Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: Colors.green, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You Win!',
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
              child: TextButton(
                onPressed: () {
                  context.read<MiniGameBloc>().add(GoToMainPage());
                  context.read<MiniGameBloc>().add(ResetHealthEvent());
                }, 
                child: const Text(
                  "Go to menu"
                )
              )
            ),
          ],
        ),
      ),
    );
  }
}

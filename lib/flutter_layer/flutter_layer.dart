import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_game_via_flame/blocs/taping_down/taping_down_bloc.dart';

class FlutterLayer extends StatelessWidget {
  const FlutterLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TapingDownBloc, TapingDownState>(
      builder: (context, state) {
        return Column(
          children: [
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Helth: ${state.archerHelth}"),
                TextButton(
                  onPressed: () {
                    context.read<TapingDownBloc>().add(DecreaseHealthEvent());
                  }, 
                  child: Text("hit")
                ),
                TextButton(
                  onPressed: () {
                    context.read<TapingDownBloc>().add(ResetHealthEvent());
                  }, 
                  child: Text("reset health")
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_game_via_flame/blocs/taping_down/taping_down_bloc.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';

class FlameLayer extends StatelessWidget {
  const FlameLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: MiniGame(tapingDownBloc: context.read<TapingDownBloc>()));
  }
}

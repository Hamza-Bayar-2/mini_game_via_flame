import 'package:flutter/cupertino.dart';

class FlutterLayer extends StatelessWidget {
  const FlutterLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Helth: 80"),
      ],
    );
  }
}
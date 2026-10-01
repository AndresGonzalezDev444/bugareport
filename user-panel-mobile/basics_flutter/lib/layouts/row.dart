import 'package:flutter/material.dart';

class RowExample extends StatelessWidget {
  const RowExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: SizedBox(
        // height: double.infinity,
        child: const Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Ejemplo1"),
            Expanded(child: Text("Ejemplo2")),
            Text("Ejemplo3"),
          ],
        ),
      ),
    );
  }
}
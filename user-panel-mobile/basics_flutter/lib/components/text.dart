import 'package:flutter/material.dart';

class TextExample extends StatelessWidget {
  const TextExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Spacer(),
        Text(
          "Texto Basico",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        Text("Texto Basico", style: TextStyle(fontSize: 24)),
        Text("Texto con curva", style: TextStyle(fontStyle: FontStyle.italic)),
        Text("Texto con curva", style: TextStyle(color: Colors.red)),
        Text(
          "Decorator",
          style: TextStyle(decoration: TextDecoration.underline, fontSize: 30),
        ),
        Text(
          "Espaciado entre letras aasdasdasd",
          style: TextStyle(letterSpacing: 5, fontSize: 30),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Spacer(),
      ],
    );
  }
}

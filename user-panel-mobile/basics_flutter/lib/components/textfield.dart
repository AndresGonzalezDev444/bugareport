import 'package:flutter/material.dart';

class TextFieldExample extends StatelessWidget {
  const TextFieldExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 60),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            maxLength: 20,
            decoration: InputDecoration(
              hintText: "Usuario",
              prefixIcon: Icon(Icons.face),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Contraseña",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Repetir Contraseña",
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

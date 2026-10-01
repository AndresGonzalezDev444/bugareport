import 'package:flutter/material.dart';

class ColumnExample extends StatelessWidget {
  const ColumnExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.yellow,
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Hello World'),
        Text('Hello World'),
        Text('Hello World'),
        Text('Hello World'),
        Text('Hello World'),
        Text('Hello World'),
      ],
    ),
    );
  }
}

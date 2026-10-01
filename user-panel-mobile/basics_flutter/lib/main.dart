// import 'package:basics_flutter/components/text.dart';
// import 'package:basics_flutter/components/buttons.dart';
import 'package:basics_flutter/components/image.dart';
// import 'package:basics_flutter/components/textfield.dart';
// import 'package:basics_flutter/layouts/column.dart';
// import 'package:basics_flutter/layouts/row.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Mi super App")),
        backgroundColor: Colors.black,
        body: ImageExample(),
    ),
    );
  }
}

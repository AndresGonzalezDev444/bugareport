import 'package:flutter/material.dart';

class ImageExample extends StatelessWidget {
  const ImageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network("https://www.fundacionunivalleyumbo.com/images/logo2.webp"),
        Image.asset("assets/images/alerta.png", height: 100),
      ],
    );
  }
}
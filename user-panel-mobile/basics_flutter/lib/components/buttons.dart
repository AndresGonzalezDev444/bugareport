import 'package:flutter/material.dart';

class ButtonExample extends StatelessWidget {
  const ButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        ElevatedButton(
          onPressed: () {
            print("Pulsao pa");
          },
          child: Text("Soy un botón"),
          onLongPress: (){
            print("PULSAOOOO papito");
          },
          style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
        ),
        OutlinedButton(onPressed: null, child: Text("Segundo botón")),
        TextButton(onPressed: null, child: Text("Text Button")),
        FloatingActionButton(onPressed: (){}, child: Icon(Icons.add)),
        IconButton(onPressed: (){}, icon: Icon(Icons.favorite)),
        Spacer(),
      ],
    );
  }
}

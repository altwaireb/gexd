import 'package:flutter/material.dart';

// Widget class for {{name.pascalCase()}}
class {{name.pascalCase()}}Widget extends StatelessWidget {
  const {{name.pascalCase()}}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text('{{name.titleCase()}} Widget'),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_bar.dart';
import '../main.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key, required this.showModel});
  final Function showModel;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: homeAppBar(appState, context, showModel),
      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      body: const Center(
        child: Text(
          'Create Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

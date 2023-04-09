import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_bar.dart';
import '../main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.showModel});
  final Function showModel;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var mainPage = Scaffold(
      appBar: homeAppBar(appState, context, showModel),
      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      body: const Center(
        child: Text(
          'Home Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    return Navigator(
      key: GlobalKey(),
      initialRoute: '/',
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => mainPage,
        );
      },
    );
  }
}

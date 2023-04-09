import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'animations.dart';
import 'main.dart';
import 'pages.dart';

AppBar homeAppBar(AppState appState, BuildContext context, Function showModel) {
  return AppBar(
    backgroundColor: const Color.fromARGB(255, 15, 15, 15),
    shadowColor: Colors.transparent,
    title: RichText(
      text: TextSpan(
        style: const TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: Colors.red,
          fontSize: 30,
        ),
        text: appState.musicUI ? 'YT Music' : 'YouTube',
        recognizer: TapGestureRecognizer()
          ..onTap = () => appState.setMusicUI(!appState.musicUI),
      ),
    ),
    actions: [
      IconButton(
        tooltip: 'Cast',
        icon: const Icon(
          Icons.cast,
        ),
        splashColor: Colors.transparent,
        splashRadius: 20,
        onPressed: () {
          showModel(CastModelContent());
        },
      ),
      IconButton(
        tooltip: 'Notifications',
        icon: const Icon(
          Icons.notifications_outlined,
        ),
        splashColor: Colors.transparent,
        splashRadius: 20,
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  NotificationPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end);
                final offsetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
      ),
      IconButton(
        tooltip: 'Search',
        icon: const Icon(
          Icons.search,
        ),
        splashColor: Colors.transparent,
        splashRadius: 20,
        onPressed: () {
          Navigator.push(
            context,
            FadeRoute(
              page: SearchPage(Provider.of<AppState>(context, listen: false)),
            ),
          );
        },
      ),
      IconButton(
        tooltip: 'Account',
        icon: const Icon(
          Icons.account_circle,
        ),
        splashColor: Colors.transparent,
        splashRadius: 20,
        onPressed: () {
          Navigator.push(
            context,
            SlideUpRoute(page: AccountPage()),
          );
        },
      ),
    ],
  );
}

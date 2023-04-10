// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Clipboard.setData(const ClipboardData(text: 'abcdefg'));
    //launchUrl(Uri.https('www.google.com', '/device'));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        shadowColor: Colors.transparent,
        title: const Text('Sign In'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          splashRadius: 20,
          splashColor: Colors.transparent,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: OutlinedButton(
                      onPressed: () {
                        print('button 1 pressed');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white10),
                      ),
                      child: const Text(
                        'Sign In',
                        textScaleFactor: 1.25,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

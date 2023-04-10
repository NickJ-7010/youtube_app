// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import '../pages.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Clipboard.setData(const ClipboardData(text: 'abcdefg'));
    //launchUrl(Uri.https('www.google.com', '/device'));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        shadowColor: Colors.transparent,
        title: const Text('Account'),
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
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Account And Some Settings Are Unavailable',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                'You need to sign in before you can manage your account and some settings.\n',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const Text(
                'To sign in click the button below labeled "Sign In" and paste in the code that is automatically copied to your clipboard',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const Text(
                'then choose the account you want to sign in with and allow the app to use your google account!',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 100,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInPage()));
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

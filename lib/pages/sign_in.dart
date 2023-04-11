// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInPage extends StatefulWidget {
  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  String code = '';

  Future<void> generateCode(context) async {
    var tvReq = await http
        .get(Uri.parse('https://www.youtube.com/tv'), headers: <String, String>{
      'accept': '*/*',
      'origin': 'https://www.youtube.com',
      'user-agent': 'Mozilla/5.0 (ChromiumStylePlatform) Cobalt/Version',
      'content-type': 'application/json',
      'referer': 'https://www.youtube.com/tv',
      'accept-language': 'en-US'
    });
    String? tvRes =
        RegExp(r'<script id="base-js" src="(.*?)" nonce=".*?"><\/script>')
            .firstMatch(tvReq.body)
            ?.group(1);
    if (tvRes!.isNotEmpty) {
      var clientReq =
          await http.get(Uri.parse('https://www.youtube.com$tvRes'));
      Iterable<Match> regex =
          RegExp(r'.+?={};var .+?={clientId:"(.+?)",.+?:"(.+?)"},')
              .allMatches(clientReq.body.replaceAll(RegExp(r"\n"), ""));
      var clientId = regex.first.group(1);
      var clientSecret = regex.first.group(2);
      var response = await http.post(
        Uri.parse('https://www.youtube.com/o/oauth2/device/code'),
        headers: {'Content-Type': 'application/json'},
        body:
            '{ "client_id": "$clientId", "scope": "http://gdata.youtube.com https://www.googleapis.com/auth/youtube-paid-content", "device_id": "${const Uuid().v4()}", "model_name": "ytlr::" }',
      );
      var res = jsonDecode(response.body);
      Timer.periodic(Duration(seconds: res['interval']), (interval) async {
        var request = await http.post(
          Uri.parse('https://www.youtube.com/o/oauth2/token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'client_id': clientId,
            'client_secret': clientSecret,
            'code': res['user_code'],
            'grant_type': 'http://oauth.net/grant_type/device/1.0'
          }),
        );
        print(jsonDecode(request.body));
      });
      setState(() {
        code = res["user_code"];
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Code Generated!'),
        ));
      });
    } else {
      print(
          'Error: The tvRes has failed to match the regex most likely due to a bad response');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'To sign in you need to generate a code and copy it then click "Sign In"',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const Text(
                'then paste in the code and allow access to your account.\n',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const Text(
                'If you don\'t want to do that you can just click "Sign In"',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const Text(
                'a code will be automatically generated and copied to your clipboard!',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            height: 40,
                            width: 160,
                            child: OutlinedButton(
                              onPressed: () {
                                generateCode(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white10),
                              ),
                              child: const Text(
                                'Generate Code',
                                textScaleFactor: 1.25,
                              ),
                            ),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Code: ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              TextSpan(
                                text: code.isEmpty ? 'None' : code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 60),
                            child: SizedBox(
                              height: 40,
                              width: 120,
                              child: OutlinedButton(
                                onPressed: () {
                                  if (code.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: const Text(
                                          'You Do Not Have A Code Yet!'),
                                      action: SnackBarAction(
                                        label: 'Generate Code',
                                        onPressed: () {
                                          generateCode(context);
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                        },
                                      ),
                                    ));
                                  } else {
                                    Clipboard.setData(
                                      ClipboardData(text: code),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white10),
                                ),
                                child: const Text(
                                  'Copy Code',
                                  textScaleFactor: 1.25,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: OutlinedButton(
                              onPressed: () async {
                                if (code.isEmpty) {
                                  await generateCode(context);
                                  Clipboard.setData(ClipboardData(text: code));
                                }
                                launchUrl(
                                  Uri.https('www.google.com', '/device'),
                                );
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
            ],
          ),
        ),
      ),
    );
  }
}

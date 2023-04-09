// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'pages.dart';

WebSocketChannel ws =
    WebSocketChannel.connect(Uri.parse('ws://mc-server:5277'));
Function wsCallback = () {};

void main() {
  ws.stream.listen((message) {
    wsCallback(jsonDecode(message));
  });

  runApp(const MyApp());
}

void webSocketCall(String req, String arg, Function callback) {
  ws.sink.add('{ "req": "$req", "arg": "$arg" }');
  wsCallback = (res) {
    if (res['req'] == req) callback(res['body']);
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MaterialApp(
        title: 'Youtube App',
        debugShowCheckedModeBanner: false,
        home: YoutubeBaseApp(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  var subApp = 0;

  void setSubApp(int newSubApp) {
    subApp = newSubApp;
    notifyListeners();
  }

  var musicUI = false;

  void setMusicUI(bool isMusicUI) {
    musicUI = isMusicUI;
    notifyListeners();
  }
}

class YoutubeBaseApp extends StatefulWidget {
  const YoutubeBaseApp({Key? key}) : super(key: key);

  @override
  State<YoutubeBaseApp> createState() => YoutubeBaseAppState();
}

class YoutubeBaseAppState extends State<YoutubeBaseApp> {
  var activeTab = 0;
  final tabItemKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
    4: GlobalKey<NavigatorState>(),
  };

  void setActiveTab(int tabItem) {
    if (tabItem == activeTab) {
      // pop to first route
      tabItemKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() => activeTab = tabItem);
    }
  }

  void showModel(Widget content) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return content;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await tabItemKeys[activeTab]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (activeTab != 0) {
            // select 'main' tab
            setActiveTab(0);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          offstageTabNavigator(0, HomePage(showModel: showModel)),
          offstageTabNavigator(1, ShortsPage(showModel: showModel)),
          offstageTabNavigator(2, CreatePage(showModel: showModel)),
          offstageTabNavigator(3, SubscriptionsPage(showModel: showModel)),
          offstageTabNavigator(4, LibraryPage(showModel: showModel)),
        ]),
        bottomNavigationBar: BottomNavigation(
          currentTab: activeTab,
          onSelectTab: setActiveTab,
        ),
      ),
    );
  }

  Widget offstageTabNavigator(int tabItem, Widget page) {
    return Offstage(
      offstage: activeTab != tabItem,
      child: TabNavigator(
        navigatorKey: tabItemKeys[tabItem],
        tabItem: tabItem,
        mainPage: page,
      ),
    );
  }
}

class BottomNavigation extends StatelessWidget {
  const BottomNavigation(
      {super.key, required this.currentTab, required this.onSelectTab});
  final int currentTab;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        type: BottomNavigationBarType.fixed,
        items: [
          bottomNavigationBarItem(0, 'Home', Icons.home_outlined, Icons.home),
          bottomNavigationBarItem(
              1, 'Shorts', Icons.app_shortcut_outlined, Icons.app_shortcut),
          bottomNavigationBarItem(
              2, 'Create', Icons.add_circle_outline, Icons.add_circle),
          bottomNavigationBarItem(3, 'Subscriptions',
              Icons.subscriptions_outlined, Icons.subscriptions),
          bottomNavigationBarItem(
              4, 'Library', Icons.video_library_outlined, Icons.video_library),
        ],
        onTap: (index) => onSelectTab(index),
        currentIndex: currentTab,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
      ),
    );
  }

  BottomNavigationBarItem bottomNavigationBarItem(
      int tabItem, String label, IconData icon, IconData activeIcon) {
    return BottomNavigationBarItem(
      activeIcon: Icon(activeIcon),
      icon: Icon(icon),
      label: label,
    );
  }
}

class TabNavigator extends StatelessWidget {
  const TabNavigator(
      {super.key,
      required this.navigatorKey,
      required this.tabItem,
      required this.mainPage});
  final GlobalKey<NavigatorState>? navigatorKey;
  final int tabItem;
  final Widget mainPage;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => mainPage,
        );
      },
    );
  }
}

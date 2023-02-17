import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
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
          offstageTabNavigator(0, HomePage()),
          offstageTabNavigator(1, ShortsPage()),
          offstageTabNavigator(2, CreatePage()),
          offstageTabNavigator(3, SubscriptionsPage()),
          offstageTabNavigator(4, LibraryPage()),
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

  // Scaffold(
  //   body: Container(
  //     decoration: const BoxDecoration(
  //       border: Border(
  //         bottom:
  //             BorderSide(width: 1.0, color: Color.fromARGB(255, 50, 50, 50)),
  //       ),
  //     ),
  //     child: YoutubeTabView(
  //       // Adding [UniqueKey] to make sure the widget rebuilds when transitioning.
  //       key: UniqueKey(),
  //       item: activeTab,
  //     ),
  //   ),
  //   bottomNavigationBar: BottomNavigationBar(
  //     showUnselectedLabels: true,
  //     items: bottomNavigationBarItems,
  //     currentIndex: activeTab,
  //     type: BottomNavigationBarType.fixed,
  //     onTap: (index) {
  //       setState(() {
  //         activeTab = index;
  //       });
  //     },
  //     selectedItemColor: Colors.white,
  //     unselectedItemColor: Colors.white,
  //     backgroundColor: const Color.fromARGB(255, 15, 15, 15),
  //   );
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
    final routeBuilders = routes(context, mainPage);
    return Navigator(
      key: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name!]!(context),
        );
      },
    );
  }
}

Map<String, WidgetBuilder> routes(BuildContext context, Widget mainPage) {
  return {
    '/': (context) => mainPage,
    '/notifications': (context) => NotificationPage(),
    '/search': (context) => SearchPage(),
  };
}

class YoutubeTabView extends StatelessWidget {
  const YoutubeTabView({
    Key? key,
    required this.item,
  }) : super(key: key);

  final int item;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (item) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = ShortsPage();
        break;
      case 2:
        page = CreatePage();
        break;
      case 3:
        page = SubscriptionsPage();
        break;
      case 4:
        page = LibraryPage();
        break;
      default:
        throw UnimplementedError('no widget for $item');
    }

    return Container(
      color: const Color.fromARGB(255, 15, 15, 15),
      child: page,
    );
  }
}

AppBar homeAppBar(AppState appState, BuildContext context) {
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
        onPressed: () {},
      ),
      IconButton(
        tooltip: 'Notifications',
        icon: const Icon(
          Icons.notifications_outlined,
        ),
        splashColor: Colors.transparent,
        splashRadius: 20,
        onPressed: () {
          var routeBuilders = routes(context, const Text('g'));

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => routeBuilders['/notifications']!(context),
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
            MaterialPageRoute(builder: (context) => SearchPage()),
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
        onPressed: () {},
      ),
    ],
  );
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var mainPage = Scaffold(
      appBar: homeAppBar(appState, context),
      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      body: const Center(
        child: Text(
          'Home Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    var routeBuilders = routes(context, mainPage);

    return Navigator(
      key: GlobalKey(),
      initialRoute: '/',
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name!]!(context),
        );
      },
    );
  }
}

class ShortsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: homeAppBar(appState, context),
      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      body: const Center(
        child: Text(
          'Shorts Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class CreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: homeAppBar(appState, context),
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

class SubscriptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: homeAppBar(appState, context),
      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      body: const Center(
        child: Text(
          'Subscriptions Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class LibraryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: homeAppBar(appState, context),
      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      body: const Center(
        child: Text(
          'Library Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        shadowColor: Colors.transparent,
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Cast',
            icon: const Icon(
              Icons.cast,
            ),
            splashColor: Colors.transparent,
            splashRadius: 20,
            onPressed: () {},
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
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        ],
      ),
      body: const Scaffold(
        backgroundColor: Color.fromARGB(255, 15, 15, 15),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        shadowColor: Colors.transparent,
        title: TextBox(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Microphone',
            icon: const Icon(Icons.mic),
            splashColor: Colors.transparent,
            splashRadius: 20,
            onPressed: () {},
          ),
        ],
      ),
      body: const Scaffold(
        backgroundColor: Color.fromARGB(255, 15, 15, 15),
      ),
    );
  }
}

class TextBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.transparent,
      child: TextField(
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1000.0),
            borderSide: const BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          hintText: 'Search Youtube',
          hintStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: const Color.fromARGB(255, 50, 50, 50),
          isDense: true,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}

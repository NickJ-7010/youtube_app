// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  wsCallback = callback;
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

class ShortsPage extends StatelessWidget {
  const ShortsPage({super.key, required this.showModel});
  final Function showModel;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: homeAppBar(appState, context, showModel),
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

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key, required this.showModel});
  final Function showModel;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: homeAppBar(appState, context, showModel),
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
  const LibraryPage({super.key, required this.showModel});
  final Function showModel;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: homeAppBar(appState, context, showModel),
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

class CastModelContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1000,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
        body: Column(
          children: [
            const SizedBox(
              height: 50,
              child: Text(
                'Connect to a device:',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      'Device: ${index + 1}?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
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
                MaterialPageRoute(
                  builder: (context) => SearchPage(
                    Provider.of<AppState>(context, listen: false),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Notifications Unavailable',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Notifications cannot be enabled',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Text(
                'account linking is not currently possible',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage(this.appState);
  final AppState appState;

  @override
  // ignore: no_logic_in_create_state
  SearchPageState createState() => SearchPageState(appState);
}

class SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin, RestorationMixin {
  bool isSearching = true;
  bool hasResults = false;
  bool hasBuilt = false;
  List suggestions = [];
  TextEditingController controller = TextEditingController();
  late TabController tabController;

  final RestorableInt tabIndex = RestorableInt(0);

  SearchPageState(this.appState);
  final AppState appState;

  @override
  String get restorationId => 'search_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(tabIndex, 'tab_index');
    tabController.index = tabIndex.value;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: appState.musicUI ? 1 : 0,
      length: isSearching ? 2 : 3,
      vsync: this,
    );
    tabController.addListener(() {
      setState(() {
        tabIndex.value = tabController.index;
        if (tabController.index != 2) {
          if (hasBuilt) {
            appState.setMusicUI(tabController.index == 0 ? false : true);
          } else {
            tabController.index = 1;
          }
        }
        if (!isSearching) search(controller.text);
        hasBuilt = true;
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    tabIndex.dispose();
    super.dispose();
  }

  void search(String text) {
    isSearching = false;
    hasResults = true;
    switch (tabController.index) {
      case 0:
        webSocketCall('search', text, (msg) => {print(jsonEncode(msg))});
        break;
      case 1:
        webSocketCall('music_search', text, (msg) => {print(jsonEncode(msg))});
        break;
      case 2:
        print('unimplemented');
        break;
    }
  }

  @override
  // ignore: avoid_renaming_method_parameters
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        shadowColor: Colors.transparent,
        bottom: TabBar(
          controller: tabController,
          isScrollable: false,
          indicatorColor: Colors.white,
          splashFactory: NoSplash.splashFactory,
          tabs: [
            const Tab(text: "YOUTUBE"),
            const Tab(text: "YT MUSIC"),
            if (!isSearching) const Tab(text: 'LIBRARY'),
          ],
        ),
        title: Container(
          alignment: Alignment.centerLeft,
          color: Colors.transparent,
          child: Column(
            children: [
              TextField(
                controller: controller,
                onChanged: (value) {
                  webSocketCall('get_search', value, (msg) {
                    setState(() {
                      suggestions = msg;
                    });
                  });
                },
                onSubmitted: search,
                autofocus: true,
                cursorColor: const Color.fromARGB(255, 14, 122, 254),
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
            ],
          ),
        ),
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
      body: Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        body: isSearching || !hasResults
            ? ListView(
                children: [
                  for (var item in suggestions)
                    GestureDetector(
                      onTap: () {
                        controller.text = item['suggestion']['text'];
                        search(controller.text);
                      },
                      child: ListTile(
                        leading: const Icon(Icons.search),
                        iconColor: Colors.white,
                        title: RichText(
                          text: TextSpan(
                            children: [
                              for (var row in item['suggestion']['runs'])
                                TextSpan(
                                  text: row['text'],
                                  style: TextStyle(
                                    fontWeight: row['bold']
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontStyle: row['italics']
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    decoration: row['strikethrough']
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : const Text("Helo", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            children: const [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Account And Settings Unavailable',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Account and settings aren\'t currently coded',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  FadeRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}

class SlideUpRoute extends PageRouteBuilder {
  final Widget page;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}

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
        home: YoutubeBaseApp(restorationId: '0'),
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
  const YoutubeBaseApp({
    Key? key,
    required this.restorationId,
  }) : super(key: key);

  final String restorationId;

  @override
  State<YoutubeBaseApp> createState() => _YoutubeBaseAppState();
}

class _YoutubeBaseAppState extends State<YoutubeBaseApp> with RestorationMixin {
  final RestorableInt tabIndex = RestorableInt(0);

  @override
  String get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(tabIndex, 'bottom_navigation_tab_index');
  }

  @override
  void dispose() {
    tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bottomNavigationBarItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.app_shortcut_outlined),
        activeIcon: Icon(Icons.app_shortcut),
        label: 'Shorts',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_outline),
        activeIcon: Icon(Icons.add_circle),
        label: 'Create',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.subscriptions_outlined),
        activeIcon: Icon(Icons.subscriptions),
        label: 'Subscriptions',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.video_library_outlined),
        activeIcon: Icon(Icons.video_library),
        label: 'Library',
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom:
                BorderSide(width: 1.0, color: Color.fromARGB(255, 50, 50, 50)),
          ),
        ),
        child: YoutubeTabView(
          // Adding [UniqueKey] to make sure the widget rebuilds when transitioning.
          key: UniqueKey(),
          item: tabIndex.value,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        items: bottomNavigationBarItems,
        currentIndex: tabIndex.value,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            tabIndex.value = index;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      ),
    );
  }
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
        onPressed: () {},
      ),
      IconButton(
        tooltip: 'Notifications',
        icon: const Icon(
          Icons.notifications_outlined,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationPage()),
          );
        },
      ),
      IconButton(
        tooltip: 'Search',
        icon: const Icon(
          Icons.search,
        ),
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
        onPressed: () {},
      ),
    ],
  );
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: homeAppBar(appState, context),
      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      body: const Center(
        child: Text(
          'Home Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
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
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Search',
            icon: const Icon(
              Icons.search,
            ),
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Microphone',
            icon: const Icon(
              Icons.mic,
            ),
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
          hintText: 'Search',
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

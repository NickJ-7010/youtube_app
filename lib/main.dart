import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Youtube App',
        debugShowCheckedModeBanner: false,
        home: TopNavBar(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  var subApp = 0;

  void setSubApp(int newSubApp) {
    subApp = newSubApp;
    notifyListeners();
  }
}

class TopNavBar extends StatelessWidget {
  const TopNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    Widget appPage;
    String appTitle;

    switch (appState.subApp) {
      case 0:
        appPage = YoutubeBaseApp(restorationId: '0');
        appTitle = 'Youtube';
        break;
      case 1:
        appPage = YoutubeMusicBaseApp(restorationId: '0');
        appTitle = 'Youtube Music';
        break;
      default:
        throw UnimplementedError('no widget for current subApp');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 15, 15, 15),
        shadowColor: Colors.transparent,
        title: Text(appTitle),
      ),
      body: appPage,
      drawer: Drawer(
          backgroundColor: Colors.black,
          child: ListView(
            children: [
              ListTile(
                iconColor: Colors.grey,
                textColor: Colors.white,
                hoverColor: Colors.white10,
                title: Text('Youtube'),
                leading: Icon(Icons.play_circle),
                onTap: () {
                  Navigator.pop(context);
                  appState.setSubApp(0);
                },
              ),
              ListTile(
                iconColor: Colors.grey,
                textColor: Colors.white,
                hoverColor: Colors.white10,
                title: Text('Youtube Music'),
                leading: Icon(Icons.album),
                onTap: () {
                  Navigator.pop(context);
                  appState.setSubApp(1);
                },
              ),
            ],
          )),
    );
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
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.app_shortcut_outlined),
        activeIcon: Icon(Icons.app_shortcut),
        label: 'Shorts',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_outline),
        activeIcon: Icon(Icons.add_circle),
        label: 'Create',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.subscriptions_outlined),
        activeIcon: Icon(Icons.subscriptions),
        label: 'Subscriptions',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.video_library_outlined),
        activeIcon: Icon(Icons.video_library),
        label: 'Library',
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
        backgroundColor: Color.fromARGB(255, 15, 15, 15),
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
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = GeneratorPage();
        break;
      case 3:
        page = FavoritesPage();
        break;
      case 4:
        page = GeneratorPage();
        break;
      default:
        throw UnimplementedError('no widget for $item');
    }

    return Container(
      color: Color.fromARGB(255, 15, 15, 15),
      child: page,
    );
  }
}

class YoutubeMusicBaseApp extends StatefulWidget {
  const YoutubeMusicBaseApp({
    Key? key,
    required this.restorationId,
  }) : super(key: key);

  final String restorationId;

  @override
  State<YoutubeMusicBaseApp> createState() => _YoutubeMusicBaseAppState();
}

class _YoutubeMusicBaseAppState extends State<YoutubeMusicBaseApp>
    with RestorationMixin {
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
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.explore_outlined),
        activeIcon: Icon(Icons.explore),
        label: 'Explore',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.library_music_outlined),
        activeIcon: Icon(Icons.library_music),
        label: 'Library',
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom:
                BorderSide(width: 1.0, color: Color.fromARGB(255, 50, 50, 50)),
          ),
        ),
        child: YoutubeMusicTabView(
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
        backgroundColor: Color.fromARGB(255, 15, 15, 15),
      ),
    );
  }
}

class YoutubeMusicTabView extends StatelessWidget {
  const YoutubeMusicTabView({
    Key? key,
    required this.item,
  }) : super(key: key);

  final int item;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (item) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = GeneratorPage();
        break;
      case 3:
        page = FavoritesPage();
        break;
      case 4:
        page = GeneratorPage();
        break;
      default:
        throw UnimplementedError('no widget for $item');
    }

    return Container(
      color: Color.fromARGB(255, 15, 15, 15),
      child: page,
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    var buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return Color.fromARGB(255, 25, 25, 25);
        },
      ),
      iconColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return Colors.pink;
        },
      ),
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                style: buttonStyle,
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: Colors.white,
    );

    return Card(
        color: Color.fromARGB(255, 25, 25, 25),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            pair.asLowerCase,
            style: style,
            semanticsLabel: pair.asPascalCase,
          ),
        ));
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var textStyle = TextStyle(color: Colors.white);

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text(
          'No favorites yet.',
          style: textStyle,
        ),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have ${appState.favorites.length} favorites:',
            style: textStyle,
          ),
        ),
        for (var pair in appState.favorites)
          ListTile(
            iconColor: Colors.pink,
            textColor: Colors.white,
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

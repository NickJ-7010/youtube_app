// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      child: MaterialApp(
        theme: ThemeData(
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Color.fromARGB(255, 15, 15, 15),
          ),
        ),
        title: 'Youtube App',
        debugShowCheckedModeBanner: false,
        home: const YoutubeBaseApp(),
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
  final DraggableScrollableController dragController =
      DraggableScrollableController();
  int activeTab = 0;
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
        body: Stack(
          children: <Widget>[
            offstageTabNavigator(0, HomePage(showModel: showModel)),
            offstageTabNavigator(1, ShortsPage(showModel: showModel)),
            offstageTabNavigator(2, CreatePage(showModel: showModel)),
            offstageTabNavigator(3, SubscriptionsPage(showModel: showModel)),
            offstageTabNavigator(4, LibraryPage(showModel: showModel)),
            // Positioned(
            //   bottom: 0,
            //   child: CustomBottomSheet(
            //     maxHeight: MediaQuery.of(context).size.height - 165,
            //     headerHeight: 50,
            //     header: Container(
            //       alignment: Alignment.center,
            //       decoration: const BoxDecoration(
            //         color: Colors.red,
            //         borderRadius:
            //             BorderRadius.vertical(top: Radius.circular(22.5)),
            //       ),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: <Widget>[
            //           Container(
            //             margin: const EdgeInsets.only(top: 6.0, bottom: 8.0),
            //             width: 30.0, // 10.w
            //             height: 6.5, // 0.8.h
            //             decoration: BoxDecoration(
            //                 color: const Color.fromARGB(50, 255, 255, 255),
            //                 borderRadius: BorderRadius.circular(50)),
            //           ),
            //           Text("Drag the header to see bottom sheet"),
            //         ],
            //       ),
            //     ),
            //     children: List.generate(
            //       30,
            //       (int index) => Container(
            //         width: double.infinity,
            //         height: 40.0,
            //         alignment: Alignment.center,
            //         color: Colors.red,
            //         child: Text("list item $index"),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
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
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
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

class CustomBottomSheet extends StatefulWidget {
  CustomBottomSheet({
    Key? key,
    this.scrollController,
    required this.maxHeight,
    this.headerHeight = 0.0,
    this.minHeight = 0.0,
    this.header,
    this.body,
    this.bgColor = Colors.white,
    this.borderRadius,
    this.boxShadow,
    this.hasBottomViewPadding = true,
    this.children,
  }) : super(key: key) {
    if (body == null && children == null) {
      assert(
          body != null || children != null, "either body or children required");
    }
    if (body != null && children != null) {
      assert(body != null || children != null,
          "can't have both body and children");
    }
    assert(headerHeight >= 0.0, "header height cannot be less than 0");
    if (header != null) {
      assert(headerHeight > 0.0, "header height required if header is present");
    }
  }

  final ScrollController? scrollController;
  final double maxHeight;
  final double headerHeight;

  /// if you want the bottom sheet to be shown (not including header part)
  final double minHeight;
  final Widget? header;
  final Widget? body;
  final List<Widget>? children;
  final Color bgColor;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;

  /// for safe area - bottom: true effect
  final bool hasBottomViewPadding;

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with SingleTickerProviderStateMixin<CustomBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  Animation? _animation;
  AnimationController? _animationController;

  double _bodyHeight = 0.0;
  bool _isAtTop = false;
  double _initPosition = 0.0;

  void _saveInitPosition(DragStartDetails d) =>
      _initPosition = d.globalPosition.dy;

  /// scroll based on position
  Future<void> _onDragEndPosition(DragEndDetails d) async {
    _animationController!.duration = const Duration(milliseconds: 300);
    if (_bodyHeight >= widget.maxHeight * 1 / 3) {
      _animation = Tween<double>(begin: _bodyHeight, end: widget.maxHeight)
          .animate(_animationController!);
      _animationController?.reset();
      await _animationController?.forward();
    }
    if (_bodyHeight < widget.maxHeight * 1 / 3) {
      _animation = Tween<double>(begin: _bodyHeight, end: 0.0)
          .animate(_animationController!);
      _animationController?.reset();
      await _animationController?.forward();
    }
  }

  Future<void> _onDragEndVelocitySimple(DragEndDetails d) async {
    double end;
    if (d.primaryVelocity! < 0.0) {
      end = widget.maxHeight;
    } else {
      end = 0.0;
    }
    _animation = Tween<double>(begin: _bodyHeight, end: end)
        .animate(_animationController!);
    _animationController?.reset();
    await _animationController?.forward();
  }

  void _followDragWithBodyAsList(DragUpdateDetails d) {
    final double movedAmount = _initPosition - d.globalPosition.dy;

    /// negative = drag down, positive = drag up
    final double scrollTo = _scrollController.offset + movedAmount;

    /// needed for scrolling the inner list

    /// the list inside has not been touched yet
    if (_scrollController.position.extentBefore == 0.0) {
      if (_isAtTop && d.primaryDelta!.isNegative) {
        /// bottom sheet has been scrolled to the top and the user is scrolling more upwards
        _scrollController.jumpTo(scrollTo);
      } else {
        /// follow drag gesture
        double newHeight = _bodyHeight + movedAmount;
        if (newHeight < 0.0) newHeight = 0.0;

        /// makes sure the bodyHeight does not fall under 0.0
        if (newHeight > widget.maxHeight) {
          newHeight = widget.maxHeight;
        }

        /// makes sure the bodyHeight does not go above max height
        _bodyHeight = newHeight;
        setState(() {});
        _isAtTop = false;
      }
    } else {
      /// user is scrolling the inner list
      if (scrollTo > _scrollController.position.maxScrollExtent) return;
      _scrollController.jumpTo(scrollTo);
    }
    _initPosition = d.globalPosition.dy;
  }

  Future<void> _onDragEndWithBodyAsList(DragEndDetails d) async {
    if (d.primaryVelocity == null) return;

    if (!_isAtTop) {
      /// scrolls the bottom sheet container
      if (d.primaryVelocity == 0) await _onDragEndPosition(d);
      if (d.primaryVelocity != 0) await _onDragEndVelocitySimple(d);
    } else {
      /// scrolls the inner list
      double animateTo = _scrollController.offset - d.primaryVelocity! / 5;

      if (d.primaryVelocity! > 0.0 && animateTo < 0.0) animateTo = 0.0;

      /// does not overscroll upwards
      if (d.primaryVelocity! < 0.0 &&
          animateTo > _scrollController.position.maxScrollExtent) {
        animateTo = _scrollController.position.maxScrollExtent;

        /// does not overscroll downwards
      }

      int duration = 1600;

      /// scroll duration for inner parts

      if (animateTo == 0.0 && _scrollController.offset - animateTo < duration) {
        duration = 600;
      }

      if (animateTo == _scrollController.offset &&
          _scrollController.offset - animateTo < duration) {
        duration = 300;
      }

      await _scrollController.animateTo(animateTo,
          duration: Duration(milliseconds: duration),
          curve: Curves.easeOutCubic);
    }

    if (_bodyHeight >= widget.maxHeight) {
      _isAtTop = true;
    } else {
      _isAtTop = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )
      ..addListener(() {
        _bodyHeight = _animation!.value;

        /// this is for when the bottom sheet was controlled by animation controller
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed &&
            _bodyHeight >= widget.maxHeight) _isAtTop = true;
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _saveInitPosition,
      onVerticalDragUpdate: _followDragWithBodyAsList,
      onVerticalDragEnd: _onDragEndWithBodyAsList,
      child: SingleChildScrollView(
        child: Container(
          padding: widget.hasBottomViewPadding
              ? EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom)
              : null,
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(
              maxHeight: widget.maxHeight + widget.headerHeight,
              minHeight: widget.headerHeight + widget.minHeight),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: widget.borderRadius,
            boxShadow: widget.boxShadow,
          ),
          height: widget.headerHeight +
              _bodyHeight +
              (widget.hasBottomViewPadding
                  ? MediaQuery.of(context).viewPadding.bottom
                  : 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: widget.headerHeight,
                alignment: Alignment.center,
                child: widget.header,
              ),
              Expanded(
                child: widget.body ??
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 45.0),
                        itemCount: widget.children!.length,
                        itemBuilder: (_, int index) => widget.children![index]),
              )
            ],
          ),
        ),
      ),
    );
  }
}

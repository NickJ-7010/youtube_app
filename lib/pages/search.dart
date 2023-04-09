// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';

class SearchPage extends StatefulWidget {
  const SearchPage(this.appState);
  final AppState appState;

  @override
  // ignore: no_logic_in_create_state
  SearchPageState createState() => SearchPageState(appState);
}

class SearchPageState extends State<SearchPage>
    with TickerProviderStateMixin, RestorationMixin {
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
    createTabController();
  }

  @override
  void dispose() {
    tabController.dispose();
    tabIndex.dispose();
    super.dispose();
  }

  void createTabController() {
    setState(() {
      tabController = TabController(
        initialIndex: isSearching
            ? appState.musicUI
                ? 1
                : 0
            : tabController.index,
        length: isSearching ? 2 : 3,
        vsync: this,
      );
      tabController.addListener(() {
        if (controller.text.isNotEmpty) {
          tabIndex.value = tabController.index;
          if (tabController.index != 2) {
            if (hasBuilt) {
              appState.setMusicUI(tabController.index == 0 ? false : true);
            }
          }
          if (isSearching) {
            webSocketCall(
                tabController.index == 0 ? 'get_search' : 'get_music_search',
                controller.text, (msg) {
              setState(() {
                suggestions = msg;
              });
            });
          } else {
            search(controller.text);
          }
        } else {
          if (hasBuilt) {
            appState.setMusicUI(tabController.index == 0 ? false : true);
          } else {
            tabController.index = 1;
          }
          tabIndex.value = tabController.index;
        }
        hasBuilt = true;
      });
    });
  }

  void search(String text) {
    setState(() {
      isSearching = false;
      hasResults = true;
      createTabController();
    });
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
    Widget searchContent;
    switch (tabController.index) {
      case 0:
        searchContent = const Text("Youtube Search Results",
            style: TextStyle(color: Colors.white));
        break;
      case 1:
        searchContent = const Text("Youtube Music Search Results",
            style: TextStyle(color: Colors.white));
        break;
      case 2:
        searchContent = const Text("Downloaded Library Search Results",
            style: TextStyle(color: Colors.white));
        break;
      default:
        searchContent =
            const Text("Error", style: TextStyle(color: Colors.white));
        break;
    }

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
                  if (value.isNotEmpty) {
                    webSocketCall(
                        appState.musicUI ? 'get_music_search' : 'get_search',
                        value, (msg) {
                      setState(() {
                        suggestions = msg;
                      });
                    });
                  } else {
                    suggestions = [];
                  }
                },
                onTap: () {
                  setState(() {
                    isSearching = true;
                    createTabController();
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
                    item is String
                        ? GestureDetector(
                            onTap: () {
                              controller.text = item;
                              search(controller.text);
                            },
                            child: ListTile(
                              leading: const Icon(Icons.search),
                              iconColor: Colors.white,
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: item.toString().substring(
                                            0,
                                            min(controller.text.length,
                                                item.length)),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                      text: item.toString().substring(
                                            min(
                                              controller.text.length,
                                              item.length,
                                            ),
                                          ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
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
                                                : FontWeight.normal),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                ],
              )
            : searchContent,
      ),
    );
  }
}

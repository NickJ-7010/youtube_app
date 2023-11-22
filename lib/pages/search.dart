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
  bool library = false;
  bool hasResults = false;
  bool hasBuilt = false;
  List suggestions = [];
  dynamic searchRes = {};
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
            ? library
                ? 2
                : appState.musicUI
                    ? 1
                    : 0
            : tabController.index,
        length: 3,
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
      hasResults = false;
      createTabController();
      switch (tabController.index) {
        case 0:
          webSocketCall(
              'search',
              text,
              (msg) => {
                    setState(() {
                      searchRes = msg;
                      hasResults = true;
                    })
                  });
          break;
        case 1:
          webSocketCall(
              'music_search',
              text,
              (msg) => {
                    setState(() {
                      searchRes = msg;
                      print(jsonEncode(searchRes));
                      hasResults = true;
                    })
                  });
          break;
        case 2:
          print('unimplemented');
          hasResults = true;
          break;
      }
    });
  }

  @override
  // ignore: avoid_renaming_method_parameters
  Widget build(BuildContext buildContext) {
    Widget searchContent = Container();
    if (hasResults) {
      switch (tabController.index) {
        case 0:
          searchContent = const Text("Youtube Search Results",
              style: TextStyle(color: Colors.white));
          break;
        case 1:
          searchContent = MusicSearchWidget(searchRes: searchRes);
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
          tabs: const [
            Tab(text: "YOUTUBE"),
            Tab(text: "YT MUSIC"),
            Tab(text: 'LIBRARY'),
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
                    if (library) {
                      suggestions = [];
                    } else {
                      webSocketCall(
                          appState.musicUI ? 'get_music_search' : 'get_search',
                          value, (msg) {
                        setState(() {
                          suggestions = msg;
                        });
                      });
                    }
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
        body: isSearching
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

class MusicSearchWidget extends StatelessWidget {
  const MusicSearchWidget({
    super.key,
    required this.searchRes,
  });

  final dynamic searchRes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    x(searchRes['header']['chips'])
                        ? GestureDetector(
                            onTap: () {
                              print('remove music filter');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                              ),
                              margin: const EdgeInsets.only(right: 7),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          )
                        : Container(),
                    for (var chip in searchRes['header']['chips'])
                      Chip(
                        endpoint: chip['endpoint']['payload']['params'],
                        text: chip['text'],
                        active: chip['is_selected'],
                      ),
                  ],
                ),
              ),
            ),
          ),
          for (var shelf in searchRes['contents'])
            shelf['type'] == 'MusicShelf'
                ? Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          highlightColor: Colors.white10,
                          splashColor: Colors.white10,
                          onTap: () {
                            useMusicFilter(
                                shelf['endpoint']['payload']['params']);
                          },
                          child: Container(
                            height: 50,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  shelf['title']['text'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    highlightColor: Colors.white10,
                                    splashColor: Colors.white10,
                                    borderRadius: BorderRadius.circular(100),
                                    onTap: () {
                                      useMusicFilter(shelf['endpoint']
                                          ['payload']['params']);
                                    },
                                    child: Container(
                                      height: 25,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        shelf['bottom_text']['text'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      for (var item in shelf['contents'])
                        MusicSearchItem(item: item),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        height: 50,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          shelf['header']['title']['text'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(15, 255, 255, 255),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(15, 255, 255, 255),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 40,
                                          margin: const EdgeInsets.only(
                                            right: 7,
                                          ),
                                          child: shelf['subtitle']['runs'][0]
                                                          ['text'] ==
                                                      'Artist' ||
                                                  shelf['subtitle']['runs'][0]
                                                          ['text'] ==
                                                      'Profile'
                                              ? CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: NetworkImage(
                                                    shelf['thumbnail']
                                                        ['contents'][0]['url'],
                                                  ),
                                                )
                                              : Image.network(
                                                  shelf['thumbnail']['contents']
                                                      [0]['url'],
                                                  width: 40,
                                                ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                shelf['title']['text'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Row(
                                                children: [
                                                  for (var badge in shelf[
                                                      'subtitle_badges'])
                                                    badge['icon_type'] ==
                                                            'MUSIC_EXPLICIT_BADGE'
                                                        ? Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 3),
                                                            child: const Icon(
                                                              Icons.explicit,
                                                              color:
                                                                  Colors.grey,
                                                              size: 20,
                                                            ),
                                                          )
                                                        : Text(
                                                            badge['icon_type'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                  Expanded(
                                                    child: Text(
                                                      shelf['subtitle']['text'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.centerRight,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              highlightColor: Colors.white10,
                                              splashColor: Colors.white10,
                                              onTap: () {
                                                print('tapped');
                                              },
                                              child: const SizedBox(
                                                height: 40,
                                                child: Icon(
                                                  Icons.more_vert,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  shelf['buttons'][0]['text'],
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              border: Border.all(
                                                color: Colors.white24,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  shelf['buttons'][1]['text'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            shelf.containsKey('contents')
                                ? Column(
                                    children: [
                                      const SizedBox(height: 5),
                                      for (var item in shelf['contents'])
                                        MusicSearchItem(item: item),
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
        ],
      ),
    );
  }
}

class MusicSearchItem extends StatelessWidget {
  const MusicSearchItem({
    super.key,
    required this.item,
  });

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.white10,
        splashColor: Colors.white10,
        onTap: () {
          print('tapped');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                margin: const EdgeInsets.only(
                  right: 7,
                ),
                child: item.containsKey('title')
                    ? Image.network(
                        item['thumbnail']['contents'][0]['url'],
                        width: 40,
                      )
                    : CircleAvatar(
                        radius: 100,
                        backgroundImage: NetworkImage(
                          item['thumbnail']['contents'][0]['url'],
                        ),
                      ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['flex_columns'][0]['title']['text'],
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        for (var badge in item['badges'])
                          badge['icon_type'] == 'MUSIC_EXPLICIT_BADGE'
                              ? Container(
                                  margin: const EdgeInsets.only(right: 3),
                                  child: const Icon(
                                    Icons.explicit,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                )
                              : Text(
                                  badge['icon_type'] ?? badge['type'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                        Expanded(
                          child: Text(
                            item['flex_columns'][1]['title']['text'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    highlightColor: Colors.white10,
                    splashColor: Colors.white10,
                    onTap: () {
                      print('tapped');
                    },
                    child: const SizedBox(
                      height: 40,
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void useMusicFilter(String endpoint) {
  print("Music Filter: $endpoint");
}

bool x(dynamic array) {
  for (var e in array) {
    if (e['is_selected']) return true;
  }
  return false;
}

class Chip extends StatelessWidget {
  const Chip({
    super.key,
    required this.text,
    required this.endpoint,
    required this.active,
  });

  final String text;
  final String endpoint;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (active) {
          print('remove music filter');
        } else {
          useMusicFilter(endpoint);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: active ? Colors.white : Colors.white12,
          ),
          borderRadius: BorderRadius.circular(6),
          color: active ? Colors.white : const Color.fromARGB(255, 27, 27, 27),
        ),
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: active ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}

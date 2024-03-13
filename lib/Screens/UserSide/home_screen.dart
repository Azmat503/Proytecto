import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/Screens/UserSide/Article/article_detail_screen.dart';
import 'package:proyecto/Screens/UserSide/Article/article_screen.dart';
import 'package:proyecto/Screens/UserSide/Message/chat_screen.dart';
import 'package:proyecto/Screens/UserSide/Article/create_article_screen.dart';
import 'package:proyecto/Screens/UserSide/Event/event_detail_screen.dart';
import 'package:proyecto/Screens/UserSide/Event/event_screen.dart';
import 'package:proyecto/Screens/UserSide/Inbox/inbox_screen.dart';
import 'package:proyecto/Screens/UserSide/Auth/login_screen.dart';
import 'package:proyecto/Screens/UserSide/NewFeed/Screen/new_feed_screen.dart';
import 'package:proyecto/Screens/UserSide/Posts/post_detail_screen.dart';
import 'package:proyecto/Screens/UserSide/Posts/post_screen.dart';
import 'package:proyecto/Screens/UserSide/Profile/profile_screen.dart';
import 'package:proyecto/Screens/UserSide/Setting/settings_screen.dart';
import 'package:proyecto/Screens/UserSide/Studies/studies_detail_screen.dart';
import 'package:proyecto/Screens/UserSide/Studies/studies_screen.dart';
import 'package:proyecto/Screens/UserSide/Studies/write_study_detail_screen.dart';
import 'package:proyecto/Screens/UserSide/Studies/write_study_screen.dart';
import 'package:proyecto/Screens/UserSide/UserProfile/user_profile_screen.dart';
import 'package:proyecto/Views/side_menu_container.dart';

import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:firebase_messaging/firebase_messaging.dart';

var selectedIndex = 0;
var previousSelectedIndex = 0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchTextController = TextEditingController();
  bool isProfileContainerVisible = true;

  String? selectedValue;
  FirebaseAuth user = FirebaseAuth.instance;
  String myId = '';
  String myUsername = '';
  String myEmail = '';
  String profileImageUrl = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    touchmatchMedia = html.window.matchMedia('(pointer: coarse)').matches;
    getdata();

    // FirebaseMessaging.onMessage.listen((event) {
    //   print(event);
    //   FirebaseNotifications(message: event).showFlutterNotification();
    // });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.sizeOf(context).width;
    height = MediaQuery.sizeOf(context).height;
    return Scaffold(
        drawerEnableOpenDragGesture: true,
        drawer: customDrawer(),
        key: _scaffoldKey,
        body: determinLayout());
  }

  Widget determinLayout() {
    return desktopLayout();
  }

  Widget desktopLayout() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (width > 800) customDrawer(),
          Expanded(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(left: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (isProfileContainerVisible) homeProfileContainer(),
                  Expanded(child: tabsContent()),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Drawer customDrawer() {
    return Drawer(
      width: 170,
      child: Container(
        width: 100,
        color: Colors.black,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                "assets/twitterIcon.png",
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            sideMenuContainerWidget()
          ],
        ),
      ),
    );
  }

  Widget sideMenuContainerWidget() {
    return Expanded(
      child: SizedBox(
        width: 150,
        child: ListView.builder(
          itemCount: sideMenuList.length,
          itemBuilder: (context, index) {
            var data = sideMenuList[index];

            return Column(
              children: [
                SideMenuContainer(
                  buttonIcon: data.icon,
                  buttonTitle: data.title,
                  isSelected: data.isSelected,
                  onPressed: () {
                    if (index == 5) {
                      selectedIndex = 13;
                      isProfileContainerVisible = false;
                    } else {
                      selectedIndex = index;
                      isProfileContainerVisible = true;
                    }
                    previousSelectedIndex = index;

                    setState(() {});
                    setState(() {
                      for (var i = 0; i < sideMenuList.length; i++) {
                        sideMenuList[i].isSelected = (i == index);
                      }
                    });
                    if (width < 800) {
                      _scaffoldKey.currentState!.openEndDrawer();
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget tabsContent() {
    if (selectedIndex == 0) {
      isProfileContainerVisible = true;
      setState(() {});
      return NewFeedScreen(
        postClick: () {
          selectedIndex = 5;
          tabsContent();
        },
        articleClick: () {
          selectedIndex = 6;
          tabsContent();
        },
        seeUserProfileClick: () {
          selectedIndex = 11;
          tabsContent();
        },
        onEventClick: () {
          selectedIndex = 8;
          tabsContent();
        },
      );
    } else if (selectedIndex == 1) {
      isProfileContainerVisible = true;
      setState(() {});
      return PostScreen(postClick: () {
        selectedIndex = 5;
        tabsContent();
      }, articleClick: () {
        selectedIndex = 6;
        tabsContent();
      }, seeUserProfileClick: () {
        selectedIndex = 11;
        tabsContent();
      });
    } else if (selectedIndex == 2) {
      isProfileContainerVisible = true;
      setState(() {});
      return ArticleScreen(
        postClick: () {
          selectedIndex = 6;
          tabsContent();
        },
        seeUserProfileClick: () {
          selectedIndex = 11;
          tabsContent();
        },
        createArticleClick: () {
          selectedIndex = 17;
          tabsContent();
        },
      );
    } else if (selectedIndex == 3) {
      isProfileContainerVisible = true;
      setState(() {});
      return StudiesScreen(
        onClick: () {
          selectedIndex = 7;
          tabsContent();
        },
        writeStudyClick: () {
          selectedIndex = 15;
          tabsContent();
        },
      );
    } else if (selectedIndex == 4) {
      isProfileContainerVisible = true;
      setState(() {});
      return EventScreen(
        onEventClick: () {
          selectedIndex = 8;
          tabsContent();
        },
      );
    } else if (selectedIndex == 5) {
      isProfileContainerVisible = false;
      setState(() {});
      return PostDetailScreen(
        postClick: () {
          selectedIndex = previousSelectedIndex;
          tabsContent();
        },
      );
    } else if (selectedIndex == 6) {
      isProfileContainerVisible = false;
      setState(() {});
      return ArticleDetailScreen(
        postClick: () {
          tabsContent();
        },
      );
    } else if (selectedIndex == 7) {
      isProfileContainerVisible = false;
      setState(() {});
      return StudiesDetailScreen(
        onBackPressed: () {
          selectedIndex = 3;
          tabsContent();
        },
      );
    } else if (selectedIndex == 8) {
      isProfileContainerVisible = false;
      setState(() {});
      return EventDetailScreen(
        onBackPressed: () {
          selectedIndex = previousSelectedIndex;
          tabsContent();
        },
      );
    } else if (selectedIndex == 9) {
      isProfileContainerVisible = false;
      setState(() {});
      return MyProfileScreen(
        onBackPressed: () {
          selectedIndex = previousSelectedIndex;
          tabsContent();
        },
      );
    } else if (selectedIndex == 10) {
      isProfileContainerVisible = false;
      setState(() {});
      return SettingScreen(
        onBackPressed: () {
          selectedIndex = previousSelectedIndex;
          tabsContent();
        },
      );
    } else if (selectedIndex == 11) {
      isProfileContainerVisible = false;
      setState(() {});
      return UserProfileScreen(
          onBackPressed: () {
            selectedIndex = previousSelectedIndex;
            tabsContent();
          },
          goToChatPressed: () {
            selectedIndex = 14;
            tabsContent();
          },
          userId: "");
    } else if (selectedIndex == 13) {
      isProfileContainerVisible = false;
      setState(() {});
      return const InboxScreen();
    } else if (selectedIndex == 14) {
      isProfileContainerVisible = false;
      setState(() {});
      return ChatScreen(
        onBackPressed: () {
          selectedIndex = 11;
          tabsContent();
        },
      );
    } else if (selectedIndex == 15) {
      isProfileContainerVisible = false;
      setState(() {});
      return WriteStudyScreen(onBackPressed: () {
        selectedIndex = 3;
        tabsContent();
      }, nextButtonPressed: () {
        selectedIndex = 16;
        tabsContent();
      });
    } else if (selectedIndex == 16) {
      isProfileContainerVisible = false;
      setState(() {});
      return WriteStudyDetailScreen(onBackPressed: () {
        selectedIndex = 15;
        tabsContent();
      });
    } else {
      isProfileContainerVisible = false;
      setState(() {});
      return CreateArticleContainer(
        onBackPressed: () {
          selectedIndex = 2;
          tabsContent();
        },
      );
    }
  }

  Widget homeProfileContainer() {
    var isMobile = (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
    return Container(
      width: width,
      height: height * 0.06,
      color: Colors.white,
      margin: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // if (isMobile == true) Container(),
            if (width < 800)
              GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
                child: Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.menu),
                ),
              ),
            if (isMobile == false && width > 800)
              Container(
                width: width * 0.33,
                padding: const EdgeInsets.only(left: 10, right: 10),
                margin: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(
                      width: 1,
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(50 / 2)),
                child: TextField(
                  controller: searchTextController,
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(fontSize: width * 0.009)),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: "Search Here.....",
                      prefixIcon: Image.asset(
                        "assets/search.png",
                      )),
                ),
              ),
            Container(
              margin: const EdgeInsets.only(right: 20),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: postButtonColor,
                  ),
                  child: Center(
                      child: Image.asset(
                    "assets/mailbox.png",
                    width: 18,
                    height: 18,
                  )),
                ),
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (profileImageUrl.isNotEmpty)
                          CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: Image.network(
                                profileImageUrl,
                                width: width * 0.04,
                                height: width * 0.04,
                              ).image),
                        if (profileImageUrl.isEmpty)
                          Image.asset(
                            "assets/profilepic.png",
                            width: width * 0.04,
                            height: width * 0.04,
                          ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(myUsername,
                                style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))),
                            Row(
                              children: [
                                Text(
                                  myEmail,
                                  style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal)),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTapDown: (detail) {
                                      showRightAlignedPopupMenu(
                                          context, detail);
                                    },
                                    onTap: () {},
                                    child: Image.asset("assets/dropdown.png")),
                              ],
                            )
                          ],
                        )
                      ]),
                )
              ]),
            ),
          ]),
    );
  }

  Widget homeScreenForMBLView() {
    return Column(
      children: [
        if (isProfileContainerVisible) homeProfileContainerForMBL(),
        Expanded(child: tabsContent())
      ],
    );
  }

  Widget homeProfileContainerForMBL() {
    return Container(
      width: width,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.menu),
            ),
          ),
          SizedBox(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (profileImageUrl.isNotEmpty)
                CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: Image.network(
                      profileImageUrl,
                      width: width * 0.04,
                      height: width * 0.04,
                    ).image),
              if (profileImageUrl.isEmpty)
                Image.asset(
                  "assets/profilepic.png",
                  width: width * 0.04,
                  height: width * 0.04,
                ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(myUsername,
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold))),
                  Row(
                    children: [
                      Text(
                        myEmail,
                        style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal)),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTapDown: (detail) {
                            showRightAlignedPopupMenu(context, detail);
                          },
                          onTap: () {},
                          child: Image.asset("assets/dropdown.png")),
                    ],
                  )
                ],
              )
            ]),
          )
        ],
      ),
    );
  }

  void showRightAlignedPopupMenu(
      BuildContext context, TapDownDetails detail) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = Offset(overlay.size.width - 50, 60);

    await showMenu(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20.0), // Adjust the radius as needed
      ),
      position: RelativeRect.fromRect(
          position & const Size(10, 40), Offset.zero & overlay.size),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 'profile',
          onTap: () {
            selectedIndex = 9;
            tabsContent();
          },
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: buttonColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Text('My Profile',
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          onTap: () {
            selectedIndex = 10;
            tabsContent();
          },
          child: Row(
            children: [
              Icon(
                Icons.settings,
                color: buttonColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Text('Settings',
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ));
          },
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: buttonColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Text('Logout',
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ],
    );
  }

  void getdata() async {
    var userId = user.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId.toString())
        .snapshots()
        .listen((userData) {
      setState(() {
        myId = userData.data()?['userId'];
        myUsername = userData.data()?['name'];
        myEmail = userData.data()?['email'];
        profileImageUrl = userData.data()?['imageUrl'];
      });
    });
  }
}

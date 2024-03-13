import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/Views/create_post_container.dart';
import 'package:proyecto/Views/my_post_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/Views/all_post_container.dart';

var selectedTabIndex = 0;

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final Function onBackPressed;
  final Function goToChatPressed;
  const UserProfileScreen(
      {super.key,
      required this.onBackPressed,
      required this.goToChatPressed,
      required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  late TabController tabviewController;
  TextEditingController searchTextController = TextEditingController();
  String userID = '';
  String myID = '';
  String myUsername = '';
  String myEmail = '';
  String myImageUrl = '';
  Map<String, dynamic>? userData;
  Map<String, dynamic>? myDataInfo;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  Stream<List<Map<String, dynamic>>>? _myAllPost;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    tabviewController = TabController(length: 3, vsync: this);
    user = auth.currentUser;
    userID = selectedUserId;
    getdata();
    myInfo();
  }

  @override
  void dispose() {
    tabviewController.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return homeProfileContainer();
  }

  Widget homeProfileContainer() {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          Container(
            width: width,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.only(left: 20, bottom: 20, top: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Row(children: [
                              GestureDetector(
                                onTap: () {
                                  selectedIndex = previousSelectedIndex;
                                  widget.onBackPressed();
                                },
                                child: Image.asset(
                                  "assets/back.png",
                                  width: 15,
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(myUsername,
                                      style: GoogleFonts.lato(
                                          textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))),
                                  Text("2345 Posts",
                                      style: GoogleFonts.lato(
                                          textStyle: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal))),
                                ],
                              ),
                            ]),
                          )
                        ]),
                  ),
                  Row(
                    children: [
                      Container(
                        width: width * 0.3,
                        height: 40,
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(50 / 2)),
                        child: TextField(
                          controller: searchTextController,
                          cursorHeight: 20,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: "Search Here.....",
                              prefixIcon: Image.asset(
                                "assets/search.png",
                                width: width * 0.03,
                              )),
                        ),
                      ),
                      Container(
                        width: width * 0.03,
                        height: width * 0.03,
                        margin: const EdgeInsets.only(right: 40),
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
                      )
                    ],
                  ),
                ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    profileContainer(),
                    const SizedBox(
                      height: 30,
                    ),
                    profilDetailContainer(),
                    const SizedBox(
                      height: 16,
                    ),
                    tabBarConatiner(),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 0.8,
                      color: const Color.fromRGBO(232, 232, 232, 1),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (selectedTabIndex == 0)
                      SizedBox(
                        width: double.infinity,
                        //margin: const EdgeInsets.symmetric(horizontal: 30),
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                            stream: _myAllPost,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }

                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              List<Map<String, dynamic>> newPosts =
                                  snapshot.data ?? [];
                              if (newPosts.isNotEmpty) {
                                return ListView.builder(
                                  key: UniqueKey(),
                                  itemCount: newPosts.length,
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var data = newPosts[index];

                                    return AllPostContainer(
                                      post: data,
                                      postClick: () {
                                        // widget.postClick();
                                      },
                                      articleClick: () {
                                        // widget.articleClick();
                                      },
                                    );
                                  },
                                );
                              } else {
                                return Container();
                              }
                            }),
                      ),
                    if (selectedTabIndex == 2)
                      SizedBox(
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: newFeedList.length,
                          primary: false,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var data = newFeedList[index];
                            return MyPostContainer(
                              post: data,
                              isFollowHidden: true,
                            );
                          },
                        ),
                      )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget profileContainer() {
    return SizedBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: width * 0.03,
                backgroundImage: myImageUrl.isNotEmpty
                    ? Image.network(
                        myImageUrl,
                      ).image
                    : Image.asset(
                        "assets/person.png",
                        fit: BoxFit.fill,
                        width: width * 0.07,
                        height: width * 0.07,
                      ).image,
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    myUsername,
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    myEmail,
                    style: GoogleFonts.lato(
                        textStyle:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (userID != myID)
                    GestureDetector(
                      onTap: () {
                        widget.goToChatPressed();
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 10),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: buttonColor),
                            borderRadius: BorderRadius.circular(20),
                            color: backgroundColor),
                        child: Center(
                            child: Text(
                          "Chat",
                          style: GoogleFonts.lato(
                              textStyle:
                                  TextStyle(color: buttonColor, fontSize: 10)),
                        )),
                      ),
                    )
                ],
              ),
            ],
          ),
          const SizedBox(
            width: 16,
          ),
          if (userID != myID)
            GestureDetector(
              onTap: () {
                if (isFollowing) {
                  unfollowButtonAction();
                } else {
                  followButtonAction();
                }
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 10),
                margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: isFollowing ? Colors.white : buttonColor),
                    borderRadius: BorderRadius.circular(20),
                    color: isFollowing ? buttonColor : backgroundColor),
                child: Center(
                    child: Text(
                  isFollowing ? "Un Follow" : "Follow",
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: isFollowing ? Colors.white : buttonColor,
                          fontSize: 10)),
                )),
              ),
            )
        ]),
      ]),
    );
  }

  Widget profilDetailContainer() {
    return SizedBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          myUsername,
          style: GoogleFonts.lato(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(userData?['status'] ?? "sd",
            style: GoogleFonts.lato(
              textStyle: const TextStyle(fontSize: 14),
            )),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Image.asset(
              "assets/pin.png",
              width: 15,
              height: 15,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(userData?['address'] ?? "Multan, Pakistan",
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(fontSize: 14),
                )),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Image.asset(
              "assets/birthday.png",
              width: 15,
              height: 15,
            ),
            const SizedBox(
              width: 10,
            ),
            Text("Born ${userData?['dob'] ?? 'November 10, 1998'}",
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(fontSize: 14),
                )),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Image.asset(
              "assets/link.png",
              width: 15,
              height: 15,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "assets/link.png",
              style: GoogleFonts.lato(
                  textStyle: TextStyle(fontSize: 14, color: buttonColor)),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: "${userData?['following'].toList().length ?? '145'}",
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                  TextSpan(
                      text: " Following",
                      style: GoogleFonts.lato(
                        textStyle: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ))
                ],
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: "${userData?['follower'].toList().length ?? '3249'}",
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextSpan(
                    text: " Followers",
                    style: GoogleFonts.lato(
                        textStyle:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  )
                ],
              ),
            )
          ],
        ),
      ]),
    );
  }

  Widget tabBarConatiner() {
    return Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 10),
        child: SizedBox(
            height: height * 0.03,
            width: double.infinity,
            child: TabBar(
                onTap: (index) {
                  selectedTabIndex = index;
                  setState(() {});
                },
                controller: tabviewController,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                labelPadding: const EdgeInsets.only(right: 50),
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                labelColor: buttonColor,
                labelStyle: GoogleFonts.lato(
                    textStyle: const TextStyle(fontWeight: FontWeight.w700)),
                unselectedLabelColor: Colors.black,
                unselectedLabelStyle: GoogleFonts.lato(
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400)),
                indicatorColor: buttonColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(
                      child: Text(
                    "Post ",
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12)),
                  )),
                  Tab(
                    child: Text(
                      "Network",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12),
                      ),
                    ),
                  ),
                  Tab(
                      child: Text("Save",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12)))),
                ])));
  }

  Future<void> getdata() async {
    if (userID != "") {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userID)
          .snapshots()
          .listen((userInfo) {
        if (mounted) {
          userData = userInfo.data();
          selectedUserId = userInfo.data()!['userId'];
          myUsername = userInfo.data()!['name'];
          myEmail = userInfo.data()!['email'];
          myImageUrl = userInfo.data()!['imageUrl'];

          _myAllPost = PostRepositort().fetchAllMyPosts(userID);

          setState(() {});
        }
      });
    } else {
      print("userId$selectedUserId is empty");
    }
  }

  Future<void> myInfo() async {
    if (user != null) {
      var userId = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId.toString())
          .snapshots()
          .listen((userInfo) {
        if (mounted) {
          myDataInfo = userInfo.data();
          myID = userInfo.data()!['userId'];
          isFollowing = myDataInfo!['following'].toList().contains(userID);

          setState(() {});
        }
      });
    }
  }

  void followButtonAction() {
    FirebaseFirestore.instance.collection("Users").doc(myID).update({
      "following": FieldValue.arrayUnion([selectedUserId.toString()])
    });
    FirebaseFirestore.instance.collection("Users").doc(selectedUserId).update({
      "follower": FieldValue.arrayUnion([myID])
    });
  }

  void unfollowButtonAction() {
    FirebaseFirestore.instance.collection("Users").doc(myID).update({
      "following": FieldValue.arrayRemove([selectedUserId.toString()])
    });
    FirebaseFirestore.instance.collection("Users").doc(selectedUserId).update({
      "follower": FieldValue.arrayRemove([myID.toString()])
    });
  }
}

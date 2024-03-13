import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/Views/my_post_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/Views/all_post_container.dart';

var selectedTabIndex = 0;

class MyProfileScreen extends StatefulWidget {
  final Function onBackPressed;
  const MyProfileScreen({super.key, required this.onBackPressed});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with TickerProviderStateMixin {
  late TabController tabviewController;
  TextEditingController searchTextController = TextEditingController();
  String myId = '';
  String myUsername = '';
  String myEmail = '';
  String myImageUrl = '';
  Map<String, dynamic>? userData;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  List<Map<String, dynamic>> myAllPost = [];
  @override
  void initState() {
    super.initState();
    tabviewController = TabController(length: 3, vsync: this);
    user = auth.currentUser;
    getdata();
    //getAllPost();
  }

  @override
  void dispose() {
    tabviewController.dispose();
    super.dispose();
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
                    if (selectedTabIndex == 0) Container(),
                    SizedBox(
                      width: double.infinity,
                      //margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: ListView.builder(
                        key: UniqueKey(),
                        itemCount: myAllPost.length,
                        primary: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var data = myAllPost[index];
                          if (data['postType'] != "article") {
                            return AllPostContainer(
                              post: data,
                              postClick: () {
                                // widget.postClick();
                              },
                              articleClick: () {
                                // widget.articleClick();
                              },
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
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
                    height: 20,
                  ),
                  Container(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 10, top: 10),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border.all(width: 1, color: buttonColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text("Become a value creator",
                            style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: buttonColor, fontSize: 10))),
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(
            width: 16,
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
            margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: buttonColor),
                borderRadius: BorderRadius.circular(20),
                color: backgroundColor),
            child: Center(
                child: Text(
              "Edit Profile",
              style: GoogleFonts.lato(
                  textStyle: TextStyle(color: buttonColor, fontSize: 10)),
            )),
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
    if (user != null) {
      var userId = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId.toString())
          .snapshots()
          .listen((userInfo) {
        setState(() {
          userData = userInfo.data();
          myId = userInfo.data()!['userId'];
          myUsername = userInfo.data()!['name'];
          myEmail = userInfo.data()!['email'];
          myImageUrl = userInfo.data()!['imageUrl'];
          fetchAllMyPosts(userId);
        });
      });
    }
  }

  Future<void> fetchAllMyPosts(userId) async {
    FirebaseFirestore.instance
        .collection('Posts')
        .where("userId", isEqualTo: userId)
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .listen((allPostSnapshot) {
      myAllPost.clear();
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        myAllPost.add(post);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }
}

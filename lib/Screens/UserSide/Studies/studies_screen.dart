import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/Views/feedback_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:html' as html;

class StudiesScreen extends StatefulWidget {
  final Function onClick;
  final Function writeStudyClick;
  const StudiesScreen(
      {super.key, required this.onClick, required this.writeStudyClick});

  @override
  State<StudiesScreen> createState() => _StudiesScreenState();
}

class _StudiesScreenState extends State<StudiesScreen> {
  TextEditingController searchTextController = TextEditingController();
  final TextEditingController articleEditingController =
      TextEditingController();
  String profileImageUrl = "";
  String myId = "";
  User? user;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> studiesList = [];
  var isMobile = false;
  final firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    chapterList.clear();
    if (foundation.defaultTargetPlatform == TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }
    user = auth.currentUser;
    touchmatchMedia = html.window.matchMedia('(pointer: coarse)').matches;
    getUserData();
    fetchStudiesList();
    // getAllCategoriesList();
    //  getAllArticles();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getUserData() async {
    if (user != null) {
      var userId = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId.toString())
          .snapshots()
          .listen((userInfo) {
        profileImageUrl = userInfo.data()?['imageUrl'];
        myId = userInfo.data()?['userId'];
        userData = userInfo.data();
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> fetchStudiesList() async {
    await firebaseFirestore.collection("Studies").snapshots().listen((studies) {
      studiesList.clear();
      for (DocumentSnapshot doc in studies.docs) {
        var data = doc.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> chapterList = [];
        firebaseFirestore
            .collection("Studies")
            .doc(data['studyId'])
            .collection("Chapters")
            .snapshots()
            .listen((chapters) {
          for (DocumentSnapshot doc in chapters.docs) {
            var data = doc.data() as Map<String, dynamic>;
            chapterList.add(data);
          }
          var study = {
            "studyName": data["Study Name"],
            "studyId": data["studyId"],
            "chapterList": chapterList,
            "user": data['user'],
            "joinedUsers": data['joinedUsers'],
            "commentCount": data['commentCount']
          };
          studiesList.add(study);
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor,
        margin: const EdgeInsets.only(top: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              createArticelContainer(),
              ListView.builder(
                  itemCount: studiesList.length,
                  primary: false,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var data = studiesList[index];
                    var joinedUsers = data['joinedUsers'].toList();
                    var isFollowed = joinedUsers.contains(myId);
                    return studyContainer(data, isFollowed);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget studyContainer(data, bool isFollowed) {
    var list = data['chapterList'];
    var userImageUrl = data['user']["imageUrl"];
    var userName = data['user']["name"];
    var userEmail = data['user']["email"];
    var commentsCount = data['commentCount'];
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.white,
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              SizedBox(
                child: Row(children: [
                  if (userImageUrl.isNotEmpty)
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: width * 0.02,
                      backgroundImage: Image.network(
                        userImageUrl,
                        fit: BoxFit.contain,
                      ).image,
                    ),
                  if (userImageUrl.isEmpty)
                    Image.asset(
                      "assets/profilepic.png",
                      width: width * 0.04,
                      height: width * 0.04,
                    ),
                  const SizedBox(
                    width: 16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEmail,
                        style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        userName,
                        style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        )),
                      ),
                    ],
                  ),
                ]),
              ),
              if (((userData?['userId'] != data['user']['userId'])) &&
                  (isFollowed == false))
                GestureDetector(
                  onTap: () {
                    postId = "";
                    postId = data['studyId'];

                    widget.onClick();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 20),
                    padding: const EdgeInsets.only(
                        top: 10, right: 20, left: 20, bottom: 10),
                    decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(
                          20,
                        )),
                    child: Center(
                        child: Text(
                      "Join Us",
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.009,
                              fontWeight: FontWeight.bold)),
                    )),
                  ),
                ),
            ]),
            const SizedBox(
              height: 10,
            ),
            Text(
              data['studyName'].toString(),
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: width * 0.01,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 10,
            ),
            if (list.length > 0)
              Column(
                children: List.generate(list.length ?? 0, (index) {
                  var chapter = list[index];

                  //return Container();
                  if (chapter['videoUrl'] != "") {
                    return Column(
                      children: [
                        userStudiesItem(
                            "assets/preview.png",
                            chapter["chapterName"],
                            "Preview",
                            data['studyId'],
                            index),
                        if (index < 6)
                          const Divider(
                            height: 1,
                          )
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        userStudiesItem(
                            "assets/group.png",
                            chapter["chapterName"],
                            "Preview",
                            data['studyId'],
                            index),
                        //if (index < 9)
                        const Divider(
                          height: 1,
                        )
                      ],
                    );
                  }
                }),
              ),
            const SizedBox(
              height: 10,
            ),
            FeedbackContainer(
              commentCount: commentsCount,
            ),
          ]),
        )
      ],
    );
  }

  Widget userStudiesItem(
      String icon, String title, String buttonTitle, String studyId, index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              icon,
              width: width * 0.008,
              height: width * 0.008,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(title,
                style: GoogleFonts.lato(
                    textStyle:
                        const TextStyle(color: Colors.black, fontSize: 12)))
          ],
        ),
        GestureDetector(
          onTap: () {
            postId = "";
            postId = studyId;
            studySelectedIndex = index;
            widget.onClick();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10, right: 20, top: 10),
            padding:
                const EdgeInsets.only(top: 7, right: 20, left: 20, bottom: 7),
            decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(
                  15,
                )),
            child: Center(
              child: Text(
                buttonTitle,
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: Colors.white, fontSize: width * 0.008)),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget createArticelContainer() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20),
          child: Text(
            "Write Study",
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                  fontFamily: "Lato",
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 30, right: 20, top: 8.0),
          height: 0.2,
          color: Colors.grey,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20, right: 20.0),
          child: SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (profileImageUrl.isNotEmpty)
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: width * 0.02,
                    backgroundImage: Image.network(
                      profileImageUrl,
                      fit: BoxFit.contain,
                    ).image,
                  ),
                if (profileImageUrl.isEmpty)
                  Image.asset(
                    "assets/profilepic.png",
                    width: width * 0.06,
                    height: width * 0.06,
                  ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: SizedBox(
                    width: width * 0.6,
                    child: TextField(
                      minLines: 1,
                      maxLines: 1,
                      controller: articleEditingController,
                      decoration: InputDecoration(
                          hintText: "Write study here..",
                          hintStyle: GoogleFonts.lato(
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                          border: InputBorder.none),
                      onChanged: (value) {
                        // print("onChanged Pressed");
                        //  isPostButtonEnable = postController.text.isNotEmpty;
                        //setState(() {});
                      },
                      onTap: () {
                        // isWrireArticle = true;
                        widget.writeStudyClick();
                        if (mounted) {
                          setState(() {});
                        }
                        //  print("OnTap Pressed");
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // pickArticlemages();
                      //getMultipleImageInfos();
                      // selectImage();

                      // _pickProfileImage();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, bottom: 20),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: postButtonColor,
                      ),
                      child: Center(
                          child: Image.asset(
                        "assets/gallery.png",
                        width: 13,
                        height: 13,
                      )),
                    ),
                  ),
                ],
              ),
            ),
            // if (isLoading)
            //   Container(
            //     width: 74,
            //     height: 50,
            //     margin: const EdgeInsets.only(bottom: 20, right: 20),
            //     decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(20), color: postColor),
            //     child: const Center(
            //       child: CircularProgressIndicator(),
            //     ),
            //   ),
            // if (!isLoading)
            GestureDetector(
              onTap: () {
                // if (postController.text.isNotEmpty) {
                //   savePost(postController.text, userData,
                //       uploadedProfileImage, fileType);
                //   postController.text = "";
                // }
              },
              child: Container(
                width: 74,
                height: 40,
                margin: const EdgeInsets.only(bottom: 20, right: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: postColor),
                child: const Center(
                  child: Text("Post"),
                ),
              ),
            ),
          ],
        )
      ]),
    );
  }
}

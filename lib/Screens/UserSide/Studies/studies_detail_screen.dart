import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:proyecto/Views/comment_container.dart';
import 'package:proyecto/Views/feedback_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:html' as html;
import 'package:visibility_detector/visibility_detector.dart';
import 'package:intl/intl.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:youtube_player_iframe_plus/youtube_player_iframe_plus.dart'
    as y_tplus;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

var isPlaying;

class ChaptersModel {
  Map<String, dynamic> chapterDetail = {};
  bool isSelected = false;
  String chapterId = "";
  ChaptersModel(
      {required this.chapterDetail,
      required this.chapterId,
      required this.isSelected});
}

class StudiesDetailScreen extends StatefulWidget {
  final Function onBackPressed;
  const StudiesDetailScreen({super.key, required this.onBackPressed});

  @override
  State<StudiesDetailScreen> createState() => _StudiesDetailScreenState();
}

class _StudiesDetailScreenState extends State<StudiesDetailScreen> {
  TextEditingController searchTextController = TextEditingController();
  bool isVideoTutorial = false;
  final TextEditingController commentTextController = TextEditingController();

  List<ChaptersModel> chaptersList = [];
  List<Map<String, dynamic>> commentList = [];
  List<String> joinedUsers = [];

  Map<String, dynamic>? userData;
  Map<String, dynamic>? studyUserData;
  Map<String, dynamic>? studyData;
  Map<String, dynamic>? chapterDetail;
  ChaptersModel? singleChapter;

  final firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  String profileImageUrl = "";
  String userProfileImageUrl = "";

  var isMobile = false;

  var chapterId = "";
  String myId = "";
  var isFollowed = false;
  String formattedTime = "";
  String formattedDate = "";
  bool isFirstLoad = true;
  var selectedIndex = 0;
  var isFollowing = true;
  @override
  void initState() {
    super.initState();

    if (foundation.defaultTargetPlatform == TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }
    user = auth.currentUser;
    touchmatchMedia = html.window.matchMedia('(pointer: coarse)').matches;
    getUserData();
    fetchJoinedUserList();
    fetchChapterList();
    // getAllCategoriesList();
    //  getAllArticles();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 20, bottom: 20, top: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: Row(children: [
                              GestureDetector(
                                onTap: () {
                                  selectedIndex = 3;
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
                              Text("Studies Detail Page",
                                  style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold))),
                            ]),
                          )
                        ]),
                  ),
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
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(fontSize: width * 0.01)),
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
                ]),
          ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: width * 0.3,
                color: backgroundColor,
                margin: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (userProfileImageUrl.isNotEmpty)
                                      CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        radius: width * 0.02,
                                        backgroundImage: Image.network(
                                          userProfileImageUrl,
                                          fit: BoxFit.contain,
                                        ).image,
                                      ),
                                    if (userProfileImageUrl.isEmpty)
                                      Image.asset(
                                        "assets/profilepic.png",
                                        width: width * 0.06,
                                        height: width * 0.06,
                                      ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          studyUserData?['email'] ??
                                              "@RiccardioVicidomi",
                                          style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: width * 0.01,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          studyUserData?['name'] ??
                                              "Donde se forjan las ideas",
                                          style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: width * 0.01)),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                            //if (isHideJoinButton == false)
                            if (myId != studyData?['userId'])
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      try {
                                        if ((isFollowed == false)) {
                                          FirebaseFirestore.instance
                                              .collection("Studies")
                                              .doc(postId)
                                              .update({
                                            "joinedUsers":
                                                FieldValue.arrayUnion([myId])
                                          });
                                        } else {
                                          FirebaseFirestore.instance
                                              .collection("Studies")
                                              .doc(postId)
                                              .update({
                                            "joinedUsers":
                                                FieldValue.arrayRemove([myId])
                                          });
                                        }
                                        setState(() {});
                                        // setState(() {});
                                      } catch (error) {
                                        print(
                                            "Error retrieving user status data: $error");
                                      }
                                    },
                                    child: Container(
                                      width: width * 0.07,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: buttonColor,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          )),
                                      child: Center(
                                          child: Text(
                                        (isFollowed == false)
                                            ? "Join Us"
                                            : "Left",
                                        style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: width * 0.009)),
                                      )),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                ],
                              )
                          ]),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(studyData?['Study Name'] ?? " Study Name",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width * 0.01,
                                fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                              children:
                                  List.generate(chaptersList.length, (index) {
                            var chapter = chaptersList[index];
                            var data = chapter.chapterDetail;
                            var icon = (data['videoUrl'] != "")
                                ? "assets/preview.png"
                                : "assets/group.png";
                            selectedIndex = index;

                            return GestureDetector(
                              onTap: () {
                                isVideoTutorial = false;

                                if (data['videoUrl'] != "") {
                                  isVideoTutorial = true;
                                }
                                for (var i in chaptersList) {
                                  i.isSelected = false;
                                }
                                chapterId = "";
                                chapterId = chaptersList[index].chapterId;
                                chapter.isSelected = true;

                                singleChapter = chapter;
                                fetchComments(chapterId);
                                setState(() {});
                              },
                              child: Column(
                                children: [
                                  userStudiesItem(icon, data['chapterName'],
                                      "Preview", chapter.isSelected),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (index < 9)
                                    const Divider(
                                      height: 1,
                                    )
                                ],
                              ),
                            );
                          })),
                        ),
                      ),
                    ]),
              ),
              if (!isVideoTutorial)
                Expanded(child: textStudiesDetailcontainer(singleChapter)),
              if (isVideoTutorial)
                Expanded(
                  child: videoStudiesDetailcontainer(singleChapter),
                )
            ],
          ))
        ],
      ),
    );
  }

  Widget userStudiesItem(
      String icon, String title, String buttonTitle, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                icon,
                width: 15,
                height: 15,
                color: (isSelected == true) ? buttonColor : Colors.black,
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: width * 0.26,
                child: Text(title,
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: (isSelected == true)
                                ? buttonColor
                                : Colors.black,
                            fontSize: 10))),
              )
            ],
          ),
          Container(
            width: 3,
            height: isSelected == true ? 40 : 10,
            color: (isSelected == true) ? buttonColor : Colors.transparent,
          )
        ],
      ),
    );
  }

  Widget textStudiesDetailcontainer(ChaptersModel? data) {
    DateTime postDateTime =
        DateTime.fromMillisecondsSinceEpoch(data?.chapterDetail['timeStamp']);
    formattedTime = DateFormat.jm().format(postDateTime);
    formattedDate = DateFormat('MMM dd, y').format(postDateTime);
    setState(() {});
    return Container(
      padding: const EdgeInsets.all(20),
      height: height - 100,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (touchmatchMedia == false || isMobile == false)
                HtmlWidget(
                  data?.chapterDetail['chapterDetail'].toString() ?? "",
                  customWidgetBuilder: (element) {
                    if (element.localName == 'iframe') {
                      var src = element.attributes['src']!;
                      final videoId = src.split('/').last;
                      y_tplus.YoutubePlayerController? controller;

                      controller = y_tplus.YoutubePlayerController(
                        initialVideoId: videoId,
                        params: const y_tplus.YoutubePlayerParams(
                          showControls: true,
                          mute: false,
                          showFullscreenButton: true,
                          loop: false,
                          strictRelatedVideos: true,
                          color: 'white',
                        ),
                      );
                      controller.load(src);

                      return Container(
                        width: width * 0.5,
                        height: height * 0.6,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black),
                        padding: const EdgeInsets.all(20),
                        child: VisibilityDetector(
                          key: Key(videoId),
                          onVisibilityChanged: (visibilityInfo) {
                            if (visibilityInfo.visibleFraction <= 0) {
                              controller!.pause();
                              setState(() {});
                            }
                          },
                          child: y_tplus.YoutubePlayerIFramePlus(
                            controller: controller,
                            aspectRatio: 16 / 9,
                          ),
                        ),
                      );
                    }
                    return null; // Use default widget builder for other elements
                  },
                ),
              if (touchmatchMedia == true || isMobile == true)
                htmlEditorControllerWidget(
                    data?.chapterDetail['chapterDetail'] ?? ""),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    formattedTime,
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: width * 0.01,
                            fontWeight: FontWeight.normal)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: width * 0.01,
                            fontWeight: FontWeight.normal)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "1000 Views",
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.01,
                            fontWeight: FontWeight.normal)),
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              FeedbackContainer(
                commentCount: "${commentList.length}",
              ),
              const SizedBox(
                height: 16,
              ),
              postAReply(),
              const SizedBox(
                height: 16,
              ),
              Column(
                children: List.generate(commentList.length, (index) {
                  var data = commentList[index];
                  // return Container();
                  return CommentContainer(
                    comment: data,
                    commentcount: "${10}",
                  );
                }),
              )
            ]),
      ),
    );
  }

  Widget videoStudiesDetailcontainer(ChaptersModel? data) {
    DateTime postDateTime =
        DateTime.fromMillisecondsSinceEpoch(data?.chapterDetail['timeStamp']);
    formattedTime = DateFormat.jm().format(postDateTime);
    formattedDate = DateFormat('MMM dd, y').format(postDateTime);
    setState(() {});
    var videoUrl = "";
    videoUrl = data?.chapterDetail['videoUrl'] ?? "";
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (touchmatchMedia == false || isMobile == false)
            if (touchmatchMedia == false || isMobile == false)
              HtmlWidget(
                data?.chapterDetail['chapterDetail'].toString() ?? "",
                customWidgetBuilder: (element) {
                  if (element.localName == 'iframe') {
                    var src = element.attributes['src']!;
                    final videoId = src.split('/').last;
                    y_tplus.YoutubePlayerController? controller;

                    controller = y_tplus.YoutubePlayerController(
                      initialVideoId: videoId,
                      params: const y_tplus.YoutubePlayerParams(
                        showControls: true,
                        mute: false,
                        showFullscreenButton: true,
                        loop: false,
                        strictRelatedVideos: true,
                        color: 'white',
                      ),
                    );
                    controller.load(src);

                    return Container(
                      width: width * 0.5,
                      height: height * 0.6,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black),
                      padding: const EdgeInsets.all(20),
                      child: VisibilityDetector(
                        key: Key(videoId),
                        onVisibilityChanged: (visibilityInfo) {
                          if (visibilityInfo.visibleFraction <= 0) {
                            controller!.pause();
                            setState(() {});
                          }
                        },
                        child: y_tplus.YoutubePlayerIFramePlus(
                          controller: controller,
                          aspectRatio: 16 / 9,
                        ),
                      ),
                    );
                  }
                  return null; // Use default widget builder for other elements
                },
              ),
          if (touchmatchMedia == true || isMobile == true)
            htmlEditorControllerWidget(
                data?.chapterDetail['chapterDetail'] ?? ""),
          const SizedBox(
            height: 10,
          ),

          Container(
            height: isMobile ? 200 : 300,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            //width: (isMobile == true) ? 200 : 300,
            child: StudyVideoPlayerWidget(
              key: Key('video_$videoUrl'),
              videoUrl: videoUrl,
            ),
          ),
          //Image.asset("assets/videoTo.png"),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                formattedDate,
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: width * 0.01,
                        fontWeight: FontWeight.normal)),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                formattedTime,
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: width * 0.01,
                        fontWeight: FontWeight.normal)),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "1000 Views",
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: width * 0.01,
                        fontWeight: FontWeight.normal)),
              )
            ],
          ),
          FeedbackContainer(
            commentCount: "${commentList.length}",
          ),
          postAReply(),
          Column(
            children: List.generate(commentList.length, (index) {
              var data = commentList[index];
              // return Container();
              return CommentContainer(
                comment: data,
                commentcount: "${10}",
              );
            }),
          )
        ]),
      ),
    );
  }

  Widget htmlEditorControllerWidget(html) {
    final QuillEditorController htmlController = QuillEditorController();
    setState(() {});
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 250,
      child: QuillHtmlEditor(
        text: html,
        controller: htmlController,
        hintTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontFamily: "Lato",
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
        ),
        minHeight: 250,
        isEnabled: false,
        autoFocus: false,
        textStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontFamily: "Lato",
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget postAReply() {
    return SizedBox(
      child: Column(children: [
        Container(
          height: 0.8,
          color: const Color.fromRGBO(232, 232, 232, 1),
        ),
        const SizedBox(
          height: 16,
        ),
        SizedBox(
            child: Row(
          children: [
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
                width: width * 0.04,
                height: width * 0.04,
              ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: SizedBox(
                width: width * 0.6,
                child: TextField(
                  minLines: 1,
                  maxLines: 5,
                  controller: commentTextController,
                  decoration: InputDecoration(
                      hintText: "Write something here..",
                      hintStyle: GoogleFonts.lato(
                          textStyle: TextStyle(fontSize: width * 0.01)),
                      border: InputBorder.none),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (commentTextController.text != "") {
                  var commentCount = "0";
                  if (studyData?['commentCount'] != null) {
                    commentCount = studyData?['commentCount'] ?? "0";
                  }

                  postAComment(
                      chapterId, commentTextController.text, commentCount);
                }
              },
              child: Container(
                  width: 74,
                  height: 40,
                  margin:
                      const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: postColor),
                  child: Center(
                    child: Text("Reply",
                        style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.01,
                                fontWeight: FontWeight.bold))),
                  )),
            )
          ],
        )),
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
      ]),
    );
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
        userData = userInfo.data();
        myId = userInfo.data()?['userId'];
        //   fetchStudiesList();

        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> getStudyUserData(String studyUserId) async {
    if (studyUserId != "") {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(studyUserId)
          .snapshots()
          .listen((userInfo) {
        userProfileImageUrl = userInfo.data()?['imageUrl'];
        studyUserData = userInfo.data();

        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> fetchJoinedUserList() async {
    if (postId != "") {
      firebaseFirestore
          .collection("Studies")
          .doc(postId)
          .snapshots()
          .listen((studyInfo) {
        var data = studyInfo.data();
        studyData = data;
        joinedUsers = List.from(data?["joinedUsers"] ?? []);
        getStudyUserData(data?['userId'] ?? "");
        isFollowed = studyInfo['joinedUsers'].toList().contains(myId);
        if (mounted) {
          setState(() {});
        }
      }).onError((onError) {
        print(onError);
      });
    }
  }

  Future<void> fetchChapterList() async {
    if (postId != "") {
      firebaseFirestore
          .collection("Studies")
          .doc(postId)
          .collection("Chapters")
          .snapshots()
          .listen((chapters) {
        chaptersList.clear();
        for (DocumentSnapshot doc in chapters.docs) {
          var data = doc.data() as Map<String, dynamic>;
          var chapterDetail = ChaptersModel(
              chapterDetail: data,
              chapterId: data['chapterId'].toString(),
              isSelected: false);
          chaptersList.add(chapterDetail);
        }
        chaptersList[studySelectedIndex].isSelected = true;
        singleChapter = chaptersList[studySelectedIndex];
        chapterId = singleChapter!.chapterId;
        fetchComments(singleChapter!.chapterId);
        if (singleChapter?.chapterDetail['videoUrl'] != "") {
          isVideoTutorial = true;
        } else {
          isVideoTutorial = false;
        }
        chapterDetail = singleChapter!.chapterDetail;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> fetchComments(String chapterId) async {
    commentList.clear();
    firebaseFirestore
        .collection("Studies")
        .doc(postId)
        .collection("Comments")
        .where("chapterId", isEqualTo: chapterId)
        .snapshots()
        .listen((commentSnapShot) {
      commentList.clear();
      for (DocumentSnapshot doc in commentSnapShot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        commentList.add(data);
      }
      if (mounted) {
        setState(() {});
      }
    }).onError((onError) {
      print(onError);
    });
  }

  Future<void> postAComment(chapterID, comment, String commentCount) async {
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    var commentData = {
      "chapterId": chapterID,
      "studyId": postId,
      "timeStamp": timeStamp,
      "commentId": timeStamp,
      "comment": comment,
      "user": userData
    };
    var commentCountInt = int.parse(commentCount);
    var commentResult = commentCountInt + 1;
    var commentcount = "$commentResult";

    firebaseFirestore
        .collection("Studies")
        .doc(postId)
        .collection("Comments")
        .doc(timeStamp.toString())
        .set(commentData)
        .then((value) {
      commentTextController.text = "";
      firebaseFirestore
          .collection("Studies")
          .doc(postId)
          .update({"commentCount": commentcount});
      setState(() {});
      print("Success");
    }).catchError((error) {
      print(error);
    });
  }

  // Future<void> fetchStudiesList() async {
  //   if (postId != "") {
  //     firebaseFirestore
  //         .collection("Studies")
  //         .doc(postId)
  //         .snapshots()
  //         .listen((studyInfo) {
  //       var data = studyInfo.data();
  //       studyUserData = data?['user'];
  //       chaptersList.clear();
  //       firebaseFirestore
  //           .collection("Studies")
  //           .doc(postId)
  //           .collection("Chapters")
  //           .snapshots()
  //           .listen((chapters) {
  //         chaptersList.clear();
  //         for (DocumentSnapshot doc in chapters.docs) {
  //           var data = doc.data() as Map<String, dynamic>;
  //           var chapterDetail = ChaptersModel(
  //               chapterDetail: data,
  //               chapterId: data['chapterId'].toString(),
  //               isSelected: false);
  //           chaptersList.add(chapterDetail);
  //         }
  //         var study = {
  //           "studyName": data?["Study Name"] ?? "Wonderfull Study",
  //           "studyId": data?["studyId"] ?? "1234567890",
  //           "joinedUsers": data?['joinedUsers'] ?? [],
  //           "chapterList": chapterList,
  //           "commentCount": data?['commentCount'] ?? "0",
  //           "user": data?['user'] ?? {}
  //         };
  //         if (chaptersList.isNotEmpty && isFirstLoad) {
  //           // Set the flag to false after the first load
  //           chaptersList[0].isSelected = true;
  //           singleChapter = chaptersList[0];
  //           isFirstLoad = false;
  //         }

  //         studyData = study;
  //         if (singleChapter?.chapterDetail['videoUrl'] != "") {
  //           isVideoTutorial = true;
  //         } else {
  //           isVideoTutorial = false;
  //         }
  //         //studiesList.add(study);
  //         if (mounted) {
  //           setState(() {});
  //         }
  //       });
  //     }).onError((onError) {
  //       print("onError $onError");
  //     });
  //   }
  //   if (chaptersList.isNotEmpty) {
  //     chaptersList[selectedIndex].isSelected = true;
  //     singleChapter = chaptersList[selectedIndex];
  //     isFirstLoad = false;
  //   } else {
  //     print("chaptersList.length ${chaptersList.length}");
  //   }
  // }
}

class StudyVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final Key key;
  const StudyVideoPlayerWidget({required this.key, required this.videoUrl})
      : super(key: key);

  @override
  State<StudyVideoPlayerWidget> createState() => _StudyVideoPlayerWidgetState();
}

class _StudyVideoPlayerWidgetState extends State<StudyVideoPlayerWidget> {
  final _meeduPlayerController = MeeduPlayerController(
    controlsStyle: ControlsStyle.primary,
    initialFit: BoxFit.fitHeight,
    customIcons: const CustomIcons(
      play: Icon(Icons.play_circle, color: Colors.white),
      pause: Icon(Icons.pause_circle, color: Colors.white),
    ),
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  void _init() {
    _meeduPlayerController
        .setDataSource(
      DataSource(
        type: DataSourceType.network,
        source: widget.videoUrl,
      ),
      autoplay: false,
      looping: false,
    )
        .catchError((onError) {
      print(
          "Error occurred while playing video in _meeduPlayerController $onError");
    });
    _meeduPlayerController.videoPlayerController!.addListener(() {
      if (isPlaying) {
        _meeduPlayerController.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction <= 0.5) {
          _meeduPlayerController.pause();
          if (mounted) {
            setState(() {});
          }
        } else {
          if (isPlaying) {
            _meeduPlayerController.pause();
          } else {
            _meeduPlayerController.play();
          }
          if (mounted) {
            setState(() {});
          }
        }
      },
      child: SizedBox(
        child: Stack(
          children: [
            MeeduVideoPlayer(
              controller: _meeduPlayerController,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _meeduPlayerController.dispose();
    super.dispose();
  }
}

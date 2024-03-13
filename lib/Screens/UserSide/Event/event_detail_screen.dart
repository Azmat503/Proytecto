import 'package:flutter/material.dart';
import 'package:proyecto/Screens/UserSide/Article/create_article_screen.dart';
import 'package:proyecto/Screens/UserSide/Studies/studies_detail_screen.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/Views/comment_container.dart';
import 'package:proyecto/Views/feedback_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_iframe_plus/youtube_player_iframe_plus.dart'
    as y_tplus;

class EventDetailScreen extends StatefulWidget {
  final Function onBackPressed;
  const EventDetailScreen({super.key, required this.onBackPressed});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  TextEditingController searchTextController = TextEditingController();
  TextEditingController commentEditingController = TextEditingController();

  Map<String, dynamic>? singleEvent;
  Map<String, dynamic>? userData;
  late Stream<List<Map<String, dynamic>>> commentList;
  List<String> eventImages = [];
  String imageUrl = "";
  String name = "";
  String formattedTime = "";
  String formattedDate = "";
  String userId = "";
  String postedUserimageUrl = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  var commentCount;
  var videoUrl = "";
  y_tplus.YoutubePlayerController? controller;
  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    if (mounted) {
      fetchsingleEvent();
      fetchUserDetail();
      commentList = fetchAllComment();
      commentCount = commentList.listen((List<Map<String, dynamic>> data) {
        data.length.toString();
      });
      updateViews(singleEvent?['views'] ?? 1);
    }
  }

  @override
  void dispose() {
    super.dispose();
    commentCount = 0;
    singleEvent = null;
    userData = null;
  }

  void fetchsingleEvent() async {
    fetchsingleEventDetail(postId);
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: homeProfileContainer());
  }

  Widget homeProfileContainer() {
    return Column(
      children: [
        Container(
          width: width,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 20),
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
                            Text("Event Detail Page",
                                style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        fontSize: width * 0.009,
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
                )
              ]),
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(left: 40, right: 40),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (singleEvent?['postDetail'] != "")
                SizedBox(
                  width: double.infinity,
                  height: height * 0.6,
                  child: EventYoutubeVideoPlayer(
                    videoUrl: videoUrl,
                    controller: controller!,
                    index: 0,
                    videoPressed: (value) {},
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: SizedBox(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                              " ${formatTimestamp(singleEvent?['timeStamp'] ?? 123456)} at  ${fetchDateFromTimeStamp(singleEvent?['timeStamp'] ?? 123456)}",
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: width * 0.008,
                                    fontWeight: FontWeight.w600),
                              )),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "${singleEvent?['postTitle'] ?? ""} || 8th Edition",
                            style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: width * 0.01,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(singleEvent?['postTitle'] ?? "",
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 10),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 0.8,
                            color: const Color.fromRGBO(232, 232, 232, 1),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "About",
                            style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(singleEvent?['postDetail'] ?? "",
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(fontSize: width * 0.009),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(formattedTime,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: width * 0.01),
                                  )),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(formattedDate,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: width * 0.01),
                                  )),
                              const SizedBox(
                                width: 16,
                              ),
                              Text("@ ${singleEvent?['views'] ?? ""} Views",
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: width * 0.01),
                                  ))
                            ],
                          ),
                        ]),
                  )),
                  const SizedBox(
                    width: 40,
                  ),
                  SizedBox(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.asset(
                          "assets/map.png",
                          fit: BoxFit.fill,
                          height: height * 0.4,
                          width: width * 0.36,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            height: 60,
                            width: width * 0.36,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20))),
                            child: Text(
                              "\n \t The Desert Rally",
                              style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              FeedbackContainer(
                commentCount: "${singleEvent?['commentCount'] ?? ''}",
              ),
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
              SizedBox(
                  child: Row(
                children: [
                  imageUrl != ""
                      ? CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: width * 0.02,
                          backgroundImage: Image.network(imageUrl).image,
                        )
                      : Image.asset(
                          "assets/person.png",
                          fit: BoxFit.contain,
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
                        controller: commentEditingController,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                            hintText: "Post your reply..",
                            hintStyle: GoogleFonts.lato(
                                textStyle: TextStyle(fontSize: width * 0.01)),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      postComment(postId, userData,
                          commentEditingController.text, userId, singleEvent);
                      commentEditingController.text = "";
                    },
                    child: Container(
                      width: 74,
                      height: 40,
                      margin: const EdgeInsets.only(
                          bottom: 20, right: 20, left: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: postColor),
                      child: Center(
                          child: Text("Reply",
                              style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * 0.01,
                                      fontWeight: FontWeight.bold)))),
                    ),
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
              commentsContainer()
            ]),
          ),
        ))
      ],
    );
  }

  Widget commentsContainer() {
    return SizedBox(
      child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: commentList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            List<Map<String, dynamic>> commentList = snapshot.data ?? [];
            if (commentList.isEmpty) {
              return const Center(child: Text('No Comment Yet!'));
            } else {
              return ListView.builder(
                  itemCount: commentList.length,
                  primary: false,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var singleComment = commentList[index];
                    return CommentContainer(
                      comment: singleComment,
                    );
                  });
            }
          }),
    );
  }

  String getVideoIdFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String? videoId = uri.pathSegments.last;
    return videoId;
  }

  void fetchsingleEventDetail(postid) {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postid)
        .snapshots()
        .listen((data) {
      // setState(() {
      singleEvent = data.data();
      videoUrl = data.data()?['postDetail'] ?? "";
      setState(() {});
      postedUserimageUrl = data.data()?['user']['imageUrl'];
      eventImages = List<String>.from(data.data()?['imagesUrl'] ?? []);
      DateTime postDateTime =
          DateTime.fromMillisecondsSinceEpoch(data.data()?['timeStamp']);
      formattedTime = DateFormat.jm().format(postDateTime);
      formattedDate = DateFormat('MMM dd, y').format(postDateTime);
      var videoId = getVideoIdFromUrl(videoUrl);

      if (data['postDetail'].contains("si")) {
        videoId = getVideoIdFromUrl(videoUrl);
      } else {
        videoId =
            y_tplus.YoutubePlayerController.convertUrlToId(data['postDetail'])!;
      }

      if (data['postDetail'].contains('si')) {
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
        controller!.load(videoId);
      } else {
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
        controller!.load(videoUrl);
      }
      if (mounted) {
        setState(() {});
      }

      //  });
    });
  }

  Future<void> fetchUserDetail() async {
    if (user != null) {
      var userID = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userID.toString())
          .snapshots()
          .listen((userInfo) {
        //setState(() {
        userData = userInfo.data();
        imageUrl = userInfo.data()!["imageUrl"];
        userId = userInfo.data()!["userId"];
        // });
        if (mounted) {
          fetchUserDetail();
          setState(() {});
        }
      });
    }
  }

  Stream<List<Map<String, dynamic>>> fetchAllComment() {
    return FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection("Comments")
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .map(
      (QuerySnapshot<Map<String, dynamic>> allPostSnapshot) {
        return allPostSnapshot.docs.map((doc) => doc.data()).toList();
      },
    );
  }

  void updateViews(int views) {
    if (mounted) {
      FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .update({"views": views + 1})
          .then((value) => null)
          .catchError((e) {});
    }
  }

  Future<void> postComment(postId, userData, comment, userId, post) async {
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection("Comments")
        .doc(timeStamp.toString())
        .set({
      "user": userData,
      "comment": comment,
      "userId": userId,
      "timeStamp": timeStamp,
      "commentId": timeStamp.toString()
    }).then((val) {
      var commentCount = post['commentCount'];
      commentCount = commentCount + 1;
      FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .update({"commentCount": commentCount});
    }).catchError((e) {
      print(e);
    });
  }
}

class EventYoutubeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final y_tplus.YoutubePlayerController controller;
  final Function(int) videoPressed;
  final int index;
  const EventYoutubeVideoPlayer(
      {super.key,
      required this.videoUrl,
      required this.controller,
      required this.videoPressed,
      required this.index});

  @override
  State<EventYoutubeVideoPlayer> createState() =>
      _EventYoutubeVideoPlayerState();
}

class _EventYoutubeVideoPlayerState extends State<EventYoutubeVideoPlayer> {
  var hideThumbnail = false;
  late y_tplus.YoutubePlayerController _controller;
  @override
  void initState() {
    super.initState();

    // _controller = YTPlus.YoutubePlayerController(
    //   initialVideoId:
    //       YTPlus.YoutubePlayerController.convertUrlToId(widget.videoUrl)!,
    //   params: const YTPlus.YoutubePlayerParams(
    //     showControls: true,
    //     mute: false,
    //     showFullscreenButton: true,
    //     loop: false,
    //     strictRelatedVideos: true,
    //     color: 'white',
    //   ),
    // );
    // _controller.load(widget.videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return youtubePlayerWidget();
  }

  Widget youtubePlayerWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.black),
      // padding: const EdgeInsets.all(20),
      child: Center(
        child: VisibilityDetector(
          key: Key(widget.videoUrl),
          onVisibilityChanged: (visibilityInfo) {
            if (visibilityInfo.visibleFraction <= 0.5) {
              hideThumbnail = false;
              widget.controller.pause();
              setState(() {});
            } else {
              widget.controller.play();
            }
          },
          child: y_tplus.YoutubePlayerIFramePlus(
            controller: widget.controller,
            aspectRatio: 16 / 9,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }
}

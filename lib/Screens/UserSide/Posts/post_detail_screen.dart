import 'package:flutter/material.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/Views/comment_container.dart';
import 'package:proyecto/Views/feedback_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDetailScreen extends StatefulWidget {
  final Function postClick;
  const PostDetailScreen({super.key, required this.postClick});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  TextEditingController searchTextController = TextEditingController();
  TextEditingController commentEditingController = TextEditingController();

  Map<String, dynamic>? singlePost;
  Map<String, dynamic>? userData;
  late Stream<List<Map<String, dynamic>>> commentList;
  String name = "";
  String imageUrl = "";
  String postedUserimageUrl = "";
  String formattedTime = "";
  String formattedDate = "";
  String userId = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  var commentCount;
  bool isPostButtonEnable = false;
  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    fetchSinglePost();
    fetchUserDetail();
    commentList = fetchAllComment();
    commentCount = commentList.listen((List<Map<String, dynamic>> data) {
      data.length.toString();
    });
    updateViews(singlePost?['views'] ?? 1);
  }

  void fetchSinglePost() async {
    fetchSinglePostDetail(postId);
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
          padding: const EdgeInsets.only(
            left: 20,
            bottom: 20,
            top: 20,
          ),
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
                                widget.postClick();
                              },
                              child: Image.asset(
                                "assets/back.png",
                                width: 15,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Text("Post",
                                style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                        fontSize: 14,
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
                        textStyle: const TextStyle(fontSize: 12)),
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
            child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(left: 40, right: 40),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                postedUserimageUrl != ""
                    ? CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: width * 0.02,
                        backgroundImage:
                            Image.network(postedUserimageUrl).image,
                      )
                    : Image.asset(
                        "assets/person.png",
                        fit: BoxFit.contain,
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
                      singlePost?['user']['name'].toString() ?? "",
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(singlePost?['user']['email'].toString() ?? "",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              color: Color.fromRGBO(181, 181, 181, 1),
                              fontSize: 12,
                              fontWeight: FontWeight.w300),
                        )),
                  ],
                ),
              ]),
              const SizedBox(
                height: 10,
              ),
              Text(
                singlePost?['postDetail'].toString() ?? "",
                style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                )),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(formattedTime,
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal),
                      )),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    )),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    "${singlePost?['views'].toString() ?? ""} Views",
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    )),
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                  stream: commentList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    List<Map<String, dynamic>> commentList =
                        snapshot.data ?? [];
                    commentCount = commentList.length;

                    return FeedbackContainer(
                      commentCount: "$commentCount",
                    );
                  }),
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
                        minLines: 1,
                        maxLines: 5,
                        controller: commentEditingController,
                        decoration: InputDecoration(
                            hintText: "Post Your Reply..",
                            hintStyle: GoogleFonts.lato(
                                textStyle: TextStyle(
                              fontSize: width * 0.01,
                              fontFamily: "Lato",
                            )),
                            border: InputBorder.none),
                        onChanged: (value) {
                          isPostButtonEnable =
                              commentEditingController.text.isNotEmpty;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (commentEditingController.text.isNotEmpty) {
                        postComment(postId, userData,
                            commentEditingController.text, userId, singlePost);
                        commentEditingController.text = "";
                      }
                    },
                    child: Container(
                      width: 74,
                      height: 40,
                      margin: const EdgeInsets.only(
                          bottom: 20, right: 20, left: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isPostButtonEnable ? buttonColor : postColor),
                      child: const Center(child: Text("Reply")),
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
              SizedBox(
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

                      List<Map<String, dynamic>> commentList =
                          snapshot.data ?? [];
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
              )
            ]),
          ),
        ))
      ],
    );
  }

  void fetchSinglePostDetail(postid) {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postid)
        .snapshots()
        .listen((data) {
      setState(() {
        singlePost = data.data();
        postedUserimageUrl = data.data()?['user']['imageUrl'];
        DateTime postDateTime =
            DateTime.fromMillisecondsSinceEpoch(data.data()?['timeStamp']);
        formattedTime = DateFormat.jm().format(postDateTime);
        formattedDate = DateFormat('MMM dd, y').format(postDateTime);
      });
    });
  }

  Future<void> fetchUserDetail() async {
    if (user != null) {
      var userId = user!.uid;
      userId = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId.toString())
          .snapshots()
          .listen((userInfo) {
        setState(() {
          userData = userInfo.data();
          imageUrl = userInfo.data()!["imageUrl"];
        });
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
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .update({"views": views + 1})
        .then((value) => null)
        .catchError((e) {});
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

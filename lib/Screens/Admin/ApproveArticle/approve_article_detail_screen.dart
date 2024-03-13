import 'package:flutter/material.dart';
//import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/Screens/UserSide/Article/article_detail_screen.dart';
import 'package:proyecto/Views/comment_container.dart';
import 'package:proyecto/Views/feedback_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/foundation.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'dart:html' as html;

class ApproveArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? singlePost;
  const ApproveArticleDetailScreen({super.key, required this.singlePost});

  @override
  State<ApproveArticleDetailScreen> createState() =>
      _ApproveArticleDetailScreenState();
}

class _ApproveArticleDetailScreenState
    extends State<ApproveArticleDetailScreen> {
  TextEditingController searchTextController = TextEditingController();
  TextEditingController commentEditingController = TextEditingController();
  final QuillEditorController htmlController = QuillEditorController();

  Map<String, dynamic>? singlePost;
  Map<String, dynamic>? userData;
  late Stream<List<Map<String, dynamic>>> commentList;
  String imageUrl = "";
  String name = "";
  String formattedTime = "";
  String formattedDate = "";
  String userId = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String postedUserimageUrl = "";
  var commentCount;
  var isMobile = false;
  late AnimationController _animationController;
  late PageController pageController = PageController();
  var hideButton = true;
  var categoryId = "";
  List<String> articleImages = [];
  @override
  void initState() {
    super.initState();
    categoryId = widget.singlePost?['categoryId'] ?? "";
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }

    user = auth.currentUser;
    if (mounted) {
      fetchSinglePost();
      //   fetchUserDetail();
      commentList = fetchAllComment();
      commentCount = commentList.listen((List<Map<String, dynamic>> data) {
        data.length.toString();
      });
      updateViews(singlePost?['views'] ?? 1);
    }
  }

  @override
  void dispose() {
    super.dispose();
    commentCount = 0;
    singlePost = null;
    userData = null;
    _animationController.dispose();
  }

  void fetchSinglePost() async {
    fetchSinglePostDetail(postId);
    if (mounted) {
      setState(() {});
    }
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
                                Navigator.pop(context);
                                //   selectedIndex = previousSelectedIndex;
                                //   widget.postClick();
                              },
                              child: Image.asset(
                                "assets/back.png",
                                width: 15,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              "Article Detail Page",
                              style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            )
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
              ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArticleTopicListViewContainer(
              categoryId: categoryId,
              onTopicSelected: onTopicSelected,
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(left: 40, right: 40),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Row(children: [
                                postedUserimageUrl != ""
                                    ? CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        radius: width * 0.02,
                                        backgroundImage:
                                            Image.network(postedUserimageUrl)
                                                .image,
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
                                      singlePost?['user']['name'].toString() ??
                                          "",
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
                                        singlePost?['user']['email']
                                                .toString() ??
                                            "",
                                        style: GoogleFonts.lato(
                                          textStyle: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        )),
                                  ],
                                ),
                              ]),
                            ),
                            if (singlePost?["status"] == "pending")
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (categoryId != "") {
                                        firebaseFirestore
                                            .collection("Posts")
                                            .doc(postId)
                                            .update({
                                          "categoryId": categoryId,
                                          "status": "approved"
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 20, right: 20),
                                      padding: const EdgeInsets.only(
                                          bottom: 10,
                                          right: 20,
                                          top: 10,
                                          left: 20),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              width: 1, color: buttonColor),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          )),
                                      child: Center(
                                          child: Text(
                                        "Accept",
                                        style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: buttonColor,
                                                fontSize: 10)),
                                      )),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (categoryId != "") {
                                        firebaseFirestore
                                            .collection("Posts")
                                            .doc(postId)
                                            .update({
                                          "categoryId": categoryId,
                                          "status": "reject"
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 20, right: 20),
                                      padding: const EdgeInsets.only(
                                          bottom: 10,
                                          right: 20,
                                          top: 10,
                                          left: 20),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              width: 1, color: buttonColor),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          )),
                                      child: Center(
                                          child: Text(
                                        "Reject",
                                        style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: buttonColor,
                                                fontSize: 10)),
                                      )),
                                    ),
                                  ),
                                ],
                              )
                          ]),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (isMobile == false && touchmatchMedia == false)
                        Html(
                          data: singlePost?['postDetail'].toString() ?? "",
                          style: {
                            'h1': Style(
                              padding: HtmlPaddings.all(0),
                              margin: Margins.zero,
                            ),
                            'h2': Style(
                              padding: HtmlPaddings.all(0),
                              margin: Margins.zero,
                            ),
                            "p": Style(
                              padding: HtmlPaddings.all(0),
                              margin: Margins.zero,
                            )
                          },
                          onLinkTap: (url, attributes, element) {
                            html.window.open(url!, "name");
                          },
                        ),
                      if (touchmatchMedia == true || isMobile == true)
                        htmlEditorControllerWidget(singlePost?['postDetail']),
                      if (articleImages.isNotEmpty)
                        Center(
                            child: CustomCarosalSlider(images: articleImages)),
                      Row(
                        children: [
                          Text(
                            formattedTime,
                            style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            formattedDate,
                            style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Text("${singlePost?['views'].toString() ?? ""} Views",
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      StreamBuilder<List<Map<String, dynamic>>>(
                          stream: commentList,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                  backgroundImage:
                                      Image.network(imageUrl).image,
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
                                    hintText: "Write something here..",
                                    hintStyle: GoogleFonts.lato(
                                      textStyle:
                                          TextStyle(fontSize: width * 0.01),
                                    ),
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              postComment(
                                  postId,
                                  userData,
                                  commentEditingController.text,
                                  userId,
                                  singlePost);
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
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                                return const Center(
                                    child: Text('No Comment Yet!'));
                              } else {
                                return ListView.builder(
                                    itemCount: commentList.length,
                                    primary: false,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
            )),
          ],
        )
      ],
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

  void fetchSinglePostDetail(postid) {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postid)
        .snapshots()
        .listen((data) {
      // setState(() {

      singlePost = data.data();
      articleImages =
          (singlePost?['imagesUrl'] as List<dynamic>).cast<String>().toList();
      categoryId = singlePost?['categoryId'] ?? "";
      postedUserimageUrl = data.data()?['user']['imageUrl'];

      if (mounted) {
        DateTime postDateTime =
            DateTime.fromMillisecondsSinceEpoch(data.data()?['timeStamp']);
        formattedTime = DateFormat.jm().format(postDateTime);
        formattedDate = DateFormat('MMM dd, y').format(postDateTime);
        setState(() {});
      }
    });
  }

  void onTopicSelected(String topic) {
    print("before categoryId $categoryId ");
    if (mounted) {
      setState(() {
        categoryId = topic;
        print(
            "before categoryId $categoryId after $categoryId  and topic $topic");
      });
    }
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
        userData = userInfo.data();
        imageUrl = userInfo.data()!["imageUrl"];
        if (mounted) {
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
      //
    });
  }
}

class ArticleTopicListViewContainer extends StatefulWidget {
  final String categoryId;
  final Function(String) onTopicSelected;

  const ArticleTopicListViewContainer(
      {super.key, required this.onTopicSelected, required this.categoryId});

  @override
  State<ArticleTopicListViewContainer> createState() =>
      _ArticleTopicListViewContainerState();
}

class _ArticleTopicListViewContainerState
    extends State<ArticleTopicListViewContainer> {
  bool isHovered = false;
  var isTopicSideBarHide = false;
  final firebaseFirestore = FirebaseFirestore.instance;
  List<CategoryModel> articleCategories = [];

  @override
  void initState() {
    super.initState();
    getCategoriesList();
  }

  @override
  Widget build(BuildContext context) {
    return topicListviewWidget();
  }

  Widget topicListviewWidget() {
    return Container(
      width: isTopicSideBarHide ? 40 : 175,
      height: height - 100,
      padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
      decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(width: 4, color: Colors.black.withOpacity(0.2))),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                isTopicSideBarHide = !isTopicSideBarHide;
                setState(() {});
              },
              child: Icon(
                isTopicSideBarHide ? Icons.chevron_right : Icons.arrow_back_ios,
                size: isTopicSideBarHide ? 20 : 15.0,
                color: Colors.white,
              ),
            ),
          ),
          if (!isTopicSideBarHide)
            Text(
              "Select Topic",
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    decoration: TextDecoration.none),
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          if (!isTopicSideBarHide)
            Expanded(
              child: ListView.builder(
                itemCount: articleCategories.length,
                itemBuilder: ((context, index) {
                  var data = articleCategories[index];
                  return MouseRegion(
                    child: GestureDetector(
                      onTap: () {
                        for (var i in articleCategories) {
                          i.isSelected = false;
                        }
                        data.isSelected = true;
                        widget.onTopicSelected(data.catId);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          data.catName,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: (data.isHover || data.isSelected)
                                    ? buttonColor
                                    : Colors.white,
                                fontSize:
                                    (data.isHover || data.isSelected) ? 16 : 14,
                                decoration: TextDecoration.none
                                //fontStyle: GoogleFonts.lato().fontStyle),
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            )
        ],
      ),
    );
  }

  Future<void> getCategoriesList() async {
    firebaseFirestore
        .collection("ArticleCategory")
        .limit(20)
        .snapshots()
        .listen((allPostSnapshot) {
      articleCategories.clear();
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        var model = CategoryModel(
            catId: post['categoryId'],
            catName: post['categoryName'],
            isSelected:
                (widget.categoryId == post['categoryId'] ? true : false));
        articleCategories.add(model);
      }
    });
  }
}

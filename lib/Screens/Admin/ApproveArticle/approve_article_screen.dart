import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/Screens/Admin/ApproveArticle/approve_article_detail_screen.dart';
import 'package:proyecto/Screens/UserSide/Article/article_screen.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:html' as html;

class ApproveArticleScreen extends StatefulWidget {
  const ApproveArticleScreen({super.key});

  @override
  State<ApproveArticleScreen> createState() => _ApproveArticleScreenState();
}

class _ApproveArticleScreenState extends State<ApproveArticleScreen> {
  final QuillEditorController htmlController = QuillEditorController();
  final TextEditingController articleEditingController =
      TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic>? userData;
  var isLoading = false;
  var htmltext = "";

  final firebaseFirestore = FirebaseFirestore.instance;
  List<CategoryModel> categoriesList = [];
  var isPostButtonEnable = false;
  bool isHtmlTextShow = false;
  var isMobile = false;
  String profileImageUrl = "";
  var isWrireArticle = false;
  bool isHovered = false;
  var isTopicSideBarHide = false;
  String selectedTopic = "All";
  List<Map<String, dynamic>> _allArticles = [];
  @override
  void initState() {
    super.initState();

    // htmlController.setText('Write Some thing');
    if (foundation.defaultTargetPlatform == TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }
    user = auth.currentUser;
    touchmatchMedia = html.window.matchMedia('(pointer: coarse)').matches;
    //getUserData();
    getAllArticles();
    // if (mounted) {
    //   setState(() {});
    // }
    getCategoriesList();
  }

  Future<void> getCategoriesList() async {
    firebaseFirestore
        .collection("ArticleCategory")
        .limit(20)
        .snapshots()
        .listen((allPostSnapshot) {
      onlyCategoriesList.clear();
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        var model = CategoryModel(
            catId: post['categoryId'],
            catName: post['categoryName'],
            isSelected: false);
        categoriesList.add(model);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            homeProfileContainer(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TopicListViewContainer(
                    onTopicSelected: onTopicSelected,
                    allCategoriesList: categoriesList,
                    isTopicSideBarHide: (p0) {
                      isTopicSideBarHide = p0;
                      setState(() {});
                    },
                  ),
                  SingleChildScrollView(
                    child: SizedBox(
                      width: (isTopicSideBarHide == true)
                          ? width - 40
                          : width - 175,
                      // margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.builder(
                        itemCount:
                            (_allArticles.isNotEmpty) ? _allArticles.length : 0,
                        primary: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var data = _allArticles[index];
                          //var userId = data['userId'];
                          return readArticleListView(data);
                          // if (isMobile) {
                          //   return postContainerForMBl(data, userId);
                          // }
                          // if ((touchmatchMedia == true)) {
                          //   return postContainerForMBl(data, userId);
                          // } else if (width < 600) {
                          //   return postContainerForMBl(data, userId);
                          // } else {
                          //   return readArticleListView(data);
                          // }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget homeProfileContainer() {
    return Container(
      width: width,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(left: 20, bottom: 20, top: 20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  child: Row(children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
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
                      "Approve Article",
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ]),
                )
              ]),
            ),
          ]),
    );
  }

  Widget readArticleListView(post) {
    // var isFollowed = userData!['following'].toList().contains(post['userId']);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 0.9,
          color: Colors.black.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    selectedUserId = "";
                    selectedUserId = post['userId'];
                    //  widget.seeUserProfileClick();
                  },
                  child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: Image.network(
                        post['user']['imageUrl'],
                        width: width * 0.032,
                        height: width * 0.032,
                      ).image),
                )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(post['user']['name'].toString(),
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none),
                            )),
                        const SizedBox(
                          width: 16,
                        ),
                        Text(
                          extractUsernameFromEmail(
                              post['user']['email'].toString()),
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                decoration: TextDecoration.none),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),

                        // customTextWidget(
                        //   ,
                        //   ),
                        // )
                        Text(
                          formatTimestampAgo(
                            DateTime.fromMillisecondsSinceEpoch(
                              post['timeStamp'] ?? "",
                            ),
                          ),
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                decoration: TextDecoration.none),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    Container(
                      constraints: const BoxConstraints(maxHeight: 150.0),
                      child: Html(
                        data: post['postDetail'].toString(),
                        // extensions: [],
                        style: {
                          'h1': Style(
                              padding: HtmlPaddings.all(0),
                              margin: Margins.zero,
                              textDecoration: TextDecoration.none,
                              fontStyle: GoogleFonts.lato().fontStyle,
                              color: Colors.black,
                              fontSize: FontSize.medium),
                          'h2': Style(
                              padding: HtmlPaddings.all(0),
                              margin: Margins.zero,
                              textDecoration: TextDecoration.none,
                              fontStyle: GoogleFonts.lato().fontStyle,
                              color: Colors.black,
                              fontSize: FontSize.medium),
                          'p': Style(
                              padding: HtmlPaddings.all(0),
                              margin: Margins.zero,
                              textDecoration: TextDecoration.none,
                              fontStyle: GoogleFonts.lato().fontStyle,
                              color: Colors.black,
                              fontSize: FontSize.medium),
                          'body': Style(
                              padding: HtmlPaddings.all(0),
                              margin: Margins.zero,
                              textDecoration: TextDecoration.none,
                              fontStyle: GoogleFonts.lato().fontStyle,
                              color: Colors.black,
                              fontSize: FontSize.medium)
                        },
                        onLinkTap: (url, attributes, element) {
                          html.window.open(url!, "name");
                        },
                      ),
                    ),
                    // if (width >= 1026 && width <= 1046)
                    //   htmlEditorControllerWidget(post['postDetail']),
                    GestureDetector(
                      onTap: () {
                        postId = post['postId'];
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ApproveArticleDetailScreen(
                                      singlePost: post,
                                    )));
                        // widget.postClick();
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.only(
                            bottom: 10, right: 20, top: 10, left: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1, color: buttonColor),
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Read Article",
                            style: TextStyle(
                                color: buttonColor,
                                fontFamily: GoogleFonts.lato().fontFamily,
                                fontSize: 10,
                                decoration: TextDecoration.none),
                          ),
                        ),
                      ),
                    ),
                    feedBackContainer(post['commentCount'], post['postId'],
                        post['postType'].toString(), post)
                  ],
                ),
              ),
            ),
            //if (userData!['userId'] != post['userId'])
            if (post['status'] == "pending") followButton(post)
          ],
        ),
      ),
    );
  }

  Widget followButton(post) {
    var categoryId = post['categoryId'];
    var postId = post['postId'];
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (categoryId != "") {
              updateArticleStatus("approved", categoryId, postId);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20, right: 20),
            padding:
                const EdgeInsets.only(bottom: 10, right: 20, top: 10, left: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1, color: buttonColor),
                borderRadius: BorderRadius.circular(
                  20,
                )),
            child: Center(
                child: Text(
              "Accept",
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: buttonColor,
                      fontSize: 10,
                      decoration: TextDecoration.none)),
            )),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (categoryId != "") {
              updateArticleStatus("reject", categoryId, postId);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20, right: 20),
            padding:
                const EdgeInsets.only(bottom: 10, right: 20, top: 10, left: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1, color: buttonColor),
                borderRadius: BorderRadius.circular(
                  20,
                )),
            child: Center(
                child: Text(
              "Reject",
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: buttonColor,
                      fontSize: 10,
                      decoration: TextDecoration.none)),
            )),
          ),
        ),
      ],
    );
  }

  Future<void> updateArticleStatus(
      String status, String categoryId, postId) async {
    firebaseFirestore
        .collection("Posts")
        .doc(postId)
        .update({"categoryId": categoryId, "status": status});
  }

  Future<void> getUserData() async {
    if (user != null) {
      var userId = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId.toString())
          .snapshots()
          .listen((userInfo) {
        setState(() {
          userData = userInfo.data();
        });
      });
    }
  }

  Future<void> getAllArticles() async {
    firebaseFirestore
        .collection('Posts')
        .where("postType", isEqualTo: "article")
        .snapshots()
        .listen((allPostSnapshot) {
      _allArticles.clear();
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        _allArticles.add(post);
        if (mounted) {
          setState(() {});
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onTopicSelected(String topic) {
    if (topic == "0") {
      getAllArticles();
    } else {
      selectedTopic = topic;
      if (mounted) {
        setState(() {});
      }
      getFilteredArticles(selectedTopic);
    }
  }

  Future<void> getFilteredArticles(articleCategory) async {
    firebaseFirestore
        .collection('Posts')
        .where("postType", isEqualTo: "article")
        .where("categoryId", isEqualTo: articleCategory)
        .snapshots()
        .listen((QuerySnapshot allPostSnapshot) {
      _allArticles.clear();
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        _allArticles.add(post);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget postContainerForMBl(post, userId) {
    // var isFollowed = userData!['following'].toList().contains(post['userId']);
    return Container(
      width: double.infinity,
      key: ValueKey(userId),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      selectedUserId = "";
                      selectedUserId = post['userId'];
                      //  widget.seeUserProfileClick();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: Image.network(
                        post['user']?['imageUrl'] ?? imagePlaceHolder,
                        width: width * 0.032,
                        height: width * 0.032,
                      ).image,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['user']['name'].toString(),
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              extractUsernameFromEmail(
                                post['user']['email'].toString(),
                              ),
                              style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              formatTimestampAgo(
                                DateTime.fromMillisecondsSinceEpoch(
                                  post['timeStamp'] ?? "",
                                ),
                              ),
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                //if (userData!['userId'] != post['userId'])
                // followButton(post, false, userData!['userId'])
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            if (isMobile == true || touchmatchMedia == true)
              htmlEditorControllerWidget(post['postDetail']),
            if (touchmatchMedia == false)
              Container(
                constraints: const BoxConstraints(maxHeight: 150.0),
                child: Html(
                  data: post['postDetail'],
                  onlyRenderTheseTags: {'h1', 'h2', 'p', 'a'},
                  // extensions: [],
                  style: {
                    'h1': Style(
                      padding: HtmlPaddings.all(0),
                      margin: Margins.zero,
                      textDecoration: TextDecoration.none,
                    ),
                    'h2': Style(
                      padding: HtmlPaddings.all(0),
                      margin: Margins.zero,
                      textDecoration: TextDecoration.none,
                    ),
                    'p': Style(
                      padding: HtmlPaddings.all(0),
                      margin: Margins.zero,
                      textDecoration: TextDecoration.none,
                      backgroundColor: backgroundColor,
                    ),
                    'body': Style(
                      padding: HtmlPaddings.all(0),
                      margin: Margins.zero,
                      textDecoration: TextDecoration.none,
                      backgroundColor: backgroundColor,
                    )
                  },
                ),
              ),
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                postId = post['postId'];
                //   widget.postClick();
              },
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.only(
                    bottom: 10, right: 20, top: 10, left: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: buttonColor),
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: Center(
                  child: Text(
                    "Read Article",
                    style: TextStyle(
                      color: buttonColor,
                      fontFamily: GoogleFonts.lato().fontFamily,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
            feedBackContainer(post['commentCount'], post['postId'],
                post['postType'].toString(), post)
          ],
        ),
      ),
    );
  }

  Widget htmlEditorControllerWidget(html) {
    final QuillEditorController htmlController = QuillEditorController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 150,
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
        minHeight: 150,
        isEnabled: false,
        autoFocus: false,
        textStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontFamily: "Lato",
              fontSize: 14,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none),
        ),
      ),
    );
  }

  Widget feedBackContainer(commentCount, postID, postType, post) {
    var commentLength = "0";
    if (commentCount > 0) {
      commentLength = "";
      commentLength = "$commentCount";
    }
    //  var isBookMarkContain = false;
    // var isLiked = false;
    var likes = post['likes'].toList().length;

    // if (post['bookMarks'].toList().length > 0) {
    //   isBookMarkContain =
    //       post['bookMarks'].toList().contains(userData!['userId'].toString());
    // } else {
    //   isBookMarkContain = false;
    // }
    // if (post['likes'].toList().length > 0) {
    //   isLiked = post['likes'].toList().contains(userData!['userId'].toString());
    // } else {
    //   isLiked = false;
    // }
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // if (isLiked) {
                    //   unlikeAction(userData!['userId'], postID);
                    // } else {
                    //   likeAction(userData!['userId'], postID);
                    // }
                  },
                  child: Image.asset(
                    "assets/triangle.png",
                    width: width * 0.015,
                    height: width * 0.015,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "$likes",
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/review.png",
                  width: width * 0.01,
                  height: width * 0.01,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "2",
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none)),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              postId = postID;
              //  widget.postClick();
            },
            child: SizedBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/comment.png",
                    width: width * 0.01,
                    height: width * 0.01,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    commentLength,
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/share.png",
                  width: width * 0.01,
                  height: width * 0.01,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "0",
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none)),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // if (isBookMarkContain) {
              //   removeFromBookMark(userData!['userId'], postID);
              // } else {
              //   addToBookMark(userData!['userId'], postID);
              // }
            },
            child: SizedBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/like.png",
                    // isBookMarkContain
                    //     ? "assets/like.png"
                    //     : "assets/bookmark.png",
                    width: width * 0.01,
                    height: width * 0.01,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "${post['bookMarks'].toList().length}",
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none)),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/signal.png",
                  width: width * 0.01,
                  height: width * 0.01,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "10",
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

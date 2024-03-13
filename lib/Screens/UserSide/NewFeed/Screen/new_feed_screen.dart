import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto/Screens/UserSide/NewFeed/Screen/story_maker_screen.dart';
import 'package:proyecto/Views/all_post_container.dart';
import 'package:proyecto/Views/create_post_container.dart';
import 'package:proyecto/Views/recommendation_container.dart';
import 'package:proyecto/Views/status_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:newsfeed_multiple_imageview/newsfeed_multiple_imageview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/foundation.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'dart:html' as html;

class NewFeedScreen extends StatefulWidget {
  final Function postClick;
  final Function articleClick;
  final Function seeUserProfileClick;
  final Function onEventClick;
  const NewFeedScreen(
      {Key? key,
      required this.postClick,
      required this.articleClick,
      required this.seeUserProfileClick,
      required this.onEventClick})
      : super(key: key);

  @override
  State<NewFeedScreen> createState() => _NewFeedScreenState();
}

class _NewFeedScreenState extends State<NewFeedScreen>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> allPosts = [];

  var auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic>? userData;
  var followingsList = [];
  var myId = "";
  var imageUrl = "";
  List<String> uploadedProfileImage = [];
  final List<Map<String, dynamic>> momentsData = [];
  var imagePlaceHolder =
      "https://firebasestorage.googleapis.com/v0/b/proyecto-3c7e7.appspot.com/o/imageplaceholder%20copy.png?alt=media&token=28107855-594f-47f1-a5c7-318f62f59a4e";
  var isMobile = false;
  @override
  bool get wantKeepAlive => true;
  late ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }

    user = auth.currentUser;
    getUserData();
    // getAllPost();
    scrollController = ScrollController();
  }

  void getAllPost() async {
    await getAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            primary: false,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const CreatePostContainer(),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: double.infinity,
                    height: 130,
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            height: 140,
                            width: width - 114,
                            margin: const EdgeInsets.only(left: 10),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(0),
                              itemCount: followingsList.length + 1,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Container(
                                    height: 130,
                                    width: 110,
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            getUserStatusData(user?.uid ?? "");
                                          },
                                          child: Container(
                                            width: 110,
                                            height: 114,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle),
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 2,
                                                            color: buttonColor),
                                                        shape: BoxShape.circle),
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    child: CircleAvatar(
                                                      radius: 45,
                                                      backgroundColor:
                                                          Colors.grey,
                                                      backgroundImage:
                                                          Image.network(
                                                        imageUrl,
                                                      ).image,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 5,
                                                  right: 15,
                                                  child: GestureDetector(
                                                    onTap: () =>
                                                        showStorySelectionOption(
                                                            context),
                                                    child: Container(
                                                      //color: buttonColor,
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1,
                                                              color:
                                                                  Colors.white),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: buttonColor),
                                                      child: const Center(
                                                          child: Text(
                                                        "+",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10),
                                                      )),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text("Create Stories",
                                            style: GoogleFonts.lato(
                                              textStyle: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600),
                                            ))
                                      ],
                                    ),
                                  );
                                } else {
                                  var data = followingsList[index - 1];
                                  return StatusContainer(
                                    userId: data,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  allPostListViewWidget(),
                  SizedBox(
                    width: width * 0.9,
                    child: Image.asset("assets/adds.png"),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                        horizontal: width * 0.04, vertical: 10),
                    child: Text(
                      "Recommended for you",
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: width * 0.01,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 180,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10),
                    child: ListView.builder(
                      itemCount: 20,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return const RecommendationContainer();
                      },
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }

  Widget allPostListViewWidget() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
      child: ListView.builder(
        controller: scrollController,
        itemCount: allPosts.length,
        primary: false,
        shrinkWrap: true,
        //controller: _allPostsScrollController,
        itemBuilder: (context, index) {
          var data = allPosts[index];
          var postID = data['postId'];
          var commentLength = data['commentCount'];
          var userId = data['userId'];
          var isFollowed = userData!['following'].toList().contains(userId);
          if (data['postType'] == "event") {
            if (isMobile == true) {
              return eventContainerForMBl(data, userId);
            } else if (touchmatchMedia == true) {
              return eventContainerForMBl(data, userId);
            } else if (width < 800) {
              return eventContainer(data, userId, commentLength, postID);
            } else {
              return eventContainer(data, userId, commentLength, postID);
            }
          } else {
            if (isMobile == true) {
              return postContainerForMBl(data, userId);
            } else if (touchmatchMedia == true) {
              return postContainerForMBl(data, userId);
            } else if (width < 800) {
              return postContainerForMBl(data, userId);
            } else {
              return Container(
                width: double.infinity,
                key: ValueKey(userId),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                            selectedUserId = data['userId'];
                            widget.seeUserProfileClick();
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: Image.network(
                              data['user']?['imageUrl'] ?? imagePlaceHolder,
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
                              Row(
                                children: [
                                  customUserName(
                                    data['user']?['name'] ?? "UserName",
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  customTextWidget(extractUsernameFromEmail(
                                      data['user']?['email'])),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  customTextWidget(formatTimestampAgo(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      data['timeStamp'] ?? "",
                                    ),
                                  )),
                                ],
                              ),
                              if (data['postType'].toString() == "event")
                                articleTitleWidget(
                                    data['postTitle'].toString()),
                              if (data['postType'].toString() == "article")
                                Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 150.0),
                                    child: Html(
                                      data: data['postDetail'],
                                      onLinkTap: (url, attributes, element) {
                                        html.window.open(url!, "name");

                                        final youtubeRegex = RegExp(
                                          r'https?:\/\/(?:www\.)?youtu\.?be(?:\.com)?\/(?:[\w\/]+)(?:\?v=|\/)?([a-zA-Z0-9_-]{11})',
                                        );

                                        if (youtubeRegex.hasMatch(url)) {
                                          // If the tapped link is a YouTube link, you can handle it here
                                          final videoId = youtubeRegex
                                              .firstMatch(url)
                                              ?.group(1);
                                          print(
                                              'YouTube link detected with video ID: $videoId');
                                          // You can display the text or do further processing
                                        }
                                        // Handle other links
                                        print(
                                            'Non-YouTube link detected: $url');
                                      },
                                    )),
                              const SizedBox(
                                height: 10,
                              ),
                              if (data['postType'].toString() != "article" ||
                                  data['postType'].toString() == "event")
                                postDetailWidget(data),
                              const SizedBox(
                                height: 10,
                              ),
                              if (data['postType'].toString() == "image" ||
                                  data['postType'].toString() == "event" &&
                                      data['imagesUrl'] != null &&
                                      (data['imagesUrl'] as List).isNotEmpty)
                                SizedBox(
                                  height: height * 0.5,
                                  child: NewsfeedMultipleImageView(
                                    imageUrls:
                                        data['imagesUrl'].cast<String>() ?? [],
                                  ),
                                ),
                              if (data['postType'].toString() == "video")
                                videoPlayerWidget(data),
                              const SizedBox(
                                height: 10,
                              ),
                              if (data['postType'].toString() == "article")
                                readArticleButton(data),
                              feedBackContainer(commentLength, postID,
                                  data['postType'].toString(), data)
                            ],
                          ),
                        ),
                      ),
                      if (myId != data['userId']) followButton(data, isFollowed)
                    ],
                  ),
                ),
              );
            }
          } //else
        },
      ),
    );
  }

  Widget customUserName(
    String text,
  ) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.lato(
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget customTextWidget(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.lato(
        textStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget articleTitleWidget(String title) {
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
      ),
      child: Text(
        title,
        style: GoogleFonts.lato(
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget postDetailWidget(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        postId = data['postId'];
        if (data['postType'].toString() != "article") {
          widget.postClick();
        }
      },
      child: Text(
        data['postDetail'].toString(),
        style: GoogleFonts.lato(
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }

  Widget readArticleButton(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        postId = data['postId'].toString();
        widget.articleClick();
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(bottom: 20),
        padding:
            const EdgeInsets.only(bottom: 10, right: 20, top: 10, left: 20),
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
    );
  }

  Widget followButton(post, bool isFollowed) {
    if (post['postType'] != "event") {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            if (isFollowed) {
              unfollowButtonAction(myId, post['userId']);
            } else {
              followButtonAction(myId, post['userId']);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20, right: 20),
            padding:
                const EdgeInsets.only(bottom: 10, right: 20, top: 10, left: 20),
            decoration: BoxDecoration(
                color: isFollowed ? buttonColor : Colors.white,
                border: Border.all(
                    width: 1, color: isFollowed ? Colors.white : buttonColor),
                borderRadius: BorderRadius.circular(
                  20,
                )),
            child: Center(
                child: Text(
              isFollowed ? "Un Follow" : "Follow",
              style: TextStyle(
                  color: isFollowed ? Colors.white : buttonColor,
                  fontFamily: GoogleFonts.lato().fontFamily,
                  fontSize: 10),
            )),
          ),
        ),
      );
    } else {
      return liveButton(post);
    }
  }

  Widget followButtonForMbl(post, bool isFollowed) {
    if (post['postType'] != "event") {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            if (isFollowed) {
              unfollowButtonAction(myId, post['userId']);
            } else {
              followButtonAction(myId, post['userId']);
            }
          },
          child: Container(
            //margin: const EdgeInsets.only(bottom: 20, right: 20),
            padding:
                const EdgeInsets.only(bottom: 10, right: 20, top: 10, left: 20),
            decoration: BoxDecoration(
                color: isFollowed ? buttonColor : Colors.white,
                border: Border.all(
                    width: 1, color: isFollowed ? Colors.white : buttonColor),
                borderRadius: BorderRadius.circular(
                  20,
                )),
            child: Center(
                child: Text(
              isFollowed ? "Un Follow" : "Follow",
              style: TextStyle(
                  color: isFollowed ? Colors.white : buttonColor,
                  fontFamily: GoogleFonts.lato().fontFamily,
                  fontSize: 10),
            )),
          ),
        ),
      );
    } else {
      return liveButton(post);
    }
  }

  Widget liveButton(post) {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.only(bottom: 20, right: 20),
          padding:
              const EdgeInsets.only(bottom: 10, right: 20, top: 10, left: 20),
          decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(
                20,
              )),
          child: Center(
              child: Text(
            "Live",
            style: TextStyle(
                color: Colors.white,
                fontFamily: GoogleFonts.lato().fontFamily,
                fontSize: width * 0.009),
          )),
        ),
      ),
    );
  }

  Widget eventContainer(data, userId, commentLength, postID) {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  selectedUserId = "";
                  selectedUserId = data['userId'];
                  postId = postID;
                  widget.onEventClick();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 10, bottom: 20),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: postButtonColor,
                  ),
                  child: Center(
                      child: Image.asset(
                    "assets/start.png",
                    width: 20,
                    height: 20,
                  )),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customUserName(formatTimestamp(data['timeStamp'])),
                    articleTitleWidget(data['postTitle'].toString()),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "943 Interested 96 Going",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (data['imagesUrl'] != null &&
                        (data['imagesUrl'] as List).isNotEmpty)
                      SizedBox(
                        height: height * 0.5,
                        child: NewsfeedMultipleImageView(
                          imageUrls: data['imagesUrl'].cast<String>() ?? [],
                        ),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventContainerForMBl(data, userId) {
    ;
    var userId = data['userId'];
    var isFollowed = userData!['following'].toList().contains(userId);
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
                      selectedUserId = data['userId'];
                      widget.seeUserProfileClick();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: Image.network(
                        data['user']?['imageUrl'] ?? imagePlaceHolder,
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
                            customUserName(formatTimestamp(data['timeStamp'])),
                            articleTitleWidget(data['postTitle'].toString()),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "943 Interested 96 Going",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (myId != data['userId']) followButtonForMbl(data, isFollowed)
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            if (data['imagesUrl'] != null &&
                (data['imagesUrl'] as List).isNotEmpty)
              SizedBox(
                height: height * 0.5,
                child: NewsfeedMultipleImageView(
                  imageUrls: data['imagesUrl'].cast<String>() ?? [],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget postContainerForMBl(data, userId) {
    var postID = data['postId'];
    var commentLength = data['commentCount'];
    var userId = data['userId'];
    var isFollowed = userData!['following'].toList().contains(userId);
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
                      selectedUserId = data['userId'];
                      widget.seeUserProfileClick();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: Image.network(
                        data['user']?['imageUrl'] ?? imagePlaceHolder,
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
                            customUserName(
                              data['user']?['name'] ?? "UserName",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            customTextWidget(extractUsernameFromEmail(
                                data['user']?['email'])),
                            const SizedBox(
                              height: 5,
                            ),
                            customTextWidget(
                              formatTimestampAgo(
                                DateTime.fromMillisecondsSinceEpoch(
                                  data['timeStamp'] ?? "",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (myId != data['userId']) followButtonForMbl(data, isFollowed)
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            if (data['postType'].toString() == "event")
              articleTitleWidget(data['postTitle'].toString()),
            if (data['postType'].toString() == "article" &&
                (touchmatchMedia == true))
              Container(
                constraints: const BoxConstraints(maxHeight: 150.0),
                child: htmlEditorControllerWidget(
                  data['postDetail'].toString(),
                ),
              ),
            if (data['postType'].toString() == "article" &&
                (touchmatchMedia == false))
              Container(
                constraints: const BoxConstraints(maxHeight: 150.0),
                child: Html(
                  data: data['postDetail'],
                  onLinkTap: (url, attributes, element) {
                    html.window.open(url!, "name");
                  },
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            if (data['postType'].toString() != "article" ||
                data['postType'].toString() == "event")
              postDetailWidget(data),
            const SizedBox(
              height: 10,
            ),
            if (data['postType'].toString() == "image" ||
                data['postType'].toString() == "event" &&
                    data['imagesUrl'] != null &&
                    (data['imagesUrl'] as List).isNotEmpty)
              SizedBox(
                height: height * 0.5,
                child: NewsfeedMultipleImageView(
                  imageUrls: data['imagesUrl'].cast<String>() ?? [],
                ),
              ),
            if (data['postType'].toString() == "video") videoPlayerWidget(data),
            const SizedBox(
              height: 10,
            ),
            if (data['postType'].toString() == "article")
              readArticleButton(data),
            feedBackContainer(
                commentLength, postID, data['postType'].toString(), data)
          ],
        ),
      ),
    );
  }

  // ... existing code ...
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
          ),
        ),
      ),
    );
  }

  Widget videoPlayerWidget(Map<String, dynamic> data) {
    String videoUrl = data['imagesUrl'][0];
    return Container(
      width: double.infinity,
      height: height * 0.7,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: VideoPlayerWidget(
            videoUrl: videoUrl,
          ),
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
    var isBookMarkContain = false;
    var isLiked = false;
    var likes = post['likes'].toList().length;

    if (post['bookMarks'].toList().length > 0) {
      isBookMarkContain =
          post['bookMarks'].toList().contains(userData!['userId'].toString());
    } else {
      isBookMarkContain = false;
    }
    if (post['likes'].toList().length > 0) {
      isLiked = post['likes'].toList().contains(userData!['userId'].toString());
    } else {
      isLiked = false;
    }
    return SizedBox(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          GestureDetector(
            onTap: () {
              if (isLiked) {
                unlikeAction(userData!['userId'], postID);
              } else {
                likeAction(userData!['userId'], postID);
              }
            },
            child: Image.asset(
              "assets/triangle.png",
              width: 20,
              height: 20,
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
                    fontWeight: FontWeight.w600)),
          )
        ])),
        SizedBox(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image.asset(
            "assets/review.png",
            width: 15,
            height: 15,
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
                    fontWeight: FontWeight.w600)),
          )
        ])),
        GestureDetector(
          onTap: () {
            postId = postID;
            if (postType != "article") {
              widget.postClick();
            } else {
              widget.articleClick();
            }
          },
          child: SizedBox(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Image.asset(
              "assets/comment.png",
              width: 15,
              height: 15,
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
                      fontWeight: FontWeight.w600)),
            )
          ])),
        ),
        SizedBox(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image.asset(
            "assets/share.png",
            width: 15,
            height: 15,
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
                    fontWeight: FontWeight.w600)),
          )
        ])),
        GestureDetector(
          onTap: () {
            if (isBookMarkContain) {
              removeFromBookMark(userData!['userId'], postID);
            } else {
              addToBookMark(userData!['userId'], postID);
            }
          },
          child: SizedBox(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Image.asset(
              isBookMarkContain ? "assets/like.png" : "assets/bookmark.png",
              width: 15,
              height: 15,
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
                      fontWeight: FontWeight.w600)),
            )
          ])),
        ),
        SizedBox(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image.asset(
            "assets/signal.png",
            width: 15,
            height: 15,
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
                    fontWeight: FontWeight.w600)),
          )
        ])),
      ]),
    );
  }

  Future<void> showStorySelectionOption(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Colors.black.withOpacity(0.6),
            width: 400,
            height: 200,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: isMobile ? 150 : 200,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Card(
                            shape: const CircleBorder(),
                            child: GestureDetector(
                              onTap: () async {
                                var image = [];
                                if (touchmatchMedia == false) {
                                  var image = await _pickProfileImage();
                                  print("image $image");
                                } else {
                                  image = await _openFileUploadDialog(context);
                                }
                                if (image.isNotEmpty) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          StoryMakerScreen(
                                        isImageStatus: true,
                                        imageString: image[0],
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Center(
                                child: Image.asset(
                                  "assets/gallery.png",
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            'Create a photo story',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      height: isMobile ? 150 : 200,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            shape: const CircleBorder(),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pop(); // Dismiss the dialog
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const StoryMakerScreen(
                                      isImageStatus: false,
                                      imageString: "",
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Image.asset(
                                "assets/textIcon.png",
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ),
                          const Text(
                            'Create a text Story',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> _pickProfileImage() async {
    uploadedProfileImage.clear();

    final completer = Completer<List<String>>();

    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.accept = '.png,.jpg';
    uploadInput.style
      ..position = 'absolute'
      ..top = '100px'
      ..left = '200px';
    uploadInput.click();

    // onChange doesn't work on mobile safari
    uploadInput.addEventListener('change', (e) async {
      // read file content as dataURL
      final files = uploadInput.files;
      Iterable<Future<String>> resultsFutures = files!.map((file) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        // String extension = file.name.split('.').last.toLowerCase();
        reader.onError.listen((error) => completer.completeError(error));
        return reader.onLoad.first.then((_) => reader.result as String);
      });

      try {
        final results = await Future.wait(resultsFutures);
        completer.complete(results);
      } catch (error) {
        completer.completeError(error);
      }
    });

    // Add the following line to ensure that the completer is correctly handled.
    return completer.future;
  }

  Future<List<String>> _openFileUploadDialog(BuildContext context) async {
    List<String> uploadedProfileImages = [];

    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      uploadedProfileImages.add(image.path);
    }

    // Return the list of uploaded image paths
    return uploadedProfileImages;
  }

  Future<void> getUserData() async {
    if (user != null) {
      var userId = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId.toString())
          .snapshots()
          .listen((userInfo) {
        userFullData = userInfo.data();
        userData = userInfo.data();
        myId = userInfo.data()?['userId'];
        imageUrl = userInfo.data()?['imageUrl'];
        followingsList = userInfo.data()?['following'].toList();

        if (mounted) {
          setState(() {});
        }
        getAllPost();
      });
    }
  }

  Future<Map<String, dynamic>> fetchUser(userId) async {
    var user = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId.toString())
        .get();
    return user.data() as Map<String, dynamic>;
  }

  void followButtonAction(myID, userId) {
    FirebaseFirestore.instance.collection("Users").doc(myID).update({
      "following": FieldValue.arrayUnion([userId.toString()])
    });
    FirebaseFirestore.instance.collection("Users").doc(userId).update({
      "follower": FieldValue.arrayUnion([myID])
    });
  }

  void unfollowButtonAction(myID, userId) {
    FirebaseFirestore.instance.collection("Users").doc(myID).update({
      "following": FieldValue.arrayRemove([userId.toString()])
    });
    FirebaseFirestore.instance.collection("Users").doc(userId).update({
      "follower": FieldValue.arrayRemove([myID.toString()])
    });
  }

  Future<void> getUserStatusData(userId) async {
    if (userId != "") {
      try {
        final QuerySnapshot<Map<String, dynamic>> userInfo =
            await FirebaseFirestore.instance
                .collection('Status')
                .where("userId", isEqualTo: userId)
                .get();

        momentsData.clear(); // Clear existing data before updating
        momentsData.addAll(userInfo.docs.map((doc) {
          return doc.data();
        }));

        if (mounted) {
          setState(() {
            if (momentsData.isNotEmpty) {
              storiessContainer(momentsData, context, userData);
            }
          });
        }
      } catch (error) {
        print("Error retrieving user status data: $error");
      }
    }
  }

  Future<void> addToBookMark(userId, postId) async {
    if (userId != "") {
      try {
        FirebaseFirestore.instance.collection("Posts").doc(postId).update({
          "bookMarks": FieldValue.arrayUnion([userId.toString()])
        });
        // setState(() {});
      } catch (error) {
        print("Error retrieving user status data: $error");
      }
    }
  }

  Future<void> removeFromBookMark(userId, postId) async {
    if (userId != "") {
      try {
        FirebaseFirestore.instance.collection("Posts").doc(postId).update({
          "bookMarks": FieldValue.arrayRemove([userId.toString()])
        });
        // setState(() {});
      } catch (error) {
        print("Error retrieving user status data: $error");
      }
    }
  }

  Future<void> likeAction(userId, postId) async {
    if (userId != "") {
      try {
        FirebaseFirestore.instance.collection("Posts").doc(postId).update({
          "likes": FieldValue.arrayUnion([userId.toString()])
        });
        // setState(() {});
      } catch (error) {
        print("Error retrieving user status data: $error");
      }
    }
  }

  Future<void> unlikeAction(userId, postId) async {
    if (userId != "") {
      try {
        FirebaseFirestore.instance.collection("Posts").doc(postId).update({
          "likes": FieldValue.arrayRemove([userId.toString()])
        });
        // setState(() {});
      } catch (error) {
        print("Error retrieving user status data: $error");
      }
    }
  }

  Future<void> getAllPosts() async {
    FirebaseFirestore.instance
        .collection('Posts')
        .orderBy("timeStamp", descending: true)
        // .limit(20)
        .snapshots()
        .listen((allPostSnapshot) {
      allPosts.clear();
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        allPosts.add(post);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }
}

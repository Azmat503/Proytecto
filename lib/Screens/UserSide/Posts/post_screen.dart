import 'package:flutter/material.dart';
import 'package:newsfeed_multiple_imageview/newsfeed_multiple_imageview.dart';
import 'package:proyecto/Views/create_post_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:proyecto/Views/all_post_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PostScreen extends StatefulWidget {
  final Function postClick;
  final Function articleClick;
  final Function seeUserProfileClick;
  const PostScreen(
      {super.key,
      required this.postClick,
      required this.articleClick,
      required this.seeUserProfileClick});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Stream<List<Map<String, dynamic>>>? allPosts;
  List<Map<String, dynamic>> allPostss = [];
  final firebaseFirestore = FirebaseFirestore.instance;
  var auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic>? userData;
  var followingsList = [];
  var myId = "";
  var imageUrl = "";
  var isMobile = false;
  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }

    getUserData();
    getAllPost();
  }

  void getAllPost() async {
    allPosts = PostRepositort().getAllPosts();
    getAllPosts();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Container(
          color: backgroundColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: width * 0.02),
                  child: ListView.separated(
                    itemCount: allPostss.length,
                    primary: false,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var data = allPostss[index];
                      var userId = data['userId'];
                      if (isMobile) {
                        return postContainerForMBl(data, userId);
                      }
                      if (touchmatchMedia == true) {
                        return postContainerForMBl(data, userId);
                      } else if (width < 600) {
                        return postContainerForMBl(data, userId);
                      } else {
                        return postListView(data);
                      }
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        height: 10,
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: width * 0.9,
                  child: Image.asset("assets/adds.png"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget postListView(post) {
    var isFollowed = userData!['following'].toList().contains(post['userId']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
                      widget.seeUserProfileClick();
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
                            customUserName(post['user']['name'].toString()),
                            const SizedBox(
                              width: 16,
                            ),
                            customTextWidget(extractUsernameFromEmail(
                                post['user']['email'].toString())),
                            const SizedBox(
                              width: 16,
                            ),
                            customTextWidget(
                              formatTimestampAgo(
                                DateTime.fromMillisecondsSinceEpoch(
                                  post['timeStamp'] ?? "",
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (post['postType'].toString() == "article")
                          articleTitleWidget(post['postTitle'].toString()),
                        const SizedBox(
                          height: 10,
                        ),
                        postDetailWidget(post),
                        const SizedBox(
                          height: 10,
                        ),
                        if (post['postType'].toString() == "image" ||
                            post['postType'].toString() == "event" &&
                                post['imagesUrl'] != null &&
                                (post['imagesUrl'] as List).isNotEmpty)
                          SizedBox(
                            height: height * 0.5,
                            child: NewsfeedMultipleImageView(
                              imageUrls: post['imagesUrl'].cast<String>() ?? [],
                            ),
                          ),

                        if (post['postType'].toString() == "video")
                          videoPlayerWidget(post),
                        const SizedBox(
                          height: 10,
                        ),
                        // if (post['hashTag'].toString() != "null")
                        //   Text(
                        //     "#proyecto \t #reach \t #tag \t #like \t #comment \t #repost",
                        //     style: TextStyle(color: buttonColor),
                        //   ),
                        if (post['postType'].toString() == "article")
                          readArticleButon(post),
                        feedBackContainer(post['commentCount'], post['postId'],
                            post['postType'].toString(), post)
                      ]),
                ),
              ),
              // if (post['isLive'])
              //liveButton(),
              // if (!post['isLive'])
              if (myId != post['userId']) followButton(post, isFollowed)
            ]),
      ),
    );
  }

  Widget customUserName(String text) {
    return Text(
      text,
      style: GoogleFonts.lato(
        textStyle: const TextStyle(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget customTextWidget(String text) {
    return Text(
      text,
      style: GoogleFonts.lato(
          textStyle: const TextStyle(color: Colors.grey, fontSize: 12)),
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
            textStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget postDetailWidget(post) {
    return GestureDetector(
        onTap: () {
          postId = post['postId'].toString();
          if (post['postType'].toString() != "article") {
            widget.postClick();
          }
          //else {
          // widget.articleClick();
          //}
        },
        child: Text(
          post['postDetail'].toString(),
          style: GoogleFonts.lato(
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        ));
  }

  Widget videoPlayerWidget(post) {
    var videoUrl = post['imagesUrl'][0];
    return SizedBox(
      width: double.infinity,
      height: height * 0.6,
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

  Widget readArticleButon(post) {
    return GestureDetector(
      onTap: () {
        postId = post['postId'].toString();
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

  Widget liveButton() {
    return const Align(
        //     alignment: Alignment.topRight,
        //     child: Container(
        //       margin: const EdgeInsets.only(bottom: 20, right: 20),
        //       padding: const EdgeInsets.only(
        //           bottom: 10, right: 20, top: 10, left: 20),
        //       decoration: BoxDecoration(
        //           color: buttonColor,
        //           border: Border.all(width: 1, color: buttonColor),
        //           borderRadius: BorderRadius.circular(
        //             20,
        //           )),
        //       child: Center(
        //           child: Text(
        //         "Live",
        //         style: TextStyle(
        //             color: Colors.white,
        //             fontFamily: GoogleFonts.lato().fontFamily,
        //             fontSize: width * 0.009),
        //       )),
        //     ),
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
      return Container();
    }
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
            feedBackContainer(
                commentLength, postID, data['postType'].toString(), data)
          ],
        ),
      ),
    );
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
      return liveButton();
    }
  }

  Future<void> getAllPosts() async {
    firebaseFirestore
        .collection("Posts")
        .where("postType", isNotEqualTo: "article")
        .orderBy("postType")
        .orderBy("timeStamp", descending: true)
        // .limit(20)
        .snapshots()
        .listen((allPostSnapshot) {
      allPostss.clear();
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        if (post["postType"] != "event") {
          allPostss.add(post);
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> getUserData() async {
    if (user != null) {
      var userId = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId.toString())
          .snapshots()
          .listen((userInfo) {
        userData = userInfo.data();
        myId = userInfo.data()?['userId'];
        imageUrl = userInfo.data()?['imageUrl'];
        followingsList = userInfo.data()?['following'].toList();
        getAllPost();
        if (mounted) {
          setState(() {});
        }
      });
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
}

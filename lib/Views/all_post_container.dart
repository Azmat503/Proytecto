import 'package:flutter/material.dart';
import 'package:newsfeed_multiple_imageview/newsfeed_multiple_imageview.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';

class AllPostContainer extends StatefulWidget {
  final Function postClick;
  final Function articleClick;
  final Map<String, dynamic> post;

  const AllPostContainer({
    super.key,
    required this.postClick,
    required this.articleClick,
    required this.post,
  });

  @override
  State<AllPostContainer> createState() => _AllPostContainerState();
}

class _AllPostContainerState extends State<AllPostContainer>
    with AutomaticKeepAliveClientMixin {
  late Map<String, dynamic> post;

  List<String> imagesUrl = [];

  String timeAgo = "";

  @override
  void initState() {
    super.initState();
    initializeArraysVariable();
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                  child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: Image.network(
                        post['user']['imageUrl'],
                        width: width * 0.032,
                        height: width * 0.032,
                      ).image)),

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
                            customTextWidget(timeAgo),
                          ],
                        ),
                        if (post['postType'].toString() == "article")
                          articleTitleWidget(post['postTitle'].toString()),
                        const SizedBox(
                          height: 10,
                        ),
                        postDetailWidget(),
                        const SizedBox(
                          height: 10,
                        ),
                        if (post['postType'].toString() == "image" ||
                            post['postType'].toString() == "article" &&
                                imagesUrl.isNotEmpty)
                          SizedBox(
                              height: height * 0.5,
                              child: NewsfeedMultipleImageView(
                                imageUrls: imagesUrl,
                              )),
                        if (post['postType'].toString() == "video")
                          videoPlayerWidget(),
                        const SizedBox(
                          height: 10,
                        ),
                        // if (post['hashTag'].toString() != "null")
                        //   Text(
                        //     "#proyecto \t #reach \t #tag \t #like \t #comment \t #repost",
                        //     style: TextStyle(color: buttonColor),
                        //   ),
                        if (post['postType'].toString() == "article")
                          readArticleButon(),
                        feedBackContainer(post['commentCount'], post['postId'],
                            post['postType'].toString(), post)
                      ]),
                ),
              ),
              // if (post['isLive'])
              //liveButton(),
              // if (!post['isLive'])
              followButton()
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

  Widget postDetailWidget() {
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

  Widget videoPlayerWidget() {
    return SizedBox(
      width: double.infinity,
      height: height * 0.6,
      child: Center(
        child: VideoPlayerWidget(videoUrl: imagesUrl.first),
      ),
    );
  }

  Widget readArticleButon() {
    return GestureDetector(
      onTap: () {
        postId = post['postId'].toString();
        widget.articleClick();
      },
      child: Container(
        width: width * 0.07,
        height: height * 0.05,
        margin: const EdgeInsets.only(bottom: 20, right: 20, top: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1, color: buttonColor),
            borderRadius: BorderRadius.circular(
              20,
            )),
        child: Center(
            child: Text(
          "Read Article",
          style: TextStyle(
              color: buttonColor,
              fontFamily: GoogleFonts.lato().fontFamily,
              fontSize: width * 0.009),
        )),
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

  Widget followButton() {
    return const Align(
        //     alignment: Alignment.topRight,
        //     child: GestureDetector(
        //       onTap: () {},
        //       child: Container(
        //         margin: const EdgeInsets.only(bottom: 20, right: 20),
        //         padding: const EdgeInsets.only(
        //             bottom: 10, right: 20, top: 10, left: 20),
        //         decoration: BoxDecoration(
        //             color: post.isFollowed ? buttonColor : Colors.white,
        //             border: Border.all(
        //                 width: 1,
        //                 color:
        //                     post.isFollowed ? Colors.white : buttonColor),
        //             borderRadius: BorderRadius.circular(
        //               20,
        //             )),
        //         child: Center(
        //             child: Text(
        //           "Follow",
        //           style: TextStyle(
        //               color: post.isFollowed ? Colors.white : buttonColor,
        //               fontFamily: GoogleFonts.lato().fontFamily,
        //               fontSize: width * 0.009),
        //         )),
        //       ),
        //     ),
        );
  }

  Widget feedBackContainer(commentCount, postID, postType, post) {
    var commentLength = "0";
    if (commentCount > 0) {
      commentLength = "";
      commentLength = "$commentCount";
    }
    var isBookMarkContain = false;
    if (post['bookMarks'].toList().length > 0) {
      isBookMarkContain = post['bookMarks']
          .toList()
          .contains(userFullData!['userId'].toString());
    } else {
      isBookMarkContain = false;
    }
    return SizedBox(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image.asset(
            "assets/triangle.png",
            width: width * 0.015,
            height: width * 0.015,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            "${post["likes"].toList().length}",
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
                      fontWeight: FontWeight.w600)),
            )
          ])),
        ),
        SizedBox(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                    fontWeight: FontWeight.w600)),
          )
        ])),
        GestureDetector(
          onTap: () {
            if (isBookMarkContain) {
              removeFromBookMark(userFullData!['userId'], postID);
            } else {
              addToBookMark(userFullData!['userId'], postID);
            }
          },
          child: SizedBox(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Image.asset(
              isBookMarkContain ? "assets/like.png" : "assets/bookmark.png",
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
                      fontWeight: FontWeight.w600)),
            )
          ])),
        ),
        SizedBox(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                    fontWeight: FontWeight.w600)),
          )
        ])),
      ]),
    );
  }

  void initializeArraysVariable() {
    post = widget.post;

    for (var i in post['imagesUrl'] as List<dynamic>) {
      imagesUrl.add(i.toString());
    }
    int timestampInMillis =
        post['timeStamp']; // Assuming it's stored as a UNIX timestamp

    DateTime postDateTime =
        DateTime.fromMillisecondsSinceEpoch(timestampInMillis);

    setState(() {
      timeAgo = formatTimestampAgo(postDateTime);
    });
  }

  Future<void> addToBookMark(userId, postId) async {
    if (userId != "") {
      try {
        FirebaseFirestore.instance.collection("Posts").doc(postId).update({
          "bookMarks": FieldValue.arrayUnion([userId.toString()])
        });
        //  setState(() {});
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
        //setState(() {});
      } catch (error) {
        print("Error retrieving user status data: $error");
      }
    }
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final _meeduPlayerController = MeeduPlayerController(
    controlsStyle: ControlsStyle.primary,
    initialFit: BoxFit.fitHeight,
    customIcons: const CustomIcons(
      play: Icon(Icons.play_circle, color: Colors.white),
      pause: Icon(Icons.pause_circle, color: Colors.white),
    ),
  );
  var isDisablePlayer = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  _init() {
    _meeduPlayerController
        .setDataSource(
            DataSource(
              type: DataSourceType.network,
              source: widget.videoUrl,
            ),
            autoplay: false,
            looping: false)
        .catchError((onError) {
      print(
          "Error occured while play video in _meeduPlayerController $onError");
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction <= 0.5) {
          _meeduPlayerController.pause();
          isDisablePlayer = true;
          if (mounted) {
            setState(() {});
          }
        } else {
          isDisablePlayer = false;
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
            if (isDisablePlayer)
              Container(
                color: Colors.transparent,
              )
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

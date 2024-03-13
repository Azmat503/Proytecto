import 'package:flutter/material.dart';
import 'package:newsfeed_multiple_imageview/newsfeed_multiple_imageview.dart';
import 'package:proyecto/Model/post_model.dart';
import 'package:proyecto/Views/feedback_container.dart';
import 'package:proyecto/my_utilities.dart';

class MyPostContainer extends StatefulWidget {
  final PostModel post;
  final bool isFollowHidden;
  const MyPostContainer(
      {super.key, required this.post, required this.isFollowHidden});

  @override
  State<MyPostContainer> createState() => _MyPostContainerState();
}

class _MyPostContainerState extends State<MyPostContainer> {
  @override
  Widget build(BuildContext context) {
    var post = widget.post;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      // child: Padding(
      //   padding: const EdgeInsets.all(20.0),
      //   child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Align(
      //           alignment: Alignment.topLeft,
      //           child: Image.asset(post.userImage),
      //         ),
      //         Expanded(
      //           child: Padding(
      //             padding: const EdgeInsets.only(left: 20.0, right: 20),
      //             child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Row(
      //                     children: [
      //                       Text(
      //                         post.name,
      //                         style: const TextStyle(
      //                             color: Colors.black,
      //                             fontSize: 16,
      //                             fontWeight: FontWeight.bold),
      //                       ),
      //                       const SizedBox(
      //                         width: 16,
      //                       ),
      //                       Text(
      //                         post.userName,
      //                         style: const TextStyle(
      //                             color: Colors.grey, fontSize: 14),
      //                       ),
      //                       const SizedBox(
      //                         width: 16,
      //                       ),
      //                       Text(
      //                         post.time,
      //                         style: const TextStyle(
      //                             color: Colors.grey, fontSize: 14),
      //                       )
      //                     ],
      //                   ),
      //                   const SizedBox(
      //                     height: 10,
      //                   ),
      //                   if (post.articleTitle.isNotEmpty)
      //                     Text(
      //                       post.articleTitle,
      //                       style: TextStyle(
      //                           fontSize: width * 0.01,
      //                           fontWeight: FontWeight.bold),
      //                     ),
      //                   const SizedBox(
      //                     height: 10,
      //                   ),
      //                   if (post.articleDetail.isNotEmpty)
      //                     GestureDetector(
      //                         onTap: () {}, child: Text(post.articleDetail)),
      //                   const SizedBox(
      //                     height: 10,
      //                   ),
      //                   if (post.imagesList.isNotEmpty && post.isImagePost)
      //                     SizedBox(
      //                         height: height * 0.5,
      //                         child: const NewsfeedMultipleImageView(
      //                           imageUrls: [],
      //                         )),
      //                   if (post.isVideoPost && post.videoUrl.isNotEmpty)
      //                     SizedBox(
      //                         width: double.infinity,
      //                         height: height * 0.6,
      //                         child: Center(
      //                           child: Stack(
      //                             children: [
      //                               Image.asset(
      //                                 "assets/car.png",
      //                                 fit: BoxFit.fill,
      //                                 width: double.infinity,
      //                                 height: height * 0.6,
      //                               ),
      //                               Center(
      //                                 widthFactor: 30,
      //                                 heightFactor: 30,
      //                                 child: Image.asset(
      //                                   "assets/videoplayer.png",
      //                                   width: 50,
      //                                   height: 50,
      //                                 ),
      //                               ),
      //                             ],
      //                           ),
      //                         )),
      //                   const SizedBox(
      //                     height: 10,
      //                   ),
      //                   if (post.hashTag.isNotEmpty)
      //                     Text(
      //                       "#proyecto \t #reach \t #tag \t #like \t #comment \t #repost",
      //                       style: TextStyle(color: buttonColor),
      //                     ),
      //                   if (post.isArticlePost)
      //                     GestureDetector(
      //                       onTap: () {},
      //                       child: Container(
      //                         width: 100,
      //                         height: 40,
      //                         margin: const EdgeInsets.only(
      //                             bottom: 20, right: 20, top: 10),
      //                         decoration: BoxDecoration(
      //                             color: Colors.white,
      //                             border:
      //                                 Border.all(width: 1, color: buttonColor),
      //                             borderRadius: BorderRadius.circular(
      //                               20,
      //                             )),
      //                         child: Center(
      //                             child: Text(
      //                           "Read Article",
      //                           style: TextStyle(color: buttonColor),
      //                         )),
      //                       ),
      //                     ),
      //                   const FeedbackContainer(),
      //                 ]),
      //           ),
      //         ),
      //         if (widget.isFollowHidden)
      //           Align(
      //             alignment: Alignment.topRight,
      //             child: Container(
      //               width: 74,
      //               height: 40,
      //               margin: const EdgeInsets.only(bottom: 20, right: 20),
      //               decoration: BoxDecoration(
      //                   color: buttonColor,
      //                   borderRadius: BorderRadius.circular(
      //                     20,
      //                   )),
      //               child: const Center(
      //                   child: Text(
      //                 "Follow",
      //                 style: TextStyle(color: Colors.white),
      //               )),
      //             ),
      //           )
      //       ]),
      // ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:html' as html;

class ArticleScreen extends StatefulWidget {
  final Function postClick;
  final Function seeUserProfileClick;
  final Function createArticleClick;
  const ArticleScreen({
    super.key,
    required this.postClick,
    required this.seeUserProfileClick,
    required this.createArticleClick,
  });

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final QuillEditorController htmlController = QuillEditorController();
  final TextEditingController articleEditingController =
      TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic>? userData;
  var isLoading = false;
  var htmltext = "";

  final firebaseFirestore = FirebaseFirestore.instance;

  final List<String> _allArticlesImages = [];
  var isPostButtonEnable = false;
  bool isHtmlTextShow = false;
  var isMobile = false;
  String profileImageUrl = "";
  var isWrireArticle = false;
  bool isHovered = false;
  var isTopicSideBarHide = false;
  String selectedTopic = "All";
  final List<Map<String, dynamic>> _allArticles = [];
  final List<CategoryModel> allCategoriesList = [];
  @override
  void initState() {
    super.initState();

    htmlController.setText('Write Some thing');
    if (foundation.defaultTargetPlatform == TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }
    user = auth.currentUser;
    touchmatchMedia = html.window.matchMedia('(pointer: coarse)').matches;
    getUserData();
    getAllCategoriesList();
    getAllArticles();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopicListViewContainer(
            onTopicSelected: onTopicSelected,
            allCategoriesList: allCategoriesList,
            isTopicSideBarHide: (value) {},
          ),
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: width - 355,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    createArticelContainer(),
                    ListView.builder(
                      itemCount:
                          (_allArticles.isNotEmpty) ? _allArticles.length : 0,
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var data = _allArticles[index];
                        var userId = data['userId'];
                        if (isMobile) {
                          return postContainerForMBl(data, userId);
                        }
                        if ((touchmatchMedia == true)) {
                          return postContainerForMBl(data, userId);
                        } else if (width < 600) {
                          return postContainerForMBl(data, userId);
                        } else {
                          return readArticleListView(data);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
            "Create Article",
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
                          hintText: "Write article here..",
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
                        //isWrireArticle = true;
                        widget.createArticleClick();
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
            if (isLoading)
              Container(
                width: 74,
                height: 50,
                margin: const EdgeInsets.only(bottom: 20, right: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: postColor),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (!isLoading)
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
                      borderRadius: BorderRadius.circular(20),
                      color: isPostButtonEnable ? buttonColor : postColor),
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

  Widget readArticleListView(post) {
    var isFollowed = userData!['following'].toList().contains(post['userId']);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
                        Text(post['user']['name'].toString(),
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            )),
                        const SizedBox(
                          width: 16,
                        ),
                        Text(
                          extractUsernameFromEmail(
                              post['user']['email'].toString()),
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
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
                                color: Colors.grey, fontSize: 12),
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
                        data: post['postDetail'],
                        onLinkTap: (url, attributes, element) {
                          html.window.open(url!, "name");
                          print("url : $url");
                        },
                      ),
                    ),
                    // if (width >= 1026 && width <= 1046)
                    //   htmlEditorControllerWidget(post['postDetail']),
                    GestureDetector(
                      onTap: () {
                        postId = post['postId'];
                        widget.postClick();
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
            ),
            if (userData!['userId'] != post['userId'])
              followButton(post, isFollowed, userData!['userId'])
          ],
        ),
      ),
    );
  }

  Widget postContainerForMBl(post, userId) {
    var isFollowed = userData!['following'].toList().contains(post['userId']);
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
                      widget.seeUserProfileClick();
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
                if (userData!['userId'] != post['userId'])
                  followButton(post, isFollowed, userData!['userId'])
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
                ),
              ),
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                postId = post['postId'];
                widget.postClick();
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
          ),
        ),
      ),
    );
  }

  Widget followButton(post, bool isFollowed, myId) {
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
              ),
            ),
            child: Center(
              child: Text(
                isFollowed ? "Un Follow" : "Follow",
                style: TextStyle(
                    color: isFollowed ? Colors.white : buttonColor,
                    fontFamily: GoogleFonts.lato().fontFamily,
                    fontSize: 10),
              ),
            ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                        fontWeight: FontWeight.w600),
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
                          fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              postId = postID;
              widget.postClick();
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
                            fontWeight: FontWeight.w600)),
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
                          fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (isBookMarkContain) {
                removeFromBookMark(userData!['userId'], postID);
              } else {
                addToBookMark(userData!['userId'], postID);
              }
            },
            child: SizedBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    isBookMarkContain
                        ? "assets/like.png"
                        : "assets/bookmark.png",
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
                          fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickArticlemages() async {
    // uploadedProfileImage.clear();
    final completer = Completer<List<String>>();
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.accept = '.png,.jpg';
    uploadInput.click();
    // onChange doesn't work on mobile safari
    uploadInput.addEventListener('change', (e) async {
      final files = uploadInput.files;
      Iterable<Future<String>> resultsFutures = files!.map((file) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        // String extension = file.name.split('.').last.toLowerCase();
        reader.onError.listen((error) => completer.completeError(error));
        return reader.onLoad.first.then((_) => reader.result as String);
      });

      final results = await Future.wait(resultsFutures);
      completer.complete(results);
    });
    // need to append on mobile safari
    html.document.body!.append(uploadInput);
    var list = await completer.future;
    for (var i in list) {
      _allArticlesImages.add(i);
    }

    uploadInput.remove();

    setState(() {});
  }

  Future<List<String>> uploadFiles(List<String> images) async {
    List<String> imagesUrls = [];

    await Future.forEach(images, (image) async {
      firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;

      firebase_storage.Reference storageReference = storage
          .refFromURL("gs://proyecto-3c7e7.appspot.com")
          .child("Article_Images/ ${DateTime.now().toString()}");

      firebase_storage.UploadTask uploadTask = storageReference.putString(
          image.toString(),
          format: firebase_storage.PutStringFormat.dataUrl);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final url = await taskSnapshot.ref.getDownloadURL();

      imagesUrls.add(url);
    });

    return imagesUrls;
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
          profileImageUrl = userInfo.data()?['imageUrl'];
        });
      });
    }
  }

  Future<void> savePost(userData) async {
    setState(() {
      isLoading = true;
    });

    try {
      // var list = await uploadFiles(images);
      if (userData != null) {
        // Extract relevant user information
        var timeStamp = DateTime.now().millisecondsSinceEpoch;
        await firebaseFirestore
            .collection('Posts')
            .doc(timeStamp.toString())
            .set({
          "user": userData,
          "userId": userData['userId'],
          "postDetail": htmltext,
          "postType": "article",
          "isApproved": false,
          "timeStamp": timeStamp,
          "postId": timeStamp.toString(),
          "views": 1,
          "commentCount": 0,
          "likes": [],
          "bookMarks": []
        }).then((val) {
          htmlController.dispose;
          htmlController.setText('');
          setState(() {
            isLoading = false;
          });
        }).catchError((e) {
          setState(() {
            isLoading = false;
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getAllCategoriesList() async {
    firebaseFirestore
        .collection("ArticleCategory")
        .snapshots()
        .listen((allPostSnapshot) {
      allCategoriesList.clear();
      var initialModel =
          CategoryModel(catId: "0", catName: "ALL", isSelected: true);
      allCategoriesList.add(initialModel);
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        var model = CategoryModel(
            catId: post['categoryId'],
            catName: post['categoryName'],
            isSelected: false);
        allCategoriesList.add(model);
        setState(() {});
        //onlyCategoriesList.add(model);
      }
    });
  }

  Future<void> addToBookMark(userId, postId) async {
    if (userId != "") {
      try {
        FirebaseFirestore.instance.collection("Posts").doc(postId).update({
          "bookMarks": FieldValue.arrayUnion([userId.toString()])
        });
        // setState(() {});
      } catch (error) {
        //  print("Error retrieving user status data: $error");
      }
    }
  }

  Future<void> removeFromBookMark(userId, postId) async {
    if (userId != "") {
      try {
        FirebaseFirestore.instance.collection("Posts").doc(postId).update({
          "bookMarks": FieldValue.arrayRemove([userId.toString()])
        });
      } catch (error) {
        // print("Error retrieving user status data: $error");
      }
    }
  }

  Future<void> likeAction(userId, postId) async {
    if (userId != "") {
      try {
        FirebaseFirestore.instance.collection("Posts").doc(postId).update({
          "likes": FieldValue.arrayUnion([userId.toString()])
        });
      } catch (error) {
        //print("Error retrieving user status data: $error");
      }
    }
  }

  Future<void> unlikeAction(userId, postId) async {
    if (userId != "") {
      try {
        FirebaseFirestore.instance.collection("Posts").doc(postId).update({
          "likes": FieldValue.arrayRemove([userId.toString()])
        });
      } catch (error) {
        //
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

  Future<void> getAllArticles() async {
    firebaseFirestore
        .collection('Posts')
        .where("postType", isEqualTo: "article")
        .where("status", isEqualTo: "approved")
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .listen((allPostSnapshot) {
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

  void onTopicSelected(String topic) {
    if (topic == "0") {
      print("topic $topic");
      getAllArticles();
    } else {
      setState(() {
        selectedTopic = topic;
        getFilteredArticles(selectedTopic);
      });
    }
  }

  Future<void> getFilteredArticles(articleCategory) async {
    firebaseFirestore
        .collection('Posts')
        .where("postType", isEqualTo: "article")
        .where("status", isEqualTo: "approved")
        .orderBy("timeStamp", descending: true)
        .where("categoryId", isEqualTo: articleCategory)
        .snapshots()
        .listen((allPostSnapshot) {
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
}

class TopicListViewContainer extends StatefulWidget {
  final Function(String) onTopicSelected;
  final Function(bool) isTopicSideBarHide;
  final List<CategoryModel> allCategoriesList;
  const TopicListViewContainer(
      {super.key,
      required this.onTopicSelected,
      required this.allCategoriesList,
      required this.isTopicSideBarHide});

  @override
  State<TopicListViewContainer> createState() => _TopicListViewContainerState();
}

var isTopicSideBarHide = false;

class _TopicListViewContainerState extends State<TopicListViewContainer> {
  bool isHovered = false;

  final firebaseFirestore = FirebaseFirestore.instance;
  List<CategoryModel> allCategoriesList = [];
  @override
  void initState() {
    super.initState();
    allCategoriesList = widget.allCategoriesList;
  }

  @override
  Widget build(BuildContext context) {
    return topicListviewWidget();
  }

  Widget topicListviewWidget() {
    return Container(
      width: isTopicSideBarHide ? 40 : 175,
      height: height,
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
                widget.isTopicSideBarHide(isTopicSideBarHide);
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
                itemCount: allCategoriesList.length,
                itemBuilder: ((context, index) {
                  var data = allCategoriesList[index];
                  return MouseRegion(
                    child: GestureDetector(
                      onTap: () {
                        for (var i in allCategoriesList) {
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
}

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/Screens/UserSide/Article/create_article_screen.dart';
import 'package:proyecto/Screens/UserSide/Article/pdf_viewer_screen.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/Screens/UserSide/see_Images_screen.dart';
import 'package:proyecto/Views/comment_container.dart';
import 'package:proyecto/Views/feedback_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_iframe_plus/youtube_player_iframe_plus.dart'
    as y_tplus;

var sliderCurrentIndex = 0;
var sliderPDFCurrentIndex = 0;
var pdfData =
    "https://firebasestorage.googleapis.com/v0/b/proyecto-3c7e7.appspot.com/o/PDF_File%2F%202024-02-27%2016%3A59%3A01.540?alt=media&token=8540a9fe-1802-423f-97d4-023a45ac3cec";

class ArticleDetailScreen extends StatefulWidget {
  final Function postClick;

  const ArticleDetailScreen({super.key, required this.postClick});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
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
  bool isLoading = false;
  PdfController? pdfController;
  List<String> articleImages = [];

  bool isPlaying = false;
  y_tplus.YoutubePlayerController? controller;
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
    if (mounted) {
      // pdfController = PdfController(
      //     document:
      //         PdfDocument.openAsset("assets/file-example_PDF_500_kB.pdf"));
      fetchSinglePost();
      fetchUserDetail();
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
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: homeProfileContainer());
  }

  Widget homeProfileContainer() {
    return Scaffold(
      body: Column(
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
                                      singlePost?['user']['email'].toString() ??
                                          "",
                                      style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      )),
                                ],
                              ),
                            ]),
                          ),
                          Container(
                            margin:
                                const EdgeInsets.only(bottom: 20, right: 20),
                            padding: const EdgeInsets.only(
                                bottom: 10, right: 20, top: 10, left: 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(width: 1, color: buttonColor),
                                borderRadius: BorderRadius.circular(
                                  20,
                                )),
                            child: Center(
                                child: Text(
                              "Follow",
                              style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: buttonColor,
                                      fontSize: width * 0.009)),
                            )),
                          )
                        ]),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (isMobile == false && touchmatchMedia == false)
                      HtmlWidget(
                        singlePost?['postDetail'].toString() ?? "",
                        customWidgetBuilder: (element) {
                          if (element.localName == 'iframe') {
                            var src = element.attributes['src']!;
                            final videoId = src.split('/').last;

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
                            controller!.load(src);

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
                      htmlEditorControllerWidget(singlePost?['postDetail']),
                    if (width > 1067)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (articleImages.isNotEmpty)
                            Center(
                                child:
                                    CustomCarosalSlider(images: articleImages)),
                          const SizedBox(
                            width: 20,
                          ),
                          if (singlePost?['pdfFile'] != "" &&
                              pdfController != null)
                            PDFViewerScreen(
                              pdfURl: singlePost?['pdfFile'] ?? pdfData,
                            )
                        ],
                      ),
                    if (width < 1068)
                      Column(
                        children: [
                          if (articleImages.isNotEmpty)
                            Center(
                                child:
                                    CustomCarosalSlider(images: articleImages)),
                          const SizedBox(
                            height: 20,
                          ),
                          if (singlePost?['pdfFile'] != "" &&
                              pdfController != null)
                            PDFViewerScreen(
                              pdfURl: singlePost?['pdfFile'] ?? pdfData,
                            )
                        ],
                      ),
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

  void fetchSinglePostDetail(postid) {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postid)
        .snapshots()
        .listen((data) async {
      // setState(() {

      singlePost = data.data();
      articleImages =
          (singlePost?['imagesUrl'] as List<dynamic>).cast<String>().toList();

      postedUserimageUrl = data.data()?['user']['imageUrl'];
      var pdfData = data.data()?['pdfFile'];

      WidgetsBinding.instance.addPostFrameCallback(
        (Duration timeStamp) async {
          String url = pdfData;
          final Uri parsedUri = Uri.parse(url);

          try {
            final Response res = await http.get(
              parsedUri,
            );
            //res.cookie('key', 'value', { sameSite: 'None', secure: true });
            var doc = PdfDocument.openData(res.bodyBytes);
            pdfController = PdfController(document: doc);
            setState(() {});
          } catch (error) {
            print('Error during HTTP request: $error');
          }
        },
      );

      DateTime postDateTime =
          DateTime.fromMillisecondsSinceEpoch(data.data()?['timeStamp']);
      formattedTime = DateFormat.jm().format(postDateTime);
      formattedDate = DateFormat('MMM dd, y').format(postDateTime);
      if (mounted) {
        setState(() {});
      }
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

class CustomCarosalSlider extends StatefulWidget {
  final List<String> images;
  const CustomCarosalSlider({super.key, required this.images});

  @override
  State<CustomCarosalSlider> createState() => _CustomCarosalSliderState();
}

class _CustomCarosalSliderState extends State<CustomCarosalSlider>
    with TickerProviderStateMixin {
  List<String> articleImages = [];
  late AnimationController _animationController;
  late Animation<double> _fadeInOutAnimation;
  late PageController pageController = PageController();
  var hideButton = true;
  var currentIndex = 0;
  var isMobile = false;

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }

    articleImages = widget.images;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeInOutAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return showImageCarouselSlider();
  }

  Widget showImageCarouselSlider() {
    return MouseRegion(
      onEnter: (event) {
        _animationController.forward();

        // setState(() {
        //   hideButton = true;
        // });
      },
      onExit: (event) {
        // _animationController.reverse();

        // setState(() {});
      },
      child: Container(
        width: isMobile ? 360 : 400,
        height: isMobile ? 460 : 470,
        color: Colors.grey.withOpacity(0.2),
        child: Stack(
          children: [
            Center(
              child: pageViewController(articleImages),
            ),
            if (hideButton == true && currentIndex < articleImages.length - 1)
              Align(
                alignment: Alignment.centerRight,
                child: FadeTransition(
                  opacity: _fadeInOutAnimation,
                  child: GestureDetector(
                    onTap: () {
                      if (currentIndex < articleImages.length) {
                        //  carouselController.nextPage();
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                      setState(() {
                        currentIndex++;
                        sliderCurrentIndex = currentIndex;
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: const BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ),
            if (hideButton == true && currentIndex > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: FadeTransition(
                  opacity: _fadeInOutAnimation,
                  child: GestureDetector(
                    onTap: () {
                      if (currentIndex >= 1) {
                        pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);

                        //carouselController.previousPage();
                        setState(() {
                          currentIndex--;
                          sliderCurrentIndex = currentIndex;
                        });
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle),
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.only(left: 5),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (hideButton == true)
              Align(
                alignment: Alignment.bottomCenter,
                child: FadeTransition(
                  opacity: _fadeInOutAnimation,
                  child: Container(
                    height: 40,
                    color: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${currentIndex + 1}/ ${articleImages.length}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        SliderTheme(
                          data: const SliderThemeData(
                            trackHeight: 1,
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 8.0),
                          ),
                          child: Slider(
                            value: currentIndex.toDouble(),
                            secondaryTrackValue: currentIndex.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                currentIndex = value.toInt();
                                pageController.animateToPage(currentIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.bounceInOut);
                              });
                            },
                            min: 0,
                            max: articleImages.length.toDouble() - 1,
                            activeColor: Colors.white,
                            inactiveColor: Colors.grey,
                            thumbColor: Colors.white,
                            autofocus: true,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            html.document.documentElement!.requestFullscreen();
                            navigateToFullCarouselSliderScreen();
                          },
                          child: Container(
                            width: 30,
                            height: 20,
                            margin: const EdgeInsets.only(right: 10),
                            child: Image.asset(
                              "assets/fullscreen.png",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget pageViewController(images) {
    return SizedBox(
      width: isMobile ? 360 : 500,
      height: isMobile ? 460 : 550,
      child: PageView(
        controller: pageController,
        restorationId: "$currentIndex",
        onPageChanged: (value) {
          currentIndex = value.toInt();
          setState(() {});
        },
        children: List.generate(images.length, (index) {
          var data = images[index];
          return Container(
            width: 390,
            height: 550,
            padding: const EdgeInsets.all(8),
            child: Image.network(data, fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
          );
        }),
      ),
    );
  }

  void navigateToFullCarouselSliderScreen() async {
    int? returnedIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullCarouselSliderScreen(
          imagesList: articleImages,
          currentIndex: currentIndex, // Pass the current index
        ),
      ),
    );

    if (returnedIndex != null) {
      setState(() {
        currentIndex = returnedIndex;
      });
      pageController.jumpToPage(currentIndex);
    }
  }
}

class PDFViewerScreen extends StatefulWidget {
  final String pdfURl;
  const PDFViewerScreen({super.key, required this.pdfURl});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInOutAnimation;
  PdfController? pdfController;
  var hideButton = true;
  var isMobile = false;
  var currentIndex = 1;
  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeInOutAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.reverse();
    initializePDFController();
  }

  void initializePDFController() async {
    String url = widget.pdfURl;
    final Uri parsedUri = Uri.parse(url);

    try {
      final Response res = await http.get(
        parsedUri,
      );
      //res.cookie('key', 'value', { sameSite: 'None', secure: true });
      var doc = PdfDocument.openData(res.bodyBytes);
      pdfController = PdfController(document: doc, initialPage: currentIndex);
      setState(() {});
      print("callinitializePDFController , $currentIndex");
    } catch (error) {
      print('Error during HTTP request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return showPDFViewer();
  }

  Widget showPDFViewer() {
    return MouseRegion(
      onEnter: (event) {
        _animationController.forward();

        // setState(() {
        //   hideButton = true;
        // });
      },
      onExit: (event) {
        // _animationController.reverse();

        // setState(() {});
      },
      child: Container(
        width: isMobile ? 360 : 400,
        height: isMobile ? 460 : 470,
        color: Colors.grey.withOpacity(0.2),
        child: SizedBox(
          width: 400,
          height: 500,
          child: pdfController != null
              ? PdfPageNumber(
                  controller: pdfController!,
                  builder: (context, state, page, pagesCount) {
                    var pagesCounts = pagesCount ?? 1;
                    return Container(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Center(
                            child: PdfView(
                              controller: pdfController!,
                              physics: const NeverScrollableScrollPhysics(),
                              onPageChanged: (page) {},
                              onDocumentLoaded: (document) {},
                              onDocumentError: (error) {},
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, right: 10),
                              child: Text(
                                '$page/${pagesCount ?? 0}',
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          if (hideButton == true && currentIndex < pagesCounts)
                            Align(
                              alignment: Alignment.centerRight,
                              child: FadeTransition(
                                opacity: _fadeInOutAnimation,
                                child: GestureDetector(
                                  onTap: () {
                                    if (currentIndex < pagesCounts) {
                                      //  carouselController.nextPage();
                                      pdfController!.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                    setState(() {
                                      currentIndex++;
                                      sliderPDFCurrentIndex = currentIndex;
                                    });
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (hideButton == true && currentIndex > 1)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FadeTransition(
                                opacity: _fadeInOutAnimation,
                                child: GestureDetector(
                                  onTap: () {
                                    if (currentIndex > 1) {
                                      pdfController!.previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut);

                                      //carouselController.previousPage();
                                      setState(() {
                                        currentIndex--;
                                        sliderPDFCurrentIndex = currentIndex;
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle),
                                    margin: const EdgeInsets.only(left: 10),
                                    padding: const EdgeInsets.only(left: 5),
                                    child: const Center(
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (hideButton == true)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: FadeTransition(
                                opacity: _fadeInOutAnimation,
                                child: Container(
                                  height: 40,
                                  color: Colors.black.withOpacity(0.6),
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${currentIndex}/ $pagesCounts",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      SliderTheme(
                                        data: const SliderThemeData(
                                          trackHeight: 1,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 8.0),
                                        ),
                                        child: Slider(
                                          value: currentIndex.toDouble(),
                                          secondaryTrackValue:
                                              currentIndex.toDouble(),
                                          onChanged: (value) {
                                            setState(() {
                                              currentIndex = value.toInt();
                                              pdfController!.animateToPage(
                                                  currentIndex,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.bounceInOut);
                                            });
                                          },
                                          min: 1,
                                          max: pagesCounts.toDouble(),
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.grey,
                                          thumbColor: Colors.white,
                                          autofocus: true,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          html.document.documentElement!
                                              .requestFullscreen();
                                          navigateToFullCarouselSliderScreen(
                                              pagesCounts);
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 20,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: Image.asset(
                                            "assets/fullscreen.png",
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                )
              : const Center(
                  child:
                      CircularProgressIndicator()), // or some loading indicator
        ),
      ),
    );
  }

  void navigateToFullCarouselSliderScreen(int pagesCounts) async {
    int? returnedIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullPDFViewerScreen(
          key: pdfViewerKey,
          pagesCounts: pagesCounts,
          currentIndex: currentIndex,
          pdfUrl: widget.pdfURl,

          isBytesAvaiable: false,

          // Pass the current index
        ),
      ),
    );

    // Handle returnedIndex when it returns
    if (returnedIndex != null) {
      currentIndex = returnedIndex;

      setState(() {});
      pdfController!.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

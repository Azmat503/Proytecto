import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/Screens/UserSide/see_Images_screen.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtube_player_iframe_plus/youtube_player_iframe_plus.dart'
    as YTPlus;

import 'dart:html' as html;
//import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

final List<String> _allArticlesImages = [];
final GlobalKey<_PDFViewerWidgetState> pdfFViewerWidgetKey = GlobalKey();

class CreateArticleContainer extends StatefulWidget {
  final Function onBackPressed;
  const CreateArticleContainer({super.key, required this.onBackPressed});

  @override
  State<CreateArticleContainer> createState() => _CreateArticleContainerState();
}

class _CreateArticleContainerState extends State<CreateArticleContainer>
    with TickerProviderStateMixin {
  List<String> articleCategories = [
    'Technology',
    'Science',
    'Health',
    'Travel',
    'Sports',
    'Fashion',
    'Food',
    'Business',
  ];
  final QuillEditorController htmlController = QuillEditorController();
  final CarouselController carouselController = CarouselController();
  late PageController pageController = PageController();
  late TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  var isMobile = false;
  var isTopicSideBarHide = false;
  var pdfIsAdded = false;
  var pdfFilePath = [];
  var bytes;
  var isLoading = false;
  var firebaseFirestore = FirebaseFirestore.instance;
  var hideButton = false;
  var currentIndex = 0;
  var htmltext = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic>? userData;
  var articleName = "";
  var isYoutube = false;

  late PdfController? pdfController;

  @override
  void initState() {
    super.initState();

    hideButton = false;
    user = auth.currentUser;

    if (foundation.defaultTargetPlatform == TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }

    getUserData();
    getCategoriesList();
  }

  bool isYouTubeLink(String link) {
    // Regular expression for matching YouTube video URLs
    RegExp youtubeRegex = RegExp(
      r'^https?:\/\/(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );

    return youtubeRegex.hasMatch(link);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: pdfIsAdded ? height + 420 : height,
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField(
            //   controller: textEditingController,
            //   onChanged: (value) {
            //     isYoutube = isYouTubeLink(textEditingController.text);
            //     setState(() {});
            //   },
            // ),
            navigatioBarContainer(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // if (isYoutube == true) youtubePlayerWidget(),

                    // if (_allArticlesImages.isNotEmpty)
                    //   ImagesRowWidget(
                    //     list: _allArticlesImages,
                    //     isMobile: isMobile,
                    //     key: UniqueKey(),
                    //   ),
                    //allArticlesImagesListView(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  pickArticPdf();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: postButtonColor,
                                  ),
                                  child: const Center(
                                      child: Icon(
                                    Icons.picture_as_pdf,
                                    size: 20,
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
                            margin:
                                const EdgeInsets.only(bottom: 20, right: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: postColor),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        if (!isLoading)
                          GestureDetector(
                            onTap: () async {
                              var text = await htmlController.getText();
                              htmltext = text;
                              if (htmltext != "") {
                                savePost(userData, pdfFilePath);
                              }
                            },
                            child: Container(
                              width: 74,
                              height: 40,
                              margin:
                                  const EdgeInsets.only(bottom: 20, right: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: buttonColor),
                              child: const Center(
                                child: Text("Post"),
                              ),
                            ),
                          ),
                      ],
                    ),
                    htmlEditorContainerWidget(),
                    const SizedBox(
                      height: 20,
                    ),
                    if (pdfFilePath.isNotEmpty)
                      Center(
                        child: SizedBox(
                          width: 445,
                          height: 420,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                    onTap: () {
                                      pdfFilePath.clear();

                                      setState(() {});
                                    },
                                    child: Container(
                                        width: 25,
                                        height: 25,
                                        margin: const EdgeInsets.only(top: 0),
                                        decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            shape: BoxShape.circle),
                                        child: const Center(
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                          ),
                                        ))),
                              ),
                              PDFViewerWidget(
                                //key: UniqueKey(),
                                bytes: bytes,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
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

  Widget youtubePlayerWidget() {
    return Container();
    //YoutubeVideoPlayer(videoUrl: textEditingController.text);
  }

  Widget navigatioBarContainer() {
    return Container(
      width: width,
      height: 50,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(
        left: 20,
      ),
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
                        selectedIndex = previousSelectedIndex;
                        widget.onBackPressed();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 15.0,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Text("Create  Article ",
                        style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold))),
                  ]),
                )
              ]),
            ),
          ]),
    );
  }

  Widget htmlEditorContainerWidget() {
    //  print(" height - (height * 0.18) = ${height - (height * 0.18)}");
    return SizedBox(
      height: height * 0.82,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 10,
          ),
          topicListviewWidget(),
          Expanded(
            child: SizedBox(
              width: isTopicSideBarHide ? width - 180 : width - 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: ToolBar(
                      toolBarColor: Colors.cyan.shade50,
                      activeIconColor: Colors.green,
                      padding: const EdgeInsets.all(8),
                      iconSize: 20,
                      controller: htmlController,
                      toolBarConfig: const [
                        ToolBarStyle.bold,
                        ToolBarStyle.background,
                        ToolBarStyle.align,
                        ToolBarStyle.underline,
                        ToolBarStyle.color,
                        ToolBarStyle.directionLtr,
                        ToolBarStyle.directionRtl,
                        ToolBarStyle.headerOne,
                        ToolBarStyle.headerTwo,
                        ToolBarStyle.italic,
                        ToolBarStyle.size,
                        ToolBarStyle.clearHistory,
                        ToolBarStyle.image,
                        ToolBarStyle.video,
                        ToolBarStyle.link,
                        ToolBarStyle.listBullet,
                        ToolBarStyle.listOrdered,
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, bottom: 20),
                      margin: const EdgeInsets.only(right: 20),
                      color: Colors.white,
                      height: 440,
                      child: QuillHtmlEditor(
                        controller: htmlController,
                        hintText: "",
                        onTextChanged: (p0) {},
                        hintTextStyle: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                fontFamily: "Lato",
                                fontSize: 10,
                                fontWeight: FontWeight.normal)),
                        minHeight: 440,
                        isEnabled: true,
                        autoFocus: true,
                        textStyle: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              fontFamily: "Lato",
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topicListviewWidget() {
    return Container(
      width: isTopicSideBarHide ? 40 : 175,
      height: height * 0.79,
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
                ),
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          if (!isTopicSideBarHide)
            Expanded(
              child: ListView.builder(
                itemCount: onlyCategoriesList.length,
                itemBuilder: ((context, index) {
                  var data = onlyCategoriesList[index];

                  return MouseRegion(
                    onEnter: (_) => setState(() => data.isHover = true),
                    onExit: (_) => setState(() => data.isHover = false),
                    child: GestureDetector(
                      onTap: () {
                        for (var i in onlyCategoriesList) {
                          i.isSelected = false;
                        }
                        articleName = data.catId;
                        data.isSelected = true;
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

  Widget allArticlesImagesListView() {
    return SizedBox(
      height: 150,
      width: isMobile ? width - 20 : width - 190,
      child: ListView.builder(
        itemCount: _allArticlesImages.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var data = _allArticlesImages[index];
          return Container(
            width: isMobile ? 90 : 100,
            margin: const EdgeInsets.only(left: 10),
            child: Stack(
              children: [
                Image.network(
                  data,
                  fit: BoxFit.fill,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                      onTap: () {
                        _allArticlesImages.removeAt(index);
                        setState(() {});
                      },
                      child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                              color: Colors.grey, shape: BoxShape.circle),
                          child: const Center(
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ))),
                )
              ],
            ),
          );
        },
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

  Future<void> pickArticPdf() async {
    pdfFilePath.clear();
    bytes = null;
    pdfController = null;
    final completer = Completer<List<String>>();
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.accept = '.pdf';
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
    pdfFilePath = await completer.future;
    uploadInput.remove();
    var editedBytes = base64Decode(pdfFilePath[0].split(',')[1]);
    bytes = editedBytes;
    // print("pdfFilePath[0] , ${pdfFilePath[0]}, bytes $bytes , ");
    var pdfDocument = PdfDocument.openData(bytes!);
    pdfController = PdfController(document: pdfDocument);
    pdfIsAdded = true;
    setState(() {});
    scrollController.animateTo(scrollController.position.maxScrollExtent + 420,
        duration: const Duration(milliseconds: 400), curve: Curves.ease);
  }

  Future<void> savePost(userInfo, pdfFilePath) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (userInfo != null) {
        // Extract relevant user information
        var list = [];
        var pdfFile = '';

        if (pdfFilePath.isNotEmpty) {
          pdfFile = await uploadPdfFile(pdfFilePath[0]);
        }

        var timeStamp = DateTime.now().millisecondsSinceEpoch;
        await firebaseFirestore
            .collection('Posts')
            .doc(timeStamp.toString())
            .set({
          "user": userInfo,
          "userId": userInfo['userId'],
          "imagesUrl": list,
          "postDetail": htmltext,
          "postType": "article",
          "status": "pending",
          "timeStamp": timeStamp,
          "postId": timeStamp.toString(),
          "views": 1,
          "commentCount": 0,
          "likes": [],
          "bookMarks": [],
          "categoryId": articleName,
          "pdfFile": pdfFile
        }).then((val) {
          htmlController.dispose;
          htmlController.setText('');
          setState(() {
            isLoading = false;

            widget.onBackPressed();
          });
        }).catchError((e) {
          print("Error == $e");
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

  Future<List<String>> uploadFiles(List<String> images) async {
    List<String> imagesUrls = [];

    await Future.forEach(images, (image) async {
      firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;

      firebase_storage.Reference storageReference = storage
          .refFromURL("gs://proyecto-3c7e7.appspot.com")
          .child("Event_Images/ ${DateTime.now().toString()}");

      firebase_storage.UploadTask uploadTask = storageReference.putString(
          image.toString(),
          format: firebase_storage.PutStringFormat.dataUrl);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final url = await taskSnapshot.ref.getDownloadURL();

      imagesUrls.add(url);
    });

    return imagesUrls;
  }

  Future<String> uploadPdfFile(String pdfFile) async {
    String url = "";

    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    firebase_storage.Reference storageReference = storage
        .refFromURL("gs://proyecto-3c7e7.appspot.com")
        .child("PDF_File/ ${DateTime.now().toString()}");

    firebase_storage.UploadTask uploadTask = storageReference.putString(
        pdfFile.toString(),
        format: firebase_storage.PutStringFormat.dataUrl);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    url = await taskSnapshot.ref.getDownloadURL();

    return url;
  }
}

class YoutubeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final YTPlus.YoutubePlayerController controller;
  final Function(int) videoPressed;
  final int index;
  const YoutubeVideoPlayer(
      {super.key,
      required this.videoUrl,
      required this.controller,
      required this.videoPressed,
      required this.index});

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  var hideThumbnail = false;
  late YTPlus.YoutubePlayerController _controller;
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
    print(
        "Video Id ${widget.videoUrl}, getThumbnail ${YTPlus.YoutubePlayerController.getThumbnail(videoId: widget.videoUrl, quality: ThumbnailQuality.high)}");
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.black),
        // padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            if (!hideThumbnail)
              GestureDetector(
                onTap: () {
                  // hideThumbnail = true;
                  //setState(() {});
                },
                child: Center(
                  child: Image.network(
                    YTPlus.YoutubePlayerController.getThumbnail(
                        videoId: widget.videoUrl,
                        quality: ThumbnailQuality.high),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            if (!hideThumbnail)
              GestureDetector(
                onTap: () {
                  hideThumbnail = true;
                  widget.videoPressed(widget.index);

                  setState(() {});
                },
                child: Center(
                  child: Container(
                      width: 50,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      )),
                ),
              ),
            if (hideThumbnail)
              Center(
                child: VisibilityDetector(
                  key: Key(widget.videoUrl),
                  onVisibilityChanged: (visibilityInfo) {
                    if (visibilityInfo.visibleFraction <= 0.5) {
                      hideThumbnail = false;
                      widget.controller.pause();
                      setState(() {});
                    }
                  },
                  child: YTPlus.YoutubePlayerIFramePlus(
                    controller: widget.controller,
                    aspectRatio: 16 / 9,
                  ),
                ),
              ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }
}

class PDFViewerWidget extends StatefulWidget {
  final Uint8List bytes;
  const PDFViewerWidget({super.key, required this.bytes});

  @override
  State<PDFViewerWidget> createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget>
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
    if (foundation.defaultTargetPlatform == TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
      hideButton = false;
    } else {
      isMobile = false;
      hideButton = true;
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
    // final Uri parsedUri = Uri.parse(url);

    try {
      //print();
      var pdfDocument = PdfDocument.openData(widget.bytes);
      pdfController = PdfController(
        document: pdfDocument,
        initialPage: currentIndex,
      );
      print("callinitializePDFController , $currentIndex");
      if (mounted) {
        setState(() {});
      }
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
        width: 420,
        height: 420,
        color: Colors.grey.withOpacity(0.2),
        child: SizedBox(
          width: 400,
          height: 400,
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
                              onDocumentError: (error) {
                                print("Error Occurred $error");
                              },
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
                                        "$currentIndex/ $pagesCounts",
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
    print("currentIndex  $currentIndex");
    int? returnedIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullPDFViewerScreen(
          key: pdfFViewerWidgetKey,
          pagesCounts: pagesCounts,
          currentIndex: currentIndex,
          pdfUrl: "",
          bytes: widget.bytes,
          isBytesAvaiable: true,
          // Pass the current index
        ),
      ),
    );

    // Handle returnedIndex when it returns
    if (returnedIndex != null) {
      if (mounted) {
        setState(() {
          currentIndex = returnedIndex;
        });
      }
      print("returnedIndex $returnedIndex");
      pdfController!.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

class ImagesRowWidget extends StatefulWidget {
  final bool isMobile;
  final List<String> list;
  const ImagesRowWidget(
      {super.key, required this.list, required this.isMobile});

  @override
  State<ImagesRowWidget> createState() => _ImagesRowWidgetState();
}

class _ImagesRowWidgetState extends State<ImagesRowWidget> {
  @override
  Widget build(BuildContext context) {
    return allArticlesImagesListView();
  }

  Widget allArticlesImagesListView() {
    return SizedBox(
      height: 150,
      width: widget.isMobile ? width - 20 : width - 190,
      child: ListView.builder(
        itemCount: _allArticlesImages.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var data = _allArticlesImages[index];
          return Container(
            width: widget.isMobile ? 90 : 100,
            margin: const EdgeInsets.only(left: 10),
            child: Stack(
              children: [
                Image.network(
                  data,
                  fit: BoxFit.fill,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                      onTap: () {
                        _allArticlesImages.removeAt(index);
                        setState(() {});
                      },
                      child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                              color: Colors.grey, shape: BoxShape.circle),
                          child: const Center(
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ))),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

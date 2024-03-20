import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:async';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:html' as html;

class StudyModel {
  String chapterName = "ALL";
  String chapterId = "0";
  String htmlText = "";
  bool isHover = false;
  bool isSelected = false;
  String videoUrl = "";
  List<String> previousHtmlTexts = [];

  StudyModel(
      {required this.chapterId,
      required this.chapterName,
      required this.htmlText,
      required this.isHover,
      required this.videoUrl,
      required this.isSelected});
}

class WriteStudyDetailScreen extends StatefulWidget {
  final Function onBackPressed;
  const WriteStudyDetailScreen({super.key, required this.onBackPressed});

  @override
  State<WriteStudyDetailScreen> createState() => _WriteStudyDetailScreenState();
}

class _WriteStudyDetailScreenState extends State<WriteStudyDetailScreen> {
  final QuillEditorController htmlController = QuillEditorController();
  late PageController pageController = PageController();
  late TextEditingController textEditingController = TextEditingController();
  var isMobile = false;
  var isTopicSideBarHide = false;
  final List<String> _allArticlesImages = [];

  var isLoading = false;
  var isImageLoading = false;
  var firebaseFirestore = FirebaseFirestore.instance;
  var hideButton = false;
  var currentIndex = 0;
  var htmltext = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic>? userData;
  var articleName = "";
  var isYoutube = false;
  List<StudyModel> chapterrList = [];
  var imageUrl = "";
  var selectedIndex = 0;
  late PdfController? pdfController;
  var pdfFilePath = [];
  var bytes;
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
    chapterrList.clear();
    if (chapterList.isNotEmpty) {
      for (var i in chapterList) {
        var chapterId = DateTime.now().millisecondsSinceEpoch;
        var model = StudyModel(
            chapterName: i,
            chapterId: chapterId.toString(),
            isSelected: false,
            htmlText: "",
            videoUrl: "",
            isHover: false);

        chapterrList.add(model);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: height,
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
                child: Column(
                  children: [
                    htmlEditorContainerWidget(),
                    if (_allArticlesImages.isNotEmpty)
                      allArticlesImagesListView(),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  //pickArticlemages();
                                  var list = await pickArticlemages();
                                  chapterrList[selectedIndex].videoUrl =
                                      list.first;
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, bottom: 20),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: postButtonColor,
                                  ),
                                  child: (isImageLoading == false)
                                      ? Center(
                                          child: Image.asset(
                                          "assets/gallery.png",
                                          width: 13,
                                          height: 13,
                                        ))
                                      : const Center(
                                          child: CircularProgressIndicator()),
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
                              bool isAnyEmpty = false;

                              for (var i in chapterrList) {
                                if (i.htmlText.isEmpty) {
                                  isAnyEmpty = true;
                                  break;
                                }
                              }

                              if (isAnyEmpty) {
                              } else {
                                savePost(userData, _allArticlesImages);
                              }

                              if (htmltext != "") {}
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
                    Text("Write Study ",
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
                        ToolBarStyle.listOrdered
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 20, left: 20),
                      color: Colors.white,
                      height: 440,
                      child: QuillHtmlEditor(
                        controller: htmlController,
                        hintText: "",
                        hintTextStyle: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                fontFamily: "Lato",
                                fontSize: 10,
                                fontWeight: FontWeight.normal)),
                        minHeight: 440,
                        isEnabled: true,
                        autoFocus: true,
                        onTextChanged: (value) {
                          chapterrList[selectedIndex].htmlText = value;
                          setState(() {});
                        },
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
                itemCount: chapterrList.length,
                itemBuilder: ((context, index) {
                  var data = chapterrList[index];

                  return MouseRegion(
                    child: GestureDetector(
                      onTap: () async {
                        selectedIndex = index;
                        for (var i in chapterrList) {
                          i.isSelected = false;
                        }
                        data.isSelected = true;
                        htmlController.setText(data.htmlText);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          data.chapterName,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: (data.isHover || data.isSelected)
                                  ? buttonColor
                                  : Colors.white,
                              fontSize:
                                  (data.isHover || data.isSelected) ? 16 : 14,
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

    setState(() {});
  }

  Future<List<String>> pickArticlemages() async {
    // uploadedProfileImage.clear();
    final completer = Completer<List<String>>();
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.accept = '.mp4';
    uploadInput.click();

    // onChange doesn't work on mobile safari
    uploadInput.addEventListener('change', (e) async {
      final files = uploadInput.files;
      setState(() {
        isImageLoading = true;
      });
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
    // onChange doesn't work on mobile safari
    uploadInput.addEventListener('cancel', (e) async {
      setState(() {
        isImageLoading = false;
      });
    });
    // need to append on mobile safari
    html.document.body!.append(uploadInput);

    var list = await completer.future;
    for (var i in list) {
      _allArticlesImages.add(i);
    }
    uploadInput.remove();

    var video = await uploadFiles(_allArticlesImages);
    setState(() {
      isImageLoading = false;
    });
    return video;
  }

  Future<void> savePost(userInfo, images) async {
    try {
      if (userInfo != null) {
        // Extract relevant user information

        var timeStamp = DateTime.now().millisecondsSinceEpoch;
        await firebaseFirestore
            .collection('Studies')
            .doc(timeStamp.toString())
            .set({
          "Study Name": studyTitle,
          "user": userInfo,
          "studyId": timeStamp.toString(),
          "joinedUsers": [],
          "commentCount": "0",
          "userId": userInfo['userId']
        }).then((value) async {
          for (var i in chapterrList) {
            var timeStamp2 = DateTime.now().millisecondsSinceEpoch;
            await firebaseFirestore
                .collection('Studies')
                .doc(timeStamp.toString())
                .collection("Chapters")
                .doc(timeStamp2.toString())
                .set({
              "chapterName": i.chapterName,
              "chapterId": timeStamp2.toString(),
              "chapterDetail": i.htmlText,
              "videoUrl": i.videoUrl,
              "timeStamp": timeStamp2,
            }).then((value) {
              print("succes");
            }).catchError((error) {
              print(error);
            });
          }
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
      print(error);
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

  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Empty Entry'),
          content: Text(message),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

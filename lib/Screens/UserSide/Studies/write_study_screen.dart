import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:html' as html;

class WriteStudyScreen extends StatefulWidget {
  final Function onBackPressed;
  final Function nextButtonPressed;
  const WriteStudyScreen({
    super.key,
    required this.onBackPressed,
    required this.nextButtonPressed,
  });

  @override
  State<WriteStudyScreen> createState() => _WriteStudyScreenState();
}

class _WriteStudyScreenState extends State<WriteStudyScreen> {
  final QuillEditorController htmlController = QuillEditorController();
  TextEditingController searchTextController = TextEditingController();
  TextEditingController chapterNameTextController = TextEditingController();

  bool isVideoTutorial = false;
  var htmltext = "";
  var isLoading = false;
  final List<String> _allArticlesImages = [];
  String profileImageUrl = "";
  User? user;
  Map<String, dynamic>? userData;
  var isMobile = false;
  final firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();

    if (foundation.defaultTargetPlatform == TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }
    user = auth.currentUser;
    touchmatchMedia = html.window.matchMedia('(pointer: coarse)').matches;
    getUserData();
    // getAllCategoriesList();
    //  getAllArticles();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              //  alignment: Alignment.topCenter,
              width: width,
              color: Colors.white,
              padding: const EdgeInsets.only(left: 25, bottom: 20, top: 20),
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
                                    selectedIndex = 3;
                                    textEditingControllerList.clear();
                                    textEditingControllerList = [
                                      TextEditingController()
                                    ];
                                    widget.onBackPressed();
                                  },
                                  child: Image.asset(
                                    "assets/back.png",
                                    width: 15,
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Text("Write Study Page",
                                    style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold))),
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
                        style: GoogleFonts.lato(
                            textStyle: TextStyle(fontSize: width * 0.01)),
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
            SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                      child: Container(
                    width: 500,
                    height: height - 170,
                    margin: const EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 20),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        //height: height - 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                            width: 16,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userData?['email'] ??
                                                    "@RiccardioVicidomi",
                                                style: GoogleFonts.lato(
                                                    textStyle: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                userData?['name'] ??
                                                    "Donde se forjan las ideas",
                                                style: GoogleFonts.lato(
                                                    textStyle: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ]),
                            const SizedBox(
                              height: 10,
                            ),
                            customStudyTextField(
                                "Study Title", chapterNameTextController),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Add Chapter",
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    TextEditingController controller =
                                        TextEditingController();
                                    textEditingControllerList.add(controller);
                                    setState(() {});
                                  },
                                  child: const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.add),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ListView.builder(
                              itemCount: textEditingControllerList.length,
                              primary: false,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var controller =
                                    textEditingControllerList[index];
                                return Column(
                                  children: [
                                    customStudyTextField(
                                        "Chapter Name", controller),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        bool isAnyEmpty = false;

                        for (var i in textEditingControllerList) {
                          if (i.text.isEmpty) {
                            isAnyEmpty = true;
                            break;
                          }
                        }

                        if (isAnyEmpty) {
                          // Show alert because at least one entry is empty
                          showAlertDialog(
                              'Please fill in all entries before proceeding.');
                        } else {
                          if (chapterNameTextController.text != "") {
                            // No empty entries, proceed to the next screen
                            for (var i in textEditingControllerList) {
                              chapterList.add(i.text);
                            }
                            studyTitle = chapterNameTextController.text;
                            widget.nextButtonPressed();
                          } else {
                            showAlertDialog('Please enter Study name');
                          }
                        }
                      },
                      child: Container(
                        width: 200,
                        height: 40,
                        padding: const EdgeInsets.only(right: 20, left: 20),
                        //  margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(
                              20,
                            )),
                        child: Center(
                            child: Text(
                          "Next",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        )),
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

  Widget customStudyTextField(String label, TextEditingController controller) {
    return Container(
      width: 500,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(50 / 2)),
      child: TextField(
        controller: controller,
        cursorHeight: 12,
        style: GoogleFonts.lato(
            textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        )),
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: label,
        ),
      ),
    );
  }

  Widget htmlEditorContainerWidget() {
    return SingleChildScrollView(
      child: SizedBox(
        width: (width * 0.7),
        height: height,
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
                  ToolBarStyle.link,
                  ToolBarStyle.listBullet,
                  ToolBarStyle.listOrdered
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 20, left: 10),
              margin: const EdgeInsets.only(
                right: 20,
              ),
              color: Colors.white,
              //width: width * 0.65,
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
                textStyle: GoogleFonts.lato(
                  textStyle: const TextStyle(
                      fontFamily: "Lato",
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
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
                        onTap: () {
                          pickVideos();
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
                        // savePost(userData, _allArticlesImages);
                      }
                    },
                    child: Container(
                      width: 74,
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 20, right: 20),
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
    );
  }

  Future<void> pickVideos() async {
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

  Future<void> getUserData() async {
    if (user != null) {
      var userId = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId.toString())
          .snapshots()
          .listen((userInfo) {
        profileImageUrl = userInfo.data()?['imageUrl'];
        userData = userInfo.data();
        if (mounted) {
          setState(() {});
        }
      });
    }
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../Event/event_screen.dart';

class StoryMakerScreen extends StatefulWidget {
  final bool isImageStatus;
  final String imageString;
  const StoryMakerScreen(
      {super.key, required this.isImageStatus, required this.imageString});

  @override
  State<StoryMakerScreen> createState() => _StoryMakerScreenState();
}

class _StoryMakerScreenState extends State<StoryMakerScreen> {
  TextEditingController textEditingController = TextEditingController();
  Color color = Colors.black;
  Color textColor = Colors.white;
  TextStyle selectedTetStyle = GoogleFonts.roboto();
  final List<Color> colorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
  ];

  List<String> fontFamilies = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Pacifico',
    'Dancing Script',
    'Playfair Display',
    'Raleway',
    'Caveat',
  ];
  List<Color> textColorList = [];
  FocusNode textFocusNode = FocusNode();
  var selectedIndex = 0;
  var selectedFontIndex = 0;
  ScreenshotController screenshotController = ScreenshotController();
  var isImageStatus = false;
  var imageString = "";
  var isTextAllowed = false;
  @override
  void initState() {
    super.initState();
    color = colorList[0];
    textColorList = colorList.reversed.toList();
    isImageStatus = widget.isImageStatus;
    imageString = widget.imageString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: isImageStatus ? Colors.black : color,
        padding:
            const EdgeInsets.only(right: 40.0, top: 20, left: 20, bottom: 20),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isImageStatus) {
                        saveImageStatus();
                      } else {
                        captureScreenshot();
                      }
                    },
                    child: const Text(
                      "Share Story",
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  if (!isImageStatus)
                    GestureDetector(
                      onTap: () {
                        selectedIndex = selectedIndex + 1;

                        color = colorList[selectedIndex];
                        if (selectedIndex == 9) {
                          selectedIndex = 0;
                        }
                        setState(() {});
                      },
                      child: Image.asset(
                        "assets/colorPalette.png",
                        color: Colors.white,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTapDown: (detail) {
                      emojiPickerContainer(context, detail);
                    },
                    child: Center(
                        child: Image.asset(
                      "assets/emoji.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    )),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isImageStatus) {
                        isTextAllowed = !isTextAllowed;
                        setState(() {});
                      } else {
                        selectedFontIndex = selectedFontIndex + 1;
                        if (selectedFontIndex == 8) {
                          selectedFontIndex = 0;
                        }
                        setState(() {});
                      }
                    },
                    child: const Text(
                      "T",
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          if (!isImageStatus)
            RepaintBoundary(
              key: GlobalKey(),
              child: SizedBox(
                width: width,
                height: height - 100,
                child: textStoryMaker(),
              ),
            ),
          if (imageString.isNotEmpty && isImageStatus)
            Expanded(
              child: SizedBox(
                child: Center(
                  child: Stack(
                    children: [
                      Center(child: Image.network(imageString)),
                      if (isTextAllowed)
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: textStoryMaker())
                    ],
                  ),
                ),
              ),
            )
        ]),
      ),
    );
  }

  Widget textStoryMaker() {
    return SizedBox(
        child: TextField(
      controller: textEditingController,
      cursorColor: Colors.white,
      style: GoogleFonts.getFont(fontFamilies[selectedFontIndex],
          color: Colors.white),
      textAlign: TextAlign.center,
      maxLines: 10,
      decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: "Enter Text Here",
          hintStyle: GoogleFonts.getFont(fontFamilies[selectedFontIndex],
              color: Colors.grey)),
    ));
  }

  emojiPickerContainer(BuildContext context, TapDownDetails detail) async {
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    Offset buttonPosition = detail.globalPosition;
    Offset position = buttonPosition - overlay.localToGlobal(Offset.zero);

    await showMenu<String>(
        context: context,
        position: RelativeRect.fromRect(
          Rect.fromPoints(
            position,
            position + const Offset(10, 80), // Adjust these values as needed
          ),
          Offset.zero & overlay.size,
        ),
        items: [
          PopupMenuItem(
            child: EmojiPickerMenuItem(onEmojiSelected: (emoji, category) {
              Navigator.pop(context, emoji);
            }),
          ),
        ]).then((selectedEmoji) {
      if (selectedEmoji != null) {
        textEditingController.text += selectedEmoji;
      }
    });
  }

  Future<void> captureScreenshot() async {
    if (textEditingController.text != "") {
      if (FirebaseAuth.instance.currentUser != null) {
        try {
          Color colorValue = color;
          int hexValue = colorValue.value & 0xFFFFFF;
          String hexString = '0xff${hexValue.toRadixString(16)}';
          await FirebaseFirestore.instance.collection("Status").doc().set({
            "content": textEditingController.text,
            "type": "text",
            "fontStyle": fontFamilies[selectedFontIndex],
            "color": hexString,
            "userId": FirebaseAuth.instance.currentUser!.uid
          }).then((value) => Navigator.pop(context));
        } catch (e) {
          print("Error :: $e while Upload");
        }
      }
    }
  }

  Future<void> saveImageStatus() async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        Color colorValue = color;
        int hexValue = colorValue.value & 0xFFFFFF;
        String hexString = '0xff${hexValue.toRadixString(16)}';
        var imageUrl = await uploadFiles(imageString);
        await FirebaseFirestore.instance.collection("Status").doc().set({
          "content": textEditingController.text,
          "type": "image",
          "fontStyle": fontFamilies[selectedFontIndex],
          "color": hexString,
          "userId": FirebaseAuth.instance.currentUser!.uid,
          "image": imageUrl
        }).then((value) => Navigator.pop(context));
      } catch (e) {
        print("Error :: $e while Upload");
      }
    }
  }

  Future<String> uploadFiles(String image) async {
    String imageUrl = "";
    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    firebase_storage.Reference storageReference = storage
        .refFromURL("gs://proyecto-3c7e7.appspot.com")
        .child("Image/ ${DateTime.now().toString()}");

    firebase_storage.UploadTask uploadTask = storageReference.putString(
        image.toString(),
        format: firebase_storage.PutStringFormat.dataUrl);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();

    imageUrl = url;

    return imageUrl;
  }
}

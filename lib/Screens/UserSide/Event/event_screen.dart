import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proyecto/Screens/UserSide/Article/create_article_screen.dart';
import 'package:proyecto/Views/create_post_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:youtube_player_iframe_plus/youtube_player_iframe_plus.dart'
    as y_tplus;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;

class EventScreen extends StatefulWidget {
  final Function onEventClick;
  const EventScreen({super.key, required this.onEventClick});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  //MARK: CONTROLLERS
  TextEditingController searchTextController = TextEditingController();
  TextEditingController titleEditingController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();
  late GoogleMapController mapController;

  //MARK: LISTS
  //final List<String> _imageUrls = [];
  List<String> uploadedProfileImage = [];
  final List<Map<String, dynamic>> allEventList = [];
//MARK: VARIABLE
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  final firebaseFirestore = FirebaseFirestore.instance;
  late Position currentPosition;
  var fileType = "";
  var selectedTime = "";
  var selectedDate = "";
  var finalTime = 0;
  var isValidUrl = true;
  //MARK: MAP
  Map<String, dynamic>? userData;

  //MARK: BOOLEAN
  var isLoading = false;
  bool emojiShowing = false;
  bool showMap = false;
  bool isLocationSelected = false;
  bool isPostButtonEnable = false;
  var isMobile = false;
  late List<YoutubePlayerController> controllerList;
  //int _currentlyPlayingIndex = -1;
  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    getUserData();
    getAllPosts();

    if (foundation.defaultTargetPlatform == TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }
  }

  Future<void> getAllPosts() async {
    FirebaseFirestore.instance
        .collection('Posts')
        .where("postType", isEqualTo: "event")
        .orderBy("timeStamp", descending: true)
        .limit(20)
        .snapshots()
        .listen((allPostSnapshot) {
      allEventList.clear();
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        allEventList.add(post);
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20),
            width: width > 800 ? width - (100) - 170 : width - (100),
            color: backgroundColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              primary: false,
              child: Column(
                children: [
                  createArticelContainer(),
                  ListView.builder(
                    itemCount: allEventList.length,
                    itemBuilder: (context, index) {
                      var data = allEventList[index];

                      return eventContainer(data, index);
                    },
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // Add shrinkWrap to the ListView
                  )
                ],
              ),
            ),
          ),
          //MARK: -
          Container(
            width: 90,
            padding: const EdgeInsets.only(right: 10),
            color: backgroundColor,
            child: SingleChildScrollView(
              child: Column(
                  children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Image.asset(
                    "assets/saleaAdd.png",
                    height: height * 0.5,
                  ),
                );
              })),
            ),
          ),
        ],
      ),
    );
  }

  bool isYouTubeLink(String link) {
    // Regular expression for matching YouTube video URLs
    RegExp youtubeRegex = RegExp(
      r'^https?:\/\/(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );

    return youtubeRegex.hasMatch(link);
  }

  bool isValidYouTubeUrl(String url) {
    late final Uri uri;
    try {
      uri = Uri.parse(url);
    } catch (e) {
      return false;
    }

    if (!['https', 'http'].contains(uri.scheme)) {
      return false;
    }
    // youtube.com/watch?v=xxxxxxxxxxx
    if (['youtube.com', 'www.youtube.com', 'm.youtube.com']
            .contains(uri.host) &&
        uri.pathSegments.isNotEmpty &&
        (uri.pathSegments.first == 'watch' ||
            uri.pathSegments.first == 'live')) {
      return true;
    }
    // youtu.be/xxxxxxxxxxx
    if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      return true;
    }
    // www.youtube.com/shorts/xxxxxxxxxxx
    // www.youtube.com/embed/xxxxxxxxxxx
    if (uri.host == 'www.youtube.com' &&
        uri.pathSegments.length == 2 &&
        ['shorts', 'embed', 'live'].contains(uri.pathSegments.first)) {
      return true;
    }
    return false;
  }

  String getVideoIdFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String? videoId = uri.pathSegments.last;
    return videoId;
  }

  Widget eventContainer(data, index) {
    y_tplus.YoutubePlayerController? controller;
    bool isValidUrl = isValidYouTubeUrl(data['postDetail']);

    var videoId = "";

    if (isValidUrl == true && !data['postDetail'].contains('si')) {
      videoId =
          y_tplus.YoutubePlayerController.convertUrlToId(data['postDetail'])!;
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
      controller.load(data['postDetail']);
    } else {
      var videoUrl = getVideoIdFromUrl(data['postDetail']);
      videoId = videoUrl;
      controller = y_tplus.YoutubePlayerController(
        initialVideoId: videoUrl,
        params: const y_tplus.YoutubePlayerParams(
          showControls: true,
          mute: false,
          showFullscreenButton: true,
          loop: false,
          strictRelatedVideos: true,
          color: 'white',
        ),
      );
      controller.load(videoUrl);
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10, bottom: 20),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: postButtonColor,
                      ),
                      child: Center(
                          child: Image.asset(
                        "assets/start.png",
                        width: 14,
                        height: 14,
                      )),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            " ${formatTimestamp(data?['timeStamp'] ?? 123456)} at  ${fetchDateFromTimeStamp(data?['timeStamp'] ?? 123456)}",
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(data?['postTitle'] ?? "",
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          " 33k Interested \t 883 Going",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 10)),
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ],
                ),
                if (data?['isEventLive'])
                  GestureDetector(
                    onTap: () {
                      postId = data['postId'];
                      widget.onEventClick();
                    },
                    child: Container(
                      width: 64,
                      height: 30,
                      margin: const EdgeInsets.only(bottom: 20, right: 20),
                      decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(
                            10,
                          )),
                      child: Center(
                          child: Text(
                        "Live",
                        style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      )),
                    ),
                  ),
              ]),
          //if (touchmatchMedia || width < 800)
          Container(
            height: (isValidUrl == true) ? height * 0.5 : 120,
            margin: (width > 800)
                ? const EdgeInsets.only(left: 60, right: 40)
                : const EdgeInsets.symmetric(horizontal: 20),
            child: (isValidUrl == true)
                ? YoutubeVideoPlayer(
                    videoUrl: videoId,
                    controller: controller,
                    index: index,
                    videoPressed: (value) {},
                  )
                : const Text("Invalid Youtube link"),
          ),
          const SizedBox(
            height: 10,
          ),
          //if (touchmatchMedia || width < 800)
          feedBackContainer("${data?['commentCount'] ?? ''}", data['postId'])
        ],
      ),
    );
  }

  Widget createArticelContainer() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20),
          child: Text(
            "Create Event",
            style: GoogleFonts.lato(
                textStyle: const TextStyle(
                    fontFamily: "Lato",
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 30, right: 20, top: 8.0),
          height: 0.2,
          color: Colors.grey,
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                width: 1,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(50 / 2)),
          child: TextField(
            controller: titleEditingController,
            style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 14)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: "Enter title",
            ),
            onChanged: (value) {
              if (titleEditingController.text.isNotEmpty &&
                  descriptionEditingController.text.isNotEmpty) {
                isPostButtonEnable = true;
              } else {
                isPostButtonEnable = false;
              }
              setState(() {});
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.only(left: 15, right: 10, top: 10),
          decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                width: 1,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(25)),
          child: TextField(
            minLines: 2,
            maxLines: 5,
            controller: descriptionEditingController,
            decoration: InputDecoration(
                hintText: "Enter Youtube Link",
                hintStyle: GoogleFonts.lato(
                  textStyle: const TextStyle(fontSize: 14),
                ),
                border: InputBorder.none),
            onChanged: (value) {
              if (titleEditingController.text.isNotEmpty &&
                  descriptionEditingController.text.isNotEmpty) {
                isPostButtonEnable = true;
              } else {
                isPostButtonEnable = false;
              }
              setState(() {});
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        if (!isValidUrl)
          const Text(
            "In Valid Youtube Link",
            style: TextStyle(color: Colors.red),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            onTap: () {
              // setState(() {
              //   if (!isLoading) {
              //     isLoading = true;
              //   }
              // });
              //if (!isLoading) {
              if (titleEditingController.text.isNotEmpty &&
                  descriptionEditingController.text.isNotEmpty) {
                var isValidYTUrl =
                    isValidYouTubeUrl(descriptionEditingController.text);
                isValidUrl = isValidYTUrl;
                setState(() {});
                if (isValidYTUrl) {
                  savePost(descriptionEditingController.text, userData,
                      uploadedProfileImage, titleEditingController.text);
                }
              }
              //}
            },
            child: Container(
              width: 74,
              height: isLoading ? 50 : 40,
              margin: const EdgeInsets.only(bottom: 20, right: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: (isPostButtonEnable || isLoading)
                      ? buttonColor
                      : postColor),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : const Center(child: Text("Post")),
            ),
          ),
        ),

        // if (uploadedProfileImage.isNotEmpty) showImagesListView(),
      ]),
    );
  }

  Widget showImagesListView() {
    return SizedBox(
      width: width - 100,
      height: width * 0.2,
      child: ListView.builder(
        itemCount: uploadedProfileImage.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Image.network(uploadedProfileImage[index]);
        },
      ),
    );
  }

  Widget feedBackContainer(commentCount, postID) {
    return Container(
      margin: (width > 800)
          ? const EdgeInsets.only(left: 60, right: 40)
          : const EdgeInsets.symmetric(horizontal: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image.asset(
            "assets/triangle.png",
            width: 20,
            height: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            "2500",
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
        SizedBox(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          GestureDetector(
            onTap: () {
              postId = postID;
              widget.onEventClick();
            },
            child: Image.asset(
              "assets/comment.png",
              width: 15,
              height: 15,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            commentCount ?? "20",
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
        SizedBox(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image.asset(
            "assets/like.png",
            width: 15,
            height: 15,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            "1",
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
        descriptionEditingController.text += selectedEmoji;
      }
    });
  }

  Future<void> showGoogleMap() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194),
                zoom: 12.0,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> showDateTimePicker(BuildContext context) async {
    DateTime? chosenDate;

    // Show Date Picker
    chosenDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light(), // Customize the theme if needed
          child: child!,
        );
      },
    );

    if (chosenDate != null) {
      selectedDate = "$chosenDate";
      // Show Time Picker if Date is chosen
      TimeOfDay? chosenTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (chosenTime != null) {
        selectedTime = "$chosenDate";
        // Combine Date and Time to form the final DateTime
        DateTime finalDateTime = DateTime(
          chosenDate.year,
          chosenDate.month,
          chosenDate.day,
          chosenTime.hour,
          chosenTime.minute,
        );
        finalTime = finalDateTime.microsecondsSinceEpoch;
      }
    }
  }

  Future<void> pickArticlemage() async {
    // uploadedProfileImage.clear();
    final completer = Completer<List<String>>();
    FileUploadInputElement uploadInput = FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.accept = '.png,.jpg';
    uploadInput.click();
    // onChange doesn't work on mobile safari
    uploadInput.addEventListener('change', (e) async {
      // read file content as dataURL
      final files = uploadInput.files;
      Iterable<Future<String>> resultsFutures = files!.map((file) {
        final reader = FileReader();
        reader.readAsDataUrl(file);
        String extension = file.name.split('.').last.toLowerCase();
        fileType = extension;

        reader.onError.listen((error) => completer.completeError(error));
        return reader.onLoad.first.then((_) => reader.result as String);
      });

      final results = await Future.wait(resultsFutures);
      completer.complete(results);
    });
    // need to append on mobile safari
    document.body!.append(uploadInput);
    uploadedProfileImage = await completer.future;

    uploadInput.remove();
    if (fileType == "png" || fileType == "jpeg" || fileType == "jpg") {
      fileType = "image";
    } else {
      fileType = "video";
    }
    //
    setState(() {});
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

  Future<void> getUserData() async {
    if (user != null) {
      var userId = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .snapshots()
          .listen((userInfo) {
        setState(() {
          userData = userInfo.data();
        });
      });
    }
  }

  void savePost(String post, userData, images, String title) async {
    if (titleEditingController.text == "" ||
        descriptionEditingController.text == "") {
    } else {
      // setState(() {
      //   isLoading = true;
      // });
      try {
        //var list = await uploadFiles(images);
        if (userData != null) {
          // Extract relevant user information
          var timeStamp = DateTime.now().millisecondsSinceEpoch;
          await firebaseFirestore
              .collection('Posts')
              .doc(timeStamp.toString())
              .set({
            "user": userData,
            "userId": userData['userId'],
            "postDetail": post,
            "imagesUrl": [],
            "postType": "event",
            "postTitle": title,
            "timeStamp": timeStamp,
            "postId": timeStamp.toString(),
            "views": 1,
            "commentCount": 0,
            "lat": 0.0,
            "long": 0.0,
            "isEventLive": true,
            "likes": [],
            "bookMarks": []
          }).then((val) {
            titleEditingController.text = "";
            descriptionEditingController.text = "";
            uploadedProfileImage.clear();
            uploadedProfileImage = [];
            setState(() {
              isLoading = false;
            });
          }).catchError((e) {
            setState(() {
              isLoading = false;
            });
          });
        } else {
          // Handle the case where the user is not logged in
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

// else if (selectedDate == "" || selectedTime == "") {
//     } else if (!isLocationSelected) {
//}
  }
}

class EmojiPickerMenuItem extends StatelessWidget {
  final Function(String, Category) onEmojiSelected;

  const EmojiPickerMenuItem({required this.onEmojiSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 4000, // Set the width as needed
      height: 350, // Set the height as needed
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          onEmojiSelected(emoji.emoji, category!);
        },
      ),
    );
  }
}

// Widget addOthersThingTOCreateEventcontainer(){
// return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SizedBox(
//                 child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     pickArticlemage();
//                     //dialogContent(context);
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(left: 20, bottom: 20),
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       color: postButtonColor,
//                     ),
//                     child: Center(
//                         child: Image.asset(
//                       "assets/gallery.png",
//                       width: 13,
//                       height: 13,
//                     )),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTapDown: (detail) {
//                     setState(() {
//                       emojiShowing = !emojiShowing;
//                     });
//                     emojiPickerContainer(context, detail);
//                     // dialogContent(context);
//                     //pickArticlemage();
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(left: 10, bottom: 20),
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       color: postButtonColor,
//                     ),
//                     child: Center(
//                         child: Image.asset(
//                       "assets/emoji.png",
//                       width: 13,
//                       height: 13,
//                     )),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     showDateTimePicker(context);
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(left: 10, bottom: 20),
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       color: postButtonColor,
//                     ),
//                     child: Center(
//                         child: Image.asset(
//                       "assets/start.png",
//                       width: 13,
//                       height: 13,
//                     )),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () async {
//                     currentPosition = await determinePosition();
//                     isLocationSelected = true;
//                     // showGoogleMap();
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(left: 10, bottom: 20),
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       color: postButtonColor,
//                     ),
//                     child: Center(
//                         child: Image.asset(
//                       "assets/location.png",
//                       width: 13,
//                       height: 13,
//                     )),
//                   ),
//                 ),
//               ],
//             )),
//             if (isLoading)
//               Container(
//                   width: 74,
//                   height: 50,
//                   margin: const EdgeInsets.only(bottom: 20, right: 20),
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       color: postColor),
//                   child: const Center(child: CircularProgressIndicator())),
//             if (!isLoading)
//               GestureDetector(
//                 onTap: () {
//                   if (titleEditingController.text.isNotEmpty &&
//                       descriptionEditingController.text.isNotEmpty) {
//                     savePost(descriptionEditingController.text, userData,
//                         uploadedProfileImage, titleEditingController.text);
//                   }
//                 },
//                 child: Container(
//                   width: 74,
//                   height: 40,
//                   margin: const EdgeInsets.only(bottom: 20, right: 20),
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       color: isPostButtonEnable ? buttonColor : postColor),
//                   child: const Center(child: Text("Post")),
//                 ),
//               )
//           ],
//         );
// }

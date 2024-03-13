import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:proyecto/Screens/UserSide/Event/event_screen.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostContainer extends StatefulWidget {
  const CreatePostContainer({super.key});

  @override
  State<CreatePostContainer> createState() => _CreatePostContainerState();
}

class _CreatePostContainerState extends State<CreatePostContainer> {
  final postController = TextEditingController();
  List<String> uploadedProfileImage = [];
  String profileImageUrl = "";
  List<String> selectedImagesUrl = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic>? userData;
  final firebaseFirestore = FirebaseFirestore.instance;
  var isLoading = false;
  var fileType = "";
  bool isPostButtonEnable = false;
  FocusNode node = FocusNode();
  @override
  void initState() {
    //deleteVegetable();
    super.initState();

    user = auth.currentUser;
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20),
          child: Text(
            "Create Post",
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
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20, right: 20.0),
          child: SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (profileImageUrl.isNotEmpty)
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: width * 0.03,
                    backgroundImage: Image.network(
                      profileImageUrl,
                      fit: BoxFit.contain,
                    ).image,
                  ),
                if (profileImageUrl.isEmpty)
                  Image.asset(
                    "assets/profilepic.png",
                    width: width * 0.08,
                    height: width * 0.08,
                  ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: SizedBox(
                    width: width * 0.6,
                    child: TextFormField(
                      minLines: 1,
                      maxLines: 5,
                      focusNode: node,
                      keyboardType: TextInputType.multiline,
                      controller: postController,
                      decoration: InputDecoration(
                          hintText: "Write something here..",
                          hintStyle: GoogleFonts.lato(
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                          border: InputBorder.none),
                      onChanged: (value) {
                        isPostButtonEnable = postController.text.isNotEmpty;
                        setState(() {});
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
                    //getMultipleImageInfos();
                    // selectImage();

                    _pickProfileImage();
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
                GestureDetector(
                  onTapDown: (detail) {
                    emojiPickerContainer(context, detail);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, bottom: 20),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: postButtonColor,
                    ),
                    child: Center(
                        child: Image.asset(
                      "assets/emoji.png",
                      width: 13,
                      height: 13,
                    )),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, bottom: 20),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: postButtonColor,
                    ),
                    child: Center(
                        child: Image.asset(
                      "assets/start.png",
                      width: 13,
                      height: 13,
                    )),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, bottom: 20),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: postButtonColor,
                    ),
                    child: Center(
                        child: Image.asset(
                      "assets/location.png",
                      width: 13,
                      height: 13,
                    )),
                  ),
                ),
              ],
            )),
            if (isLoading)
              Container(
                  width: 74,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 20, right: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: postColor),
                  child: const Center(child: CircularProgressIndicator())),
            if (!isLoading)
              GestureDetector(
                onTap: () {
                  if (postController.text.isNotEmpty) {
                    savePost(postController.text, userData,
                        uploadedProfileImage, fileType);
                    postController.text = "";
                  }
                },
                child: Container(
                  width: 74,
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 20, right: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isPostButtonEnable ? buttonColor : postColor),
                  child: const Center(child: Text("Post")),
                ),
              ),
          ],
        )
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
        postController.text += selectedEmoji;
      }
    });
  }

  Future<void> _pickProfileImage() async {
    uploadedProfileImage.clear();
    final completer = Completer<List<String>>();
    FileUploadInputElement uploadInput = FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.accept = '.png,.jpg, .mp4, .mov';
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
    if (mounted) {
      setState(() {});
    }
    uploadInput.remove();
    if (fileType == "png" || fileType == "jpeg" || fileType == "jpg") {
      fileType = "image";
    } else {
      fileType = "video";
    }
    // var list = await uploadFiles(uploadedProfileImage);
    // selectedImagesUrl = list;
  }

  Future<List<String>> uploadFiles(List<String> images) async {
    List<String> imagesUrls = [];

    await Future.forEach(images, (image) async {
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

      imagesUrls.add(url);
    });

    return imagesUrls;
  }

  //Get User Data
  Future<void> getUserData() async {
    if (user != null) {
      var userId = user!.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId.toString())
          .snapshots()
          .listen((userInfo) {
        if (mounted) {
          userData = userInfo.data();
          profileImageUrl = userInfo.data()?['imageUrl'];
          setState(() {});
        }
      });
    }
  }

  Future<void> savePost(String post, userData, images, String fileType) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    if (userData != null) {
      // Extract relevant user information
      var list = await uploadFiles(images);
      var timeStamp = DateTime.now().millisecondsSinceEpoch;
      await firebaseFirestore
          .collection('Posts')
          .doc(timeStamp.toString())
          .set({
        "user": userData,
        "userId": userData['userId'],
        "postDetail": post,
        "imagesUrl": list,
        "postType": fileType,
        "postTitle": "",
        "timeStamp": timeStamp,
        "postId": timeStamp.toString(),
        "views": 1,
        "commentCount": 0,
        "likes": [],
        "bookMarks": []
      }).then((val) {
        postController.text = "";
        uploadedProfileImage = [];
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    } else {
      // Handle the case where the user is not logged in
    }
  }
}

class PostRepositort {
  final CollectionReference<Map<String, dynamic>> _imagesCollection =
      FirebaseFirestore.instance.collection('images');
  final firebaseFirestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  Future<String> uploadImage(Uint8List imageBytes) async {
    try {
      String base64Image = base64Encode(imageBytes);
      DocumentReference<Map<String, dynamic>> docRef =
          await _imagesCollection.add({'image': base64Image});
      return docRef.id;
    } catch (e) {
      print('Error uploading image to Firestore: $e');
      return '';
    }
  }

  Stream<List<Map<String, dynamic>>> getAllPost() {
    return firebaseFirestore
        .collection('Posts')
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .map(
      (QuerySnapshot<Map<String, dynamic>> allPostSnapshot) {
        return allPostSnapshot.docs.map((doc) => doc.data()).toList();
      },
    );
  }

  Stream<List<Map<String, dynamic>>> getAllArticles() {
    return firebaseFirestore
        .collection('Posts')
        .where("postType", isEqualTo: "article")
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .map(
      (QuerySnapshot<Map<String, dynamic>> allPostSnapshot) {
        return allPostSnapshot.docs.map((doc) => doc.data()).toList();
      },
    );
  }

  Stream<List<Map<String, dynamic>>> getAllEvents() {
    return firebaseFirestore
        .collection('Posts')
        .where("postType", isEqualTo: "event")
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .map(
      (QuerySnapshot<Map<String, dynamic>> allPostSnapshot) {
        return allPostSnapshot.docs.map((doc) => doc.data()).toList();
      },
    );
  }

  Stream<List<Map<String, dynamic>>> getAllPosts() {
    return firebaseFirestore
        .collection('Posts')
        .where("postType", isNotEqualTo: "article")
        .orderBy("postType")
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .map(
      (QuerySnapshot<Map<String, dynamic>> allPostSnapshot) {
        return allPostSnapshot.docs.map((doc) => doc.data()).toList();
      },
    );
  }

  Stream<List<Map<String, dynamic>>> fetchAllMyPosts(userId) {
    return firebaseFirestore
        .collection('Posts')
        .where("userId", isEqualTo: userId)
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .map(
      (QuerySnapshot<Map<String, dynamic>> allPostSnapshot) {
        return allPostSnapshot.docs.map((doc) => doc.data()).toList();
      },
    );
  }

  Future<void> postComment(postId, userData, comment, userId) async {
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    await firebaseFirestore
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
        })
        .then((val) {})
        .catchError((e) {
          print(e);
        });
  }

  Stream<List<Map<String, dynamic>>> fetchAllComment(postID) {
    return FirebaseFirestore.instance
        .collection('Posts')
        .doc(postID)
        .collection("Comments")
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .map(
      (QuerySnapshot<Map<String, dynamic>> allPostSnapshot) {
        return allPostSnapshot.docs.map((doc) => doc.data()).toList();
      },
    );
  }
}

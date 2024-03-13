import 'package:flutter/material.dart';
import 'package:proyecto/Model/inbox_model.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:proyecto/Views/side_menu_container.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({
    super.key,
  });

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  //MARK: - TEXT EDITING CONTROLLER
  TextEditingController searchTextController = TextEditingController();
  TextEditingController messageTextController = TextEditingController();

  //MARK: - LISTS

  List<Map<String, dynamic>> allMessagesList = [];
  List<InboxModel> inboxList = [];
  List<Map<String, dynamic>> inboxMapList = [];

  //MARK: - MAPS
  late Map<String, dynamic> receiverProfile;

// FIREBASE VARIABLES
  final firebaseFirestore = FirebaseFirestore.instance;

  //MARK: - INTEGERS
  int selectedIdx = -1;

  //MARK: - STRINGS
  String myImageUrl = "";
  String myUserId = "";
  String receiverId = "";
  var conversationId = "";

  bool isChatVisible = false;
  var isMobile = false;
  var hideInboxList = false;
  var hideMenuButton = true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      isMobile = true;
    } else {
      isMobile = false;
    }
    if (isMobile == true || touchmatchMedia == true) {
      hideMenuButton = false;
    } else if (width < 800) {
      hideMenuButton = false;
    } else {
      hideMenuButton = true;
    }
    fetchAllInboxMessages();
    getMyInfo();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      drawerEnableOpenDragGesture: true,
      drawer: customDrawer(),
      key: _scaffoldKey,
      body: Container(
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.only(bottom: 20, top: 20),
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
                                if ((isChatVisible == false) &&
                                    (hideMenuButton == false) &&
                                    (width < 800))
                                  GestureDetector(
                                    onTap: () {
                                      //  selectedIndex = 4;
                                      // HomeScreenState().tabsContent();
                                      _scaffoldKey.currentState!.openDrawer();
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.menu),
                                    ),
                                  ),
                                if (isChatVisible)
                                  GestureDetector(
                                    onTap: () {
                                      isChatVisible = false;
                                      hideInboxList = false;
                                      setState(() {});
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 20),
                                      child: Image.asset(
                                        "assets/back.png",
                                        width: 15,
                                      ),
                                    ),
                                  ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text("Messages",
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
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Search Direct Messages.....",
                            prefixIcon: Image.asset(
                              "assets/search.png",
                              width: width * 0.03,
                            )),
                      ),
                    ),
                  ]),
            ),
            Expanded(
              child: Row(
                children: [
                  if (!hideInboxList || width < 1037)
                    Expanded(
                      child: Container(
                        width:
                            isChatVisible ? width * 0.3 : (width - 160) * 0.8,
                        margin: const EdgeInsets.only(top: 20, left: 20),
                        child: ListView.builder(
                          itemCount: inboxMapList.length,
                          itemBuilder: (context, index) {
                            var data = inboxMapList[index];
                            var userProfile = data['user'];
                            var isSelected = selectedIdx == index;
                            var messageCount = data["unReadMessageCount"];

                            // if (userProfile == null) {
                            //   return Container(); // or some other fallback UI
                            // }
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIdx = index;
                                  isChatVisible = true;
                                  conversationId = data["conversationId"];
                                  receiverProfile = userProfile;
                                  receiverId = userProfile['userId'];
                                  selectedUserId = receiverId;
                                  if (isMobile == true) {
                                    hideInboxList = true;
                                    setState(() {});
                                  } else if (touchmatchMedia == true) {
                                    hideInboxList = true;
                                  } else if (width < 600) {
                                    hideInboxList = true;
                                    setState(() {});
                                  } else {
                                    hideInboxList = false;
                                    setState(() {});
                                  }
                                  fetchAllChatMessages(conversationId);
                                });
                              },
                              child: inboxListView(
                                  isSelected,
                                  userProfile,
                                  data["content"],
                                  messageCount,
                                  data['timeStamp']),
                            );
                          },
                        ),
                      ),
                    ),
                  if (isChatVisible)
                    Container(
                      width: (hideInboxList == true || width < 690)
                          ? width
                          : width - (width * 0.3 + 160),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                              margin: const EdgeInsets.only(left: 20, top: 20),
                              child: receiverProfileWidget()),
                          Expanded(
                            child: ListView.builder(
                                itemCount: allMessagesList.length,
                                itemBuilder: (context, index) {
                                  var data = allMessagesList[index];
                                  if (isChatVisible &&
                                      conversationId ==
                                          data['conversationId']) {
                                    updateMessageStatus(data['messageId']);
                                  }
                                  if (!data['isRead']) {}
                                  if (data["senderId"] ==
                                      receiverProfile['userId']) {
                                    return GestureDetector(
                                        onTap: () {
                                          isChatVisible = !isChatVisible;
                                          setState(() {});
                                        },
                                        child: incomingMessageContainer(data));
                                  } else {
                                    return GestureDetector(
                                        onTap: () {
                                          isChatVisible = !isChatVisible;
                                          setState(() {});
                                        },
                                        child: outgoingMessageContainer(data));
                                  }
                                }),
                          ),
                          sendMessage()
                        ],
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

  Widget inboxListView(bool isSelected, Map<String, dynamic> userProfile,
      String lastMessage, messageCount, timeStamp) {
    var userImage = userProfile['imageUrl'] ?? "";
    var name = userProfile['name'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: Image.network(
                    userImage ??
                        "https://firebasestorage.googleapis.com/v0/b/proyecto-3c7e7.appspot.com/o/imageplaceholder%20copy.png?alt=media&token=28107855-594f-47f1-a5c7-318f62f59a4e",
                    width: width * 0.04,
                    height: width * 0.04,
                  ).image),
              const SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        extractUsernameFromEmail(userProfile['email']),
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        fetchDateFromTimeStamp(timeStamp),
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: isChatVisible ? width * 0.165 : (width - 160) * 0.8,
                    child: Text(
                      lastMessage,
                      maxLines: 2,
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: messageCount > 0 ? 12 : 10,
                          fontWeight: messageCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isSelected && isChatVisible)
            Container(
              width: 3,
              height: 40,
              color: buttonColor,
            ),
        ],
      ),
    );
  }

  Widget receiverProfileWidget() {
    return SizedBox(
      child: Row(children: [
        CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: Image.network(
              receiverProfile['imageUrl'] ??
                  "https://firebasestorage.googleapis.com/v0/b/proyecto-3c7e7.appspot.com/o/imageplaceholder%20copy.png?alt=media&token=28107855-594f-47f1-a5c7-318f62f59a4e",
              width: width * 0.03,
              height: width * 0.03,
            ).image),
        const SizedBox(
          width: 10,
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            receiverProfile['name'],
            style: GoogleFonts.lato(
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Last online 7:25",
            style: GoogleFonts.lato(
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.normal)),
          ),
        ]),
      ]),
    );
  }

  Widget outgoingMessageContainer(data) {
    return Container(
      margin: const EdgeInsets.only(right: 20, top: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: (isMobile == true || hideInboxList == true || width < 690)
                  ? width * 0.35
                  : width * 0.3,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: buttonColor, borderRadius: BorderRadius.circular(20)),
              child: Text(
                data["content"],
                style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal)),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: Image.network(
                myImageUrl,
                width: width * 0.032,
                height: width * 0.032,
              ).image,
            ),
          ]),
    );
  }

  Widget incomingMessageContainer(data) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: Image.network(
                receiverProfile['imageUrl'] ??
                    "https://firebasestorage.googleapis.com/v0/b/proyecto-3c7e7.appspot.com/o/imageplaceholder%20copy.png?alt=media&token=28107855-594f-47f1-a5c7-318f62f59a4e",
                width: width * 0.032,
                height: width * 0.032,
              ).image,
            ),
            const SizedBox(
              width: 20,
            ),
            Container(
              width: (isMobile == true || hideInboxList == true || width < 690)
                  ? width * 0.35
                  : width * 0.3,
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(16),
              child: Text(
                data["content"],
                style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.normal)),
              ),
            ),
          ]),
    );
  }

  Drawer customDrawer() {
    return Drawer(
      width: 170,
      child: Container(
        width: 100,
        color: Colors.black,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                "assets/twitterIcon.png",
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sideMenuList.length,
                itemBuilder: (context, index) {
                  var data = sideMenuList[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SideMenuContainer(
                        buttonIcon: data.icon,
                        buttonTitle: data.title,
                        isSelected: data.isSelected,
                        onPressed: () {
                          previousSelectedIndex = index;

                          setState(() {});
                          setState(() {
                            for (var i = 0; i < sideMenuList.length; i++) {
                              sideMenuList[i].isSelected = (i == index);
                            }
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                          );
                          selectedIndex = index;
                          _scaffoldKey.currentState!.openEndDrawer();
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sendMessage() {
    return Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
            border: Border.all(width: 0.9, color: Colors.grey),
            borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: SizedBox(
              width: width - (width * 0.5),
              child: TextField(
                minLines: 1,
                maxLines: 5,
                controller: messageTextController,
                style:
                    GoogleFonts.lato(textStyle: const TextStyle(fontSize: 12)),
                decoration: InputDecoration(
                    hintText: "Type Message here..",
                    hintStyle: GoogleFonts.lato(
                        textStyle: const TextStyle(fontSize: 10)),
                    border: InputBorder.none),
              ),
            )),
            GestureDetector(
              onTap: () => sendMessageSaveToDB(),
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: Image.asset(
                  "assets/sendMessage.png",
                  width: 20,
                  height: 20,
                ),
              ),
            )
          ],
        ));
  }

  void fetchAllChatMessages(conversationId) {
    firebaseFirestore
        .collection('Messages')
        .where("conversationId", isEqualTo: conversationId)
        .snapshots()
        .listen((chatSnaps) {
      allMessagesList.clear();

      for (DocumentSnapshot chatSnap in chatSnaps.docs) {
        Map<String, dynamic> data = chatSnap.data() as Map<String, dynamic>;
        allMessagesList.add(data);
        //
      }
      if (mounted) {
        setState(() {});
      }
    });
    //streambuilder.cancel();
  }

  void getMyInfo() {
    var auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      myUserId = auth.currentUser!.uid;
      firebaseFirestore
          .collection("Users")
          .doc(myUserId)
          .snapshots()
          .listen((data) {
        myUserId = auth.currentUser!.uid;
        myImageUrl = data.data()?['imageUrl'] ?? "";
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> fetchAllInboxMessages() async {
    var uid = FirebaseAuth.instance.currentUser;
    if (uid == null) return;

    firebaseFirestore
        .collection('Messages')
        .where("participants", arrayContainsAny: [uid.uid])
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .listen((chatSnaps) async {
          List<Map<String, dynamic>> newInboxMapList = [];

          for (DocumentSnapshot chatSnap in chatSnaps.docs) {
            Map<String, dynamic> data = chatSnap.data() as Map<String, dynamic>;

            for (var id in data['participants']) {
              if (id != uid.uid) {
                Map<String, dynamic>? user;
                Map<String, dynamic> inboxMap = {};

                // Use await to wait for the result of get() before continuing
                var userSnapshot =
                    await firebaseFirestore.collection('Users').doc(id).get();

                user = userSnapshot.data();
                inboxMap = {
                  "user": user,
                  "conversationId": data['conversationId'],
                  "messageId": data['messageId'],
                  "content": data['content'],
                  "timeStamp": data['timeStamp'],
                  "unReadMessageCount": 0,
                };

                if ((!data['isRead']) && (data['receiverId'] == uid.uid)) {
                  inboxMap["unReadMessageCount"] += 1;
                }

                newInboxMapList.add(inboxMap);
              }
            }
          }

          if (mounted) {
            setState(() {
              inboxMapList.clear();
              // Update the state after processing all data
              for (var inboxMap in newInboxMapList) {
                var existingIndex = inboxMapList.indexWhere((element) =>
                    element['conversationId'] == inboxMap['conversationId']);

                if (existingIndex != -1) {
                  inboxMapList[existingIndex]['unReadMessageCount'] +=
                      inboxMap['unReadMessageCount'];
                } else {
                  inboxMapList.add(inboxMap);
                }
              }
            });
          }
        });
  }

  Future<void> sendMessageSaveToDB() async {
    try {
      var timeStamp = DateTime.now().millisecondsSinceEpoch;
      var ids = [myUserId, receiverId];
      ids.sort();
      var conversationId = "${ids[0]};${ids[1]}";
      var docmentId = "$myUserId;$receiverId;$timeStamp";
      await FirebaseFirestore.instance
          .collection("Messages")
          .doc(docmentId)
          .set({
        "senderId": myUserId,
        "receiverId": receiverId,
        "conversationId": conversationId,
        "messageId": docmentId,
        "timeStamp": timeStamp,
        "isRead": false,
        "participants": ids,
        "content": messageTextController.text
      }).then((value) => messageTextController.text = "");
    } catch (error) {
      //
    }
  }

  Future<void> updateMessageStatus(String messageId) async {
    var messageDoc =
        await firebaseFirestore.collection("Messages").doc(messageId).get();
    if (messageDoc.exists) {
      await messageDoc.reference.update({
        'isRead': true,
      });
    }
  }
}

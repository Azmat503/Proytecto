import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final Function onBackPressed;
  const ChatScreen({super.key, required this.onBackPressed});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController searchTextController = TextEditingController();
  TextEditingController messageTextController = TextEditingController();
  ScrollController controller = ScrollController();

  bool isChatVisible = false;
  Stream<List<Map<String, dynamic>>>? allMessages;
  final firebaseFirestore = FirebaseFirestore.instance;
  String receiverImageUrl = "";
  String myImageUrl = "";
  String selectedUseName = "";
  String myUserId = "";
  bool isOnline = false;
  var imageplaceholder =
      "https://firebasestorage.googleapis.com/v0/b/proyecto-3c7e7.appspot.com/o/imageplaceholder%20copy.png?alt=media&token=28107855-594f-47f1-a5c7-318f62f59a4e";
  @override
  void initState() {
    super.initState();
    allMessages = getAllMessages(selectedUserId);
    getImagesUrl();
    getMyInfo();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 5),
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
                                    selectedIndex = 11;
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
              child: Container(
                width: width,
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.only(left: 20, top: 20),
                        child: receiverProfile()),
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: allMessages,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            List<Map<String, dynamic>> messageList =
                                snapshot.data ?? [];
                            var ids = [myUserId, selectedUserId];
                            ids.sort();
                            var conversationId = "${ids[0]};${ids[1]}";
                            final finalMessageList = messageList
                                .where((message) =>
                                    message['conversationId'] == conversationId)
                                .toList();
                            return ListView.builder(
                                itemCount: finalMessageList.length,
                                itemBuilder: (context, index) {
                                  var data = finalMessageList[index];

                                  if (data["senderId"] == selectedUserId) {
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
                                });
                          }),
                    ),
                    sendMessage()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget receiverProfile() {
    return SizedBox(
      child: Row(children: [
        CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: Image.network(
            receiverImageUrl,
            width: width * 0.03,
            height: width * 0.03,
          ).image,
        ),
        const SizedBox(
          width: 10,
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            selectedUseName,
            style: GoogleFonts.lato(
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            isOnline ? "isOnline" : "Last online 7:25",
            style: GoogleFonts.lato(
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
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
              width: width * 0.25,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: buttonColor, borderRadius: BorderRadius.circular(20)),
              child: Text(
                data["content"],
                maxLines: 5,
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
            )
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
                receiverImageUrl,
                width: width * 0.032,
                height: width * 0.032,
              ).image,
            ),
            const SizedBox(
              width: 20,
            ),
            Container(
              width: width * 0.25,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20)),
              // padding: const EdgeInsets.all(8),
              child: Text(
                data["content"],
                maxLines: 5,
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

  Widget sendMessage() {
    return Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
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
                decoration: InputDecoration(
                    hintText: "Type Message here..",
                    hintStyle: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: width * 0.01)),
                    border: InputBorder.none),
              ),
            )),
            GestureDetector(
              onTap: () {
                sendMessageSaveToDB();
              },
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

  Future<void> sendMessageSaveToDB() async {
    try {
      var timeStamp = DateTime.now().millisecondsSinceEpoch;
      var ids = [myUserId, selectedUserId];
      ids.sort();
      var conversationId = "${ids[0]};${ids[1]}";
      var docmentId = "$myUserId;$selectedUserId;$timeStamp";
      await FirebaseFirestore.instance
          .collection("Messages")
          .doc(docmentId)
          .set({
        "senderId": myUserId,
        "receiverId": selectedUserId,
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

  Stream<List<Map<String, dynamic>>> getAllMessages(String receiverId) {
    return firebaseFirestore.collection('Messages').snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> allPostSnapshot) {
        return allPostSnapshot.docs
            .where((doc) => (doc['participants'] as List).contains(receiverId))
            .map((doc) => doc.data())
            .toList();
      },
    );
  }

  void getImagesUrl() {
    if (selectedUserId != "") {
      firebaseFirestore
          .collection("Users")
          .doc(selectedUserId)
          .snapshots()
          .listen((data) {
        receiverImageUrl = data.data()?['imageUrl'] ?? imageplaceholder;
        selectedUseName = data.data()?['name'] ?? "";
        isOnline = data.data()?['isOnline'] ?? false;
        if (mounted) {
          setState(() {});
        }
      });
    }
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
        myImageUrl = data.data()?['imageUrl'] ?? imageplaceholder;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }
}

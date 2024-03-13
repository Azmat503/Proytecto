import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stories/flutter_stories.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusContainer extends StatefulWidget {
  final String userId;
  const StatusContainer({super.key, required this.userId});

  @override
  State<StatusContainer> createState() => _StatusContainerState();
}

class _StatusContainerState extends State<StatusContainer> {
  final _momentDuration = const Duration(seconds: 5);
  late Future<Map<String, dynamic>> userData;
  Map<String, dynamic>? userInfoData;
  bool isLoading = false;
  bool isSeenStatus = true;

  @override
  void initState() {
    super.initState();
    getUserData(widget.userId);
  }

  final List<Map<String, dynamic>> momentsData = [];
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Container(
        margin: const EdgeInsets.only(right: 10),
        child: userInfoData != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      print(" widget.userId ${widget.userId}");
                      getUserStatusData(widget.userId);
                    },
                    child: SizedBox(
                      width: 100,
                      height: 114,
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2,
                                      color: isSeenStatus
                                          ? buttonColor
                                          : Colors.white),
                                  shape: BoxShape.circle),
                              padding: const EdgeInsets.all(2),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.grey,
                                backgroundImage: Image.network(
                                  userInfoData!['imageUrl'],
                                ).image,
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : const SizedBox(),
                              ),
                            ),
                          ),
                          if (userInfoData!['isLive'])
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                //color: buttonColor,
                                width: 40,
                                height: 20,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                    color: buttonColor),
                                child: const Center(
                                    child: Text(
                                  "Live",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                )),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  Text(userInfoData!['name'],
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ))
                ],
              )
            : Center(child: Container()));
  }

  void storiesContainer(List<Map<String, dynamic>> momentsData) {
    showCupertinoDialog(
      context: context,
      barrierLabel: "Hi",
      builder: (context) {
        return CupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          child: Story(
            onFlashForward: Navigator.of(context).pop,
            onFlashBack: Navigator.of(context).pop,
            momentCount: momentsData.length,
            momentDurationGetter: (idx) => _momentDuration,
            momentBuilder: (context, idx) {
              final moment = momentsData[idx];
              final hexColor = moment['color'];
              final color = Color(int.parse(hexColor));
              return Container(
                  color: color,
                  child: buildMomentWidget(context, moment, color));
            },
          ),
        );
      },
    );
  }

  Widget buildMomentWidget(
      BuildContext context, Map<String, dynamic> moment, color) {
    final type = moment['type'];
    final content = moment['content'];

    final fontStyle = GoogleFonts.getFont(moment['fontStyle'],
        color: Colors.white, decoration: TextDecoration.none);
    switch (type) {
      case 'text':
        return Container(
          color: color,
          child: Stack(
            children: [
              Center(
                child: Text(
                  content,
                  style: fontStyle,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: CircleAvatar(
                        backgroundImage: Image.network(
                          userInfoData!['imageUrl'],
                          fit: BoxFit.contain,
                          width: width * 0.06,
                          height: width * 0.06,
                        ).image,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfoData!['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          userInfoData!['email'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'image':
        var image = moment['image'];

        return Stack(children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: CircleAvatar(
                    backgroundImage: Image.network(
                      userInfoData!['imageUrl'],
                      fit: BoxFit.contain,
                      width: width * 0.06,
                      height: width * 0.06,
                    ).image,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userInfoData!['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      userInfoData!['email'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: Image.network(
              image,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          if (content != "")
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                content,
                style: const TextStyle(
                    decoration: TextDecoration.none, color: Colors.white),
              ),
            )
        ]);
      case 'video':
        // Implement video widget here
        return Container();
      default:
        // Handle other types or fallback to a default widget
        return Container();
    }
  }

  Future<void> getUserData(userId) async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId.toString())
        .snapshots()
        .listen((userInfo) {
      userInfoData = userInfo.data();

      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> getUserStatusData(userId) async {
    setState(() {
      isLoading = true;
    });
    try {
      final QuerySnapshot<Map<String, dynamic>> userInfo =
          await FirebaseFirestore.instance
              .collection('Status')
              .where("userId", isEqualTo: userId)
              .get();

      momentsData.clear(); // Clear existing data before updating
      momentsData.addAll(userInfo.docs.map((doc) {
        // if (doc['seen'].length > 0) {
        isSeenStatus =
            doc['seen'].contains(FirebaseAuth.instance.currentUser!.uid);
        // }

        return doc.data();
      }));

      if (mounted) {
        setState(() {
          isLoading = false;
          if (momentsData.isNotEmpty) {
            storiesContainer(momentsData);
          }
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error retrieving user status data: $error");
    }
  }
}

void storiessContainer(List<Map<String, dynamic>> momentsData,
    BuildContext context, userInfoData) {
  showCupertinoDialog(
    context: context,
    barrierLabel: "Hi",
    builder: (context) {
      return CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        child: Story(
          onFlashForward: Navigator.of(context).pop,
          onFlashBack: Navigator.of(context).pop,
          momentCount: momentsData.length,
          momentDurationGetter: (idx) => const Duration(seconds: 5),
          momentBuilder: (context, idx) {
            final moment = momentsData[idx];
            final hexColor = moment['color'];
            final color = Color(int.parse(hexColor));
            return Container(
                color: color,
                child:
                    buildMomenttWidget(context, moment, color, userInfoData));
          },
        ),
      );
    },
  );
}

Widget buildMomenttWidget(
    BuildContext context, Map<String, dynamic> moment, color, userInfoData) {
  final type = moment['type'];
  final content = moment['content'];

  final fontStyle = GoogleFonts.getFont(moment['fontStyle'],
      color: Colors.white, decoration: TextDecoration.none);
  switch (type) {
    case 'text':
      return Container(
        color: color,
        child: Stack(
          children: [
            Center(
              child: Text(
                content,
                style: fontStyle,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: CircleAvatar(
                      backgroundImage: Image.network(
                        userInfoData!['imageUrl'],
                        fit: BoxFit.contain,
                        width: width * 0.06,
                        height: width * 0.06,
                      ).image,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userInfoData!['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        userInfoData!['email'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    case 'image':
      var image = moment['image'];

      return Stack(children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: CircleAvatar(
                  backgroundImage: Image.network(
                    userInfoData!['imageUrl'],
                    fit: BoxFit.contain,
                    width: width * 0.06,
                    height: width * 0.06,
                  ).image,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userInfoData!['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    userInfoData!['email'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Center(
          child: Image.network(
            image,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
        if (content != "")
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              content,
              style: const TextStyle(
                  decoration: TextDecoration.none, color: Colors.white),
            ),
          )
      ]);
    case 'video':
      // Implement video widget here
      return Container();
    default:
      // Handle other types or fallback to a default widget
      return Container();
  }
}

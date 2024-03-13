import 'package:flutter/material.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingScreen extends StatefulWidget {
  final Function onBackPressed;
  const SettingScreen({super.key, required this.onBackPressed});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  TextEditingController searchTextController = TextEditingController();
  FirebaseAuth user = FirebaseAuth.instance;
  var isLiked = false;
  var isPost = false;
  var isMention = false;
  var isNewMessage = false;
  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Container(
      color: backgroundColor,
      child: Column(
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
                                  selectedIndex = 0;
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
                              Text("Settings",
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
                          textStyle: const TextStyle(fontSize: 12)),
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
          Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.only(
                  top: 20, left: 30, right: 30, bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customize Notification",
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Likes & Follow",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                        ),
                        Switch(
                          value: isLiked,
                          onChanged: (index) {
                            isLiked = !isLiked;

                            updateData("isLikedFollowed", isLiked);
                          },
                          activeColor: buttonColor,
                        ),
                      ],
                    ),
                    Container(
                      height: 0.08,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Post & Comment Replies",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                        ),
                        Switch(
                          value: isPost,
                          onChanged: (index) async {
                            isPost = !isPost;

                            updateData("isPostComment", isPost);
                          },
                          activeColor: buttonColor,
                        ),
                      ],
                    ),
                    Container(
                      height: 0.08,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Mentions & Tags",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                        ),
                        Switch(
                          value: isMention,
                          onChanged: (index) {
                            isMention = !isMention;

                            updateData("isMentionTags", isMention);
                          },
                          activeColor: buttonColor,
                        ),
                      ],
                    ),
                    Container(
                      height: 0.08,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "New Messages",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                        ),
                        Switch(
                          value: isNewMessage,
                          onChanged: (index) {
                            isNewMessage = !isNewMessage;

                            updateData("isNewMessage", isNewMessage);
                          },
                          activeColor: buttonColor,
                        ),
                      ],
                    ),
                  ])),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.only(
                  top: 20, left: 30, right: 30, bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Privacy Policy",
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
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis auteirure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quaeabillo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur autodit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsumquia dolor sit amet,  consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam. \n At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat. \n Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ]),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future getdata() async {
    var userId = user.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId.toString())
        .snapshots()
        .listen((userData) {
      isLiked = userData.data()?['isLikedFollowed'];
      isPost = userData.data()?['isPostComment'];
      isMention = userData.data()?['isMentionTags'];
      isNewMessage = userData.data()?['isNewMessage'];
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future updateData(String key, bool value) async {
    var userId = user.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId.toString())
        .update({key: value})
        .then((_) => print("Success"))
        .catchError(
          (error) => {print('Failed: $error')},
        );
  }
}

import 'package:flutter/material.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';

class ReadArtcileContainer extends StatefulWidget {
  final Function postClick;
  final Map<String, dynamic> post;
  const ReadArtcileContainer({
    super.key,
    required this.postClick,
    required this.post,
  });

  @override
  State<ReadArtcileContainer> createState() => _ReadArtcileContainerState();
}

class _ReadArtcileContainerState extends State<ReadArtcileContainer> {
  late Map<String, dynamic> post;
  List<String> imagesUrl = [];
  String timeAgo = "";
  @override
  void initState() {
    super.initState();
    initializeArraysVariable();
    // Replace this URL with the actual video URL from your post
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: Image.network(
                      post['user']['imageUrl'],
                      width: width * 0.032,
                      height: width * 0.032,
                    ).image)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(post['user']['name'].toString(),
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              )),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            extractUsernameFromEmail(
                                post['user']['email'].toString()),
                            style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(timeAgo,
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                          constraints: const BoxConstraints(maxHeight: 150.0),
                          child: Html(
                            data: post['postDetail'],
                          )),
                      GestureDetector(
                        onTap: () {
                          postId = post['postId'];
                          widget.postClick();
                        },
                        child: Container(
                          width: width * 0.07,
                          height: height * 0.05,
                          margin: const EdgeInsets.only(
                              bottom: 20, right: 20, top: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1, color: buttonColor),
                              borderRadius: BorderRadius.circular(
                                20,
                              )),
                          child: Center(
                              child: Text(
                            "Read Article",
                            style: TextStyle(
                                color: buttonColor,
                                fontFamily: GoogleFonts.lato().fontFamily,
                                fontSize: width * 0.009),
                          )),
                        ),
                      ),
                    ]),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20, right: 20),
                padding: const EdgeInsets.only(
                    bottom: 10, right: 20, top: 10, left: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: buttonColor),
                    borderRadius: BorderRadius.circular(
                      20,
                    )),
                child: Center(
                    child: Text(
                  "Follow",
                  style: TextStyle(
                      color: buttonColor,
                      fontFamily: GoogleFonts.lato().fontFamily,
                      fontSize: width * 0.009),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initializeArraysVariable() {
    post = widget.post;
    int timestampInMillis =
        post['timeStamp']; // Assuming it's stored as a UNIX timestamp

    DateTime postDateTime =
        DateTime.fromMillisecondsSinceEpoch(timestampInMillis);
    timeAgo = formatTimestampAgo(postDateTime);
  }
}

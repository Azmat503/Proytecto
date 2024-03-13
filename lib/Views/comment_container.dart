import 'package:flutter/material.dart';
import 'package:proyecto/Views/feedback_container.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentContainer extends StatefulWidget {
  final Map<String, dynamic>? comment;
  final String? commentcount;
  const CommentContainer({super.key, this.comment, this.commentcount});

  @override
  State<CommentContainer> createState() => _CommentContainerState();
}

class _CommentContainerState extends State<CommentContainer> {
  String timeAgo = "1h";
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    var comment = widget.comment;
    var commentcount = widget.commentcount;
    setState(() {
      timeAgo = "";
      initialTime(comment);
    });
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: comment?['user']['imageUrl'] != ""
                  ? CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: width * 0.02,
                      backgroundImage:
                          Image.network(comment?['user']['imageUrl'] ?? "")
                              .image,
                    )
                  : Image.asset(
                      "assets/person.png",
                      fit: BoxFit.contain,
                      width: width * 0.03,
                      height: width * 0.03,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment?['user']['name'] ?? "Omid Armin",
                            style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(comment?['user']['email'] ?? "@Omidarimn123",
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              )),
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
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          comment?['comment'].toString() ?? " ",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal)),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FeedbackContainer(commentCount: commentcount),
                    ]),
              ),
            ),
          ]),
    );
  }

  void initialTime(comment) {
    DateTime postDateTime =
        DateTime.fromMillisecondsSinceEpoch(comment?['timeStamp']);
    timeAgo = formatTimestampAgo(postDateTime);
  }
}

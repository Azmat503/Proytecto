import 'package:flutter/material.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackContainer extends StatefulWidget {
  final String? commentCount;
  const FeedbackContainer({super.key, this.commentCount});

  @override
  State<FeedbackContainer> createState() => _FeedbackContainerState();
}

class _FeedbackContainerState extends State<FeedbackContainer> {
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    var commentCount = widget.commentCount;

    return SizedBox(
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
          Image.asset(
            "assets/comment.png",
            width: 15,
            height: 15,
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
}

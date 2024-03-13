import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/my_utilities.dart';

class RecommendationContainer extends StatefulWidget {
  const RecommendationContainer({super.key});

  @override
  State<RecommendationContainer> createState() =>
      _RecommendationContainerState();
}

class _RecommendationContainerState extends State<RecommendationContainer> {
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return SizedBox(
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 20, bottom: 20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Image.asset(
                    "assets/profilepic.png",
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Jake Nacos",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600))),
                      Text("@jakenacos910",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  fontSize: 10, color: Colors.grey)))
                    ],
                  ),
                ]),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "THE POWER OF BUYING CHEAP ",
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  )),
                ),
                Container(
                  width: 70,
                  height: 30,
                  margin: const EdgeInsets.only(
                    bottom: 10,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1, color: buttonColor),
                      borderRadius: BorderRadius.circular(
                        20,
                      )),
                  child: Center(
                      child: Text(
                    "Read Article",
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(color: buttonColor, fontSize: 10)),
                  )),
                )
              ]),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:proyecto/Views/feedback_container.dart';
import 'package:proyecto/my_utilities.dart';

class TextPostContainer extends StatefulWidget {
  final Function postClick;

  const TextPostContainer({super.key, required this.postClick});

  @override
  State<TextPostContainer> createState() => _TextPostContainerState();
}

class _TextPostContainerState extends State<TextPostContainer> {
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                child: Image.asset(
                  "assets/person.png",
                  fit: BoxFit.contain,
                  width: width * 0.05,
                  height: width * 0.05,
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
                              "Omid Armin",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * 0.01,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              "@Omidarimn123",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: width * 0.01),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              "7h",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: width * 0.01),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.postClick();
                          },
                          child: Text(
                            postDetailText,
                            style: TextStyle(fontSize: width * 0.01),
                          ),
                        ),
                        const FeedbackContainer(),
                      ]),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 74,
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 20, right: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: buttonColor),
                  child: const Center(
                      child: Text(
                    "Follow",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
            ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:proyecto/Views/feedback_container.dart';
import 'package:proyecto/my_utilities.dart';

class VideoPostContainer extends StatefulWidget {
  const VideoPostContainer({super.key});

  @override
  State<VideoPostContainer> createState() => _VideoPostContainerState();
}

class _VideoPostContainerState extends State<VideoPostContainer> {
  @override
  Widget build(BuildContext context) {
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
                child: Image.asset("assets/person.png"),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              "Omid Armin",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              "@Omidarimn123",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              "7h",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute iru re dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."),
                        SizedBox(
                            width: double.infinity,
                            height: height * 0.6,
                            child: Center(
                              child: Stack(
                                children: [
                                  Image.asset(
                                    "assets/car.png",
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: height * 0.6,
                                  ),
                                  Center(
                                    widthFactor: 30,
                                    heightFactor: 30,
                                    child: Image.asset(
                                      "assets/videoplayer.png",
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const FeedbackContainer()
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
                      color: Colors.white,
                      border: Border.all(width: 1, color: buttonColor),
                      borderRadius: BorderRadius.circular(
                        20,
                      )),
                  child: Center(
                      child: Text(
                    "Follow",
                    style: TextStyle(color: buttonColor),
                  )),
                ),
              ),
            ]),
      ),
    );
  }
}

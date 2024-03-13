import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/my_utilities.dart' as util;
import 'package:flutter/foundation.dart';

class SocialMediaSignUpButton extends StatelessWidget {
  final String myIcon;
  final String buttonTitle;
  final double width;
  final double height;
  const SocialMediaSignUpButton(
      {Key? key,
      required this.myIcon,
      required this.buttonTitle,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenHeight = height * 0.08;
    var fontSSize = (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)
        ? 14.0
        : 16.0;
    var fontWeightt = (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)
        ? FontWeight.normal
        : FontWeight.w600;
    if (util.width <= 1046 && util.width >= 1024) {
      screenHeight = 70;
    } else {
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) {
        screenHeight = 60;
      } else {
        screenHeight = height * 0.08;
      }
    }
    return Container(
        height: screenHeight,
        width: width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular((screenHeight) / 2)),
        child: Align(
          alignment: Alignment.center,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(
              myIcon,
              width: 20,
              height: 20,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(buttonTitle,
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: fontSSize,
                        fontWeight: fontWeightt)))
          ]),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/my_utilities.dart';

class CustomUnderLineButton extends StatelessWidget {
  final String buttonTitle;
  final double width;
  final double height;
  final VoidCallback onButtonPressed;
  const CustomUnderLineButton(
      {Key? key,
      required this.buttonTitle,
      required this.width,
      required this.height,
      required this.onButtonPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onButtonPressed,
      child: SizedBox(
        width: width,
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                buttonTitle,
                style: GoogleFonts.lato(
                    textStyle:
                        TextStyle(color: CustomColors().buttonTextColor)),
              ),
              Container(
                height: 1,
                color: const Color.fromRGBO(166, 150, 72, 1),
              )
            ],
          ),
        ),
      ),
    );
  }
}

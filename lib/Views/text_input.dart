import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/my_utilities.dart';

class CustomTextInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool toHide;
  final String myLabel;
  const CustomTextInputField(
      {Key? key,
      required this.controller,
      required this.myLabel,
      this.toHide = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.sizeOf(context).width;
    height = MediaQuery.sizeOf(context).height;
    return Container(
      width: (width < 652) ? 400 : 500,
      height: 60,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular((70) / 2),
          border: Border.all(
            color: Colors.white,
            width: 1,
          )),
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: TextField(
          controller: controller,
          obscureText: toHide,
          style: GoogleFonts.lato(
              textStyle: const TextStyle(color: Colors.white, fontSize: 14)),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: myLabel,
            hintStyle: GoogleFonts.lato(
                textStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}

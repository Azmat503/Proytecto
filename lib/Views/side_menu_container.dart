import 'package:flutter/material.dart';
import 'package:proyecto/my_utilities.dart';

class SideMenuContainer extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonTitle;
  final String buttonIcon;
  final bool isSelected;
  const SideMenuContainer(
      {Key? key,
      required this.buttonIcon,
      required this.buttonTitle,
      required this.onPressed,
      required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color containerColor = isSelected ? buttonColor : Colors.transparent;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 150,
        height: 30,
        decoration: BoxDecoration(
            color: containerColor, borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(left: 0),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                buttonIcon,
                width: 16,
                height: 16,
              ),
              const SizedBox(
                width: 14,
              ),
              Text(buttonTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

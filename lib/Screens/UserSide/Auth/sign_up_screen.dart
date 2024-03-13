import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/Screens/UserSide/Auth/login_screen.dart';
import 'package:proyecto/Views/custom_underline_button.dart';
import 'package:proyecto/Views/text_input.dart';
import 'package:proyecto/my_utilities.dart';

import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController conPasswordController = TextEditingController();

  String dob = "";
  String month = "";
  String year = "";
  String date = "";
  bool isLoading = false;
  List<String> monthList = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<String> dayList = List.generate(31, (index) => (index + 1).toString());

  List<String> yearList =
      List.generate(100, (index) => (2024 - index).toString());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    var screenwidth = width;
    if (width <= 1046 && width >= 1024) {
      screenwidth = width * 0.8;
    } else {
      screenwidth = (width * 0.6 < 600) ? 500 : width * 0.6;
    }
    return Scaffold(
      backgroundColor: const Color.fromRGBO(37, 46, 53, 1),
      body: Container(
        alignment: Alignment.center,
        height: height,
        child: SingleChildScrollView(
          child: Container(
              width: screenwidth,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.0)),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 20, left: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              "assets/twitterIcon.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 20, top: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Image.asset(
                                  "assets/cross.png",
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Sign Up to Proyecto",
                        style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.white,
                                fontFamily: "Lato",
                                fontSize: 32,
                                fontWeight: FontWeight.w700)),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      CustomTextInputField(
                        controller: userNameController,
                        myLabel: "User Name",
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextInputField(
                        controller: emailController,
                        myLabel: "Email Address",
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: (width < 652) ? 400 : 500,
                        child: const Text(
                          "Date of Birth",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //if (width > 1044)
                      if (width > 495 &&
                          defaultTargetPlatform != TargetPlatform.iOS)
                        dateOfBirthDropDownWidget(),
                      if (defaultTargetPlatform == TargetPlatform.iOS ||
                          defaultTargetPlatform == TargetPlatform.android)
                        openDatePicker(),
                      // if (width < 1044) dateOfBirthColumn(),
                      //dateOfBirth(),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextInputField(
                        controller: passwordController,
                        myLabel: "Password",
                        toHide: true,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextInputField(
                        controller: conPasswordController,
                        myLabel: "Confirm Password",
                        toHide: true,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          dob = " $month $date, $year";
                          creatAccount(
                              context,
                              userNameController.text,
                              emailController.text,
                              dob,
                              passwordController.text);
                        },
                        child: Container(
                          height: 60,
                          width: (width < 500) ? 500 : 400,
                          decoration: BoxDecoration(
                              color: CustomColors().buttonColor,
                              borderRadius: BorderRadius.circular((60) / 2)),
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Sign Up",
                                    style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(" Have an account?",
                                style: GoogleFonts.lato(
                                    textStyle:
                                        const TextStyle(color: Colors.white))),
                            const SizedBox(
                              width: 2,
                            ),
                            CustomUnderLineButton(
                              buttonTitle: "Sign In",
                              width: 50,
                              height: height,
                              onButtonPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ));
                              },
                            ),
                          ],
                        ),
                      )
                    ]),
              )),
        ),
      ),
    );
  }

  Widget dateOfBirthDropDownWidget() {
    return SizedBox(
      width: (width < 652) ? 400 : 500,
      height: 70,
      child: DropdownDatePicker(
          inputDecoration: const InputDecoration(
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: "Month",
          ), // optional
          isDropdownHideUnderline: true, // optional
          isFormValidator: true, // optional
          startYear: 1990, // optional
          endYear: 2004, // optional
          width: 10,
          hintDay: "Day",
          hintMonth: "Month",
          hintYear: "Year",
          hintTextStyle: GoogleFonts.lato(
              textStyle: const TextStyle(color: Colors.grey, fontSize: 12)),
          textStyle: GoogleFonts.lato(
              textStyle: const TextStyle(
                  color: Colors.grey, fontSize: 12)), // optional
          onChangedDay: (value) {
            date = "$value";
          },
          onChangedMonth: (value) {
            month = getMonth(int.parse(value!));
          },
          onChangedYear: (value) {
            year = "$value";
          },
          boxDecoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular((height * 0.08) / 2))),
    );
  }

  Widget openDatePicker() {
    return GestureDetector(
      onTap: () {
        showDateTimePicker(context);
      },
      child: Container(
        width: 400,
        height: 60,
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white),
            borderRadius: BorderRadius.circular(30)),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(dob != "" ? dob : "Enter Date",
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget showSignUpFormInMBL() {
    return Container();
  }

  Future<void> showDateTimePicker(BuildContext context) async {
    DateTime? chosenDate;

    // Show Date Picker
    chosenDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1980),
      lastDate: DateTime(2004, 12, 31),
      initialDate: DateTime(2004),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light(), // Customize the theme if needed
          child: child!,
        );
      },
    );

    if (chosenDate != null) {
      month = getMonth(chosenDate.month);
      date = "${chosenDate.day}";
      year = "${chosenDate.year}";

      dob =
          "${getMonth(chosenDate.month)} ${chosenDate.day}, ${chosenDate.year}";
      setState(() {});
    }
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> creatAccount(
    BuildContext context,
    String userName,
    String eMail,
    String dob,
    String passowrd,
  ) async {
    setState(() {
      isLoading = true;
    });
    String name = userName;
    String email = eMail;
    String dateOfBirth = dob;
    String password = passowrd;
    dob = "$month $date, $year";
    if (name == "" ||
        email == "" ||
        password == "" ||
        conPasswordController.text == "") {
      showErrorAlert("Please fill all details", "Empty Field");
    } else {
      try {
        // Show circular loader while waiting for the asynchronous operation
        // showDialog(
        //   context: context,
        //   barrierDismissible:
        //       false, // Prevent the user from dismissing the dialog
        //   builder: (BuildContext context) {
        //     if (isLoading) {
        //       return const Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     } else {
        //       return Container();
        //     }
        //   },
        // );

        FirebaseAuth auth = FirebaseAuth.instance;
        final users = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (users.user != null) {
          var userid = users.user?.uid;
          await firestore.collection("Users").doc(userid).set({
            'email': email,
            'password': password,
            'name': name,
            'userId': userid,
            'follower': [],
            'following': [],
            'imageUrl':
                "https://firebasestorage.googleapis.com/v0/b/proyecto-3c7e7.appspot.com/o/imageplaceholder%20copy.png?alt=media&token=28107855-594f-47f1-a5c7-318f62f59a4e",
            'isLikedFollowed': false,
            'isLive': false,
            'isMentionTags': false,
            'isNewMessage': false,
            'isPostComment': false,
            'dob': dateOfBirth
          });
          isLoading = false;
          if (!mounted) return;
          setState(() {});
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (error) {
        isLoading = false;
        if (!mounted) return;
        showErrorAlert(error.toString(), "Ooops error occured");
      }
    }
  }

  Future showErrorAlert(error, title) {
    setState(() {
      isLoading = false;
    });
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text('An error occurred: $error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

//Extra code might be use in future:
  Widget dateOfBirth() {
    return SizedBox(
      width: 500,
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: buildDropdownField("Month", monthList)),
          const SizedBox(width: 20), // Adjust the width as needed
          Expanded(child: buildDropdownField("Day", dayList)),
          const SizedBox(width: 20), // Adjust the width as needed
          Expanded(child: buildDropdownField("Year", yearList)),
        ],
      ),
    );
  }

  Widget buildDropdownField(String labelText, List<String> items) {
    String? selectedItem; // Add a variable to hold the selected item

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular((70) / 2)),
      child: DropdownButtonFormField(
        value: selectedItem,
        hint: Text(
          labelText,
          style: const TextStyle(color: Colors.white),
        ),
        items: items.map((String item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(color: Colors.black)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          // Handle dropdown item selection
          // You can update the selected item here
          selectedItem = newValue;
        },
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((String item) {
            return Text(
              item,
              style: const TextStyle(
                  color: Colors.white), // Set selected text color
            );
          }).toList();
        },
        style: const TextStyle(color: Colors.white),
        icon: const SizedBox.shrink(),
        decoration: const InputDecoration(
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/Screens/UserSide/Auth/sign_up_screen.dart';
import 'package:proyecto/Views/custom_underline_button.dart';
import 'package:proyecto/Views/social_media_buttons.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(37, 46, 53, 1),
      body: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
              width: (width * 0.6 < 600) ? 500 : width * 0.6,
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
                      const Text(
                        "Sign In to Proyecto",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Lato",
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SocialMediaSignUpButton(
                          myIcon: "assets/google.png",
                          buttonTitle: "Sign in with google",
                          width: 400,
                          height: height),

                      const SizedBox(
                        height: 10,
                      ),
                      SocialMediaSignUpButton(
                          myIcon: "assets/apple.png",
                          buttonTitle: "Sign in with apple",
                          width: 400,
                          height: height),

                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 30,
                        width: 399,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  color: Colors.white,
                                  height: 0.3,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text("Or",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Lato",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                      color: Colors.white, height: 0.3)),
                            ]),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //
                      Container(
                        width: 400,
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular((60) / 2),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            )),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: TextField(
                            controller: emailController,
                            style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Phone, Email, Username..",
                              hintStyle: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      //
                      Container(
                        width: 400,
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular((60) / 2),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            )),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                              hintStyle: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: () {
                          signAccount();
                        },
                        child: Container(
                          height: 60,
                          width: 400,
                          decoration: BoxDecoration(
                              color: CustomColors().buttonColor,
                              borderRadius: BorderRadius.circular((60) / 2)),
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : const Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomUnderLineButton(
                        buttonTitle: "Forgot Password?",
                        width: 120,
                        height: height,
                        onButtonPressed: () {},
                      ),

                      const SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don’t have an account?",
                                style: TextStyle(color: Colors.white)),
                            const SizedBox(
                              width: 2,
                            ),
                            CustomUnderLineButton(
                              buttonTitle: "Sign Up",
                              width: 50,
                              height: height,
                              onButtonPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen(),
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

  void signAccount() async {
    setState(() {
      isLoading = true;
    });
    String password = passwordController.text.trim();

    String email = emailController.text.trim();
    if (email.isEmpty && password.isEmpty) {
      showErrorAlert("Email and Password required", "");
    } else {
      try {
        FirebaseAuth auth = FirebaseAuth.instance;
        final users = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (users.user != null) {
          setState(() {
            isLoading = false;
          });
          saveValue();
          goToHomeScreen();
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        String errorMessage = "An error occurred. Please try again.";

        if (error is FirebaseAuthException) {
          switch (error.code) {
            case 'user-not-found':
              errorMessage = "User not found. Please check your email.";
              break;
            case 'wrong-password':
              errorMessage = "Invalid password. Please try again.";
              break;
            default:
              errorMessage = "Authentication failed. Please try again.";
          }
        } else {
          errorMessage = "An unexpected error occurred. Please try again.";
        }

        showErrorAlert(errorMessage, "An unexpected error occurred");
      }
    }
  }

  void goToHomeScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  saveValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('role', "user");
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
}

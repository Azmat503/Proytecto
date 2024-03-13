import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/Screens/UserSide/Auth/login_screen.dart';
import 'package:proyecto/Screens/UserSide/Auth/sign_up_screen.dart';
import 'package:proyecto/Views/custom_underline_button.dart';
import 'package:proyecto/Views/social_media_buttons.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    var screenHeight = height * 0.08;
    if (width <= 1046 && width >= 1024) {
      screenHeight = 70;
    } else {
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) {
        screenHeight = 60;
      } else {
        screenHeight = height * 0.08;
      }
    }
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
                    mainAxisAlignment: MainAxisAlignment.start,
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
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       left: 10.0, right: 20, top: 10),
                          //   child: Align(
                          //     alignment: Alignment.topLeft,
                          //     child: Image.asset(
                          //       "assets/cross.png",
                          //       width: 20,
                          //       height: 20,
                          //       fit: BoxFit.contain,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Welcome to Proyecto!",
                        style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w700)),
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
                              Text("Or",
                                  style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500))),
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ));
                        },
                        child: Container(
                          height: screenHeight,
                          width: 400,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular((screenHeight) / 2)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Create Account",
                              style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: (defaultTargetPlatform ==
                                                  TargetPlatform.iOS ||
                                              defaultTargetPlatform ==
                                                  TargetPlatform.android)
                                          ? 14.0
                                          : 16.0,
                                      fontWeight: (defaultTargetPlatform ==
                                                  TargetPlatform.iOS ||
                                              defaultTargetPlatform ==
                                                  TargetPlatform.android)
                                          ? FontWeight.normal
                                          : FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        width: 400,
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(children: [
                          Image.asset(
                            "assets/checkbox.png",
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          privacyPolicyLinkAndTermsOfService(context),
                        ]),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Have an account?",
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

  Widget privacyPolicyLinkAndTermsOfService(BuildContext context) {
    return Expanded(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "By signing up, you agree to the\t\t",
              style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              )),
            ),
            TextSpan(
              text: 'Terms of Service',
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                color: CustomColors().buttonTextColor,
                fontWeight: FontWeight.normal,
                fontSize: 10,
                decoration: TextDecoration.underline,
              )),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Handle "Terms of Service" tap
                },
            ),
            TextSpan(
              text: "\t\tand\t\t",
              style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.normal)),
            ),
            TextSpan(
                text: 'Privacy Policy',
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                  color: CustomColors().buttonTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  decoration: TextDecoration.underline,
                )),
                recognizer: TapGestureRecognizer()..onTap = () {}),
            TextSpan(
              text: "\t\tincluding\t\t",
              style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.normal)),
            ),
            TextSpan(
              text: 'Cookie Use',
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                color: CustomColors().buttonTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                decoration: TextDecoration.underline,
              )),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Handle "Cookie Use" tap
                },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/Screens/Admin/ApproveArticle/approve_article_screen.dart';
import 'package:proyecto/Screens/Admin/Topic/topic_screen.dart';
import 'package:proyecto/my_utilities.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  var isTopicHover = false;
  var isApprovedHover = false;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(37, 46, 53, 1),
      body: SizedBox(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                width: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Admin Panel",
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(
                  height: 20,
                ),
                MouseRegion(
                  onHover: (event) {
                    isTopicHover = true;
                    isApprovedHover = false;
                    setState(() {});
                  },
                  onExit: (event) {
                    isTopicHover = false;
                    isApprovedHover = false;
                    setState(() {});
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(createTopicRoute());

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => const TopicScreen(),
                      //     ));
                    },
                    child: Container(
                      height: 60,
                      width: 400,
                      decoration: BoxDecoration(
                        color: isTopicHover == false
                            ? Colors.black
                            : CustomColors().buttonColor,
                        borderRadius: BorderRadius.circular((60) / 2),
                        border: Border.all(width: 1, color: buttonColor),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Add Topic",
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTopicHover == false ? 14 : 15,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                MouseRegion(
                  onHover: (event) {
                    isTopicHover = false;
                    isApprovedHover = true;
                    setState(() {});
                  },
                  onExit: (event) {
                    isTopicHover = false;
                    isApprovedHover = false;
                    setState(() {});
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(createApproveArticleRoute());
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => const ApproveArticleScreen(),
                      //     ));
                    },
                    child: Container(
                      height: 60,
                      width: 400,
                      decoration: BoxDecoration(
                        color: isApprovedHover == false
                            ? Colors.black
                            : CustomColors().buttonColor,
                        borderRadius: BorderRadius.circular((60) / 2),
                        border: Border.all(width: 1, color: buttonColor),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Approve Articles",
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: isApprovedHover == false ? 14 : 15,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Route createTopicRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const TopicScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  Route createApproveArticleRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ApproveArticleScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}

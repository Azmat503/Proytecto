import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/Model/post_model.dart';
import 'package:proyecto/Model/side_menu_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String catName = "ALL";
  String catId = "0";
  bool isHover = false;
  bool isSelected = false;
  CategoryModel(
      {required this.catId, required this.catName, required this.isSelected});
}

final List<String> chapterList = [];
String studyTitle = "";
List<TextEditingController> textEditingControllerList = [
  TextEditingController()
];

List<CategoryModel> onlyCategoriesList = [];
var firebaseFirestore = FirebaseFirestore.instance;
Color buttonColor = const Color.fromRGBO(166, 150, 72, 1);
Color backgroundColor = const Color.fromRGBO(248, 249, 250, 1);
Color dullWhiteColor = const Color.fromRGBO(246, 247, 250, 1);
Color postButtonColor = const Color.fromRGBO(166, 150, 72, 0.12);
Color postColor = const Color.fromRGBO(166, 150, 72, 0.6);
Color textColor = Colors.white;
var studySelectedIndex = 0;
double height = 0;
double width = 0;
var touchmatchMedia = false;
var postId = "";
var selectedUserId = "";
var imagePlaceHolder =
    "https://firebasestorage.googleapis.com/v0/b/proyecto-3c7e7.appspot.com/o/imageplaceholder%20copy.png?alt=media&token=28107855-594f-47f1-a5c7-318f62f59a4e";

Map<String, dynamic>? userFullData;
TextStyle textStyle = GoogleFonts.lato(
  textStyle: TextStyle(
    color: Colors.black,
    fontSize: width * 0.008,
    fontWeight: FontWeight.bold,
  ),
);
String formatTimestamp(int timestampMilliseconds) {
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

  // Use DateFormat to format the date with the name of the day
  return DateFormat('EEE, MMMM d,').format(dateTime);
}

String fetchDateFromTimeStamp(int timestampMilliseconds) {
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

  // Use DateFormat to format the date with the name of the day
  return DateFormat.jm().format(dateTime);
}

String extractUsernameFromEmail(String email) {
  List<String> parts = email.split('@');
  return parts.first;
}

class MyUtility {
  BuildContext context;
  MyUtility(this.context);
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
}

class CustomColors {
  var buttonColor = const Color.fromRGBO(166, 150, 72, 1);
  var buttonTextColor = const Color.fromRGBO(166, 150, 72, 1);
}

var sideMenuList = [
  SideMenuModel(
      icon: "assets/newfeed.png", title: "New Feed", isSelected: true),
  SideMenuModel(icon: "assets/post.png", title: "Posts", isSelected: false),
  SideMenuModel(
      icon: "assets/article.png", title: "Article", isSelected: false),
  SideMenuModel(
      icon: "assets/studies.png", title: "Studies", isSelected: false),
  SideMenuModel(icon: "assets/event.png", title: "Event", isSelected: false),
  SideMenuModel(icon: "assets/event.png", title: "Messages", isSelected: false)
];

var postDetailText =
    "Heyy Mutuals!If any of you is going through the bad phrase (depression, mental trauma or anything). Can text me as i am a good listener / adviserP.S: I won’t expect anything in return…";
var articleDetailText =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis auteirure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt. \n Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quaeabillo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur autodit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsumquia dolor sit amet,  consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam.Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? \n At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat";
var eventDetailText =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis auteirure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quaeabillo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur autodit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsumquia dolor sit amet,  consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam.";
var profileInfoText =
    "24 | Believe in your selfie. Never let people treat you like you're ordinary. Be your own kind of beautiful";
List<PostModel> newFeedList = [];

String formatTimestampAgo(DateTime timestamp) {
  Duration difference = DateTime.now().difference(timestamp);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds} sec';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hr';
  } else {
    // Customize this part as needed for days, weeks, etc.
    return DateFormat.yMd().format(timestamp);
  }
}

String getMonth(int month) {
  switch (month) {
    case DateTime.january:
      return "January";
    case DateTime.february:
      return "February";
    case DateTime.march:
      return "March";
    case DateTime.april:
      return "April";
    case DateTime.may:
      return "May";
    case DateTime.june:
      return "June";
    case DateTime.july:
      return "July";
    case DateTime.august:
      return "August";
    case DateTime.september:
      return "September";
    case DateTime.october:
      return "October";
    case DateTime.november:
      return "November";
    case DateTime.december:
      return "December";
    default:
      return "";
  }
}

Future<void> getCategoriesList() async {
  firebaseFirestore
      .collection("ArticleCategory")
      .limit(20)
      .snapshots()
      .listen((allPostSnapshot) {
    onlyCategoriesList.clear();
    for (DocumentSnapshot data in allPostSnapshot.docs) {
      var post = data.data() as Map<String, dynamic>;
      var model = CategoryModel(
          catId: post['categoryId'],
          catName: post['categoryName'],
          isSelected: false);
      onlyCategoriesList.add(model);
    }
  });
}

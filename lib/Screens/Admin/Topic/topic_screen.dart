import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:proyecto/Screens/UserSide/Article/article_screen.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopicModel {
  bool isSelected = false;
  var topicName = "";
  var topicId = "";
  TopicModel(
      {required this.topicName,
      required this.isSelected,
      required this.topicId});
}

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  TextEditingController textEditingController = TextEditingController();
  List<TopicModel> allCategoriesList = [];
  //TopicModel? topicModel;
  final firebaseFirestore = FirebaseFirestore.instance;
  int editableIndex = -1;
  @override
  void initState() {
    super.initState;
    getAllPost();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.sizeOf(context).width;
    height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SizedBox(
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              homeProfileContainer(),
              addTopicWiget(context),
              const SizedBox(height: 10),
              topicListViewContainer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget homeProfileContainer() {
    return Container(
      width: width,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(left: 20, bottom: 20, top: 20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  child: Row(children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        "assets/back.png",
                        width: 15,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Add Topic",
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ]),
                )
              ]),
            ),
          ]),
    );
  }

  Widget addTopicWiget(context) {
    //var width = MediaQuery.sizeOf(context).width;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 0.9,
          color: Colors.black.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Topic",
            style: GoogleFonts.lato(
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          addTopicEditngControllerWidget(),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              saveCategory(textEditingController.text);
            },
            child: Container(
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(15)),
                child: const Center(child: Text("Add"))),
          )
        ],
      ),
    );
  }

  Widget addTopicEditngControllerWidget() {
    return Container(
      width: width - 20,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          width: 0.9,
          color: Colors.black.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: textEditingController,
        style: GoogleFonts.lato(
            textStyle: const TextStyle(color: Colors.black, fontSize: 14)),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Write Topic ",
          hintStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget topicListViewContainer() {
    return const CustomListItemContainer();
  }

  void getAllPost() async {
    getAllCategoriesList();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getAllCategoriesList() async {
    firebaseFirestore
        .collection("ArticleCategory")
        .limit(20)
        .snapshots()
        .listen((allPostSnapshot) {
      allCategoriesList.clear();
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        var topicModel = TopicModel(
            topicName: post["categoryName"],
            isSelected: false,
            topicId: post["categoryId"]);
        allCategoriesList.add(topicModel);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> saveCategory(
    String category,
  ) async {
    // Extract relevant user information
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    await firebaseFirestore
        .collection('ArticleCategory')
        .doc(timeStamp.toString())
        .set({
      "categoryName": category,
      "categoryId": "$timeStamp",
    }).then((val) {
      textEditingController.text = "";

      if (mounted) {
        setState(() {});
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onEditTap(int index) {
    // Set the index of the tapped item to be editable
    setState(() {
      editableIndex = index;
    });
  }
}

class CustomListItemContainer extends StatefulWidget {
  const CustomListItemContainer({
    super.key,
  });

  @override
  State<CustomListItemContainer> createState() =>
      _CustomListItemContainerState();
}

class _CustomListItemContainerState extends State<CustomListItemContainer> {
  final firebaseFirestore = FirebaseFirestore.instance;
  final List<TopicModel> allCategoriesList = [];
  var readOnly = true;
  @override
  void initState() {
    super.initState();
    getAllPost();
  }

  @override
  Widget build(BuildContext context) {
    return topicListContainer();
  }

  Widget topicListContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 0.5,
            color: Colors.black.withOpacity(0.09),
          ),
          borderRadius: BorderRadius.circular(10)),
      child: ListView.separated(
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          var data = allCategoriesList[index];
          return topicListTileContainer(data, index);
        },
        itemCount: allCategoriesList.length,
        separatorBuilder: (context, index) {
          return Divider(
            height: 0.9,
            color: Colors.grey.withOpacity(0.2),
          );
        },
      ),
    );
  }

  Widget topicListTileContainer(TopicModel data, index) {
    var categoryName = data.topicName;
    var categoryId = data.topicId;

    TextEditingController categoryEditingController =
        TextEditingController(text: categoryName);
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Container(
            width: width - 150,
            height: 40,
            padding: const EdgeInsets.only(right: 20),
            child: TextField(
              controller: categoryEditingController,
              readOnly: !allCategoriesList[index].isSelected,
              autofocus: false,
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: (allCategoriesList[index].isSelected == false)
                        ? FontWeight.w500
                        : FontWeight.w600),
              ),
              decoration: InputDecoration(
                border: (allCategoriesList[index].isSelected == false)
                    ? InputBorder.none
                    : const OutlineInputBorder(),
              ),
            ),
          ),
        ),
        //Text(categoryName),
        Row(
          children: [
            if (allCategoriesList[index].isSelected == false)
              Align(
                child: GestureDetector(
                  onTap: () {
                    //  widget.onEditTap();
                    for (var i in allCategoriesList) {
                      i.isSelected = false;
                    }
                    allCategoriesList[index].isSelected =
                        !allCategoriesList[index].isSelected;
                    setState(() {});
                  },
                  child: Text(
                    "Edit",
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: (allCategoriesList[index].isSelected == false)
                              ? const Color.fromARGB(255, 3, 95, 171)
                              : const Color.fromARGB(255, 244, 4, 4),
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            if (allCategoriesList[index].isSelected == true)
              Align(
                child: GestureDetector(
                  onTap: () {
                    for (var i in allCategoriesList) {
                      i.isSelected = false;
                    }
                    setState(() {});

                    updateCategory(categoryId, categoryEditingController.text);
                  },
                  child: Text(
                    "Done",
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: (allCategoriesList[index].isSelected == false)
                              ? const Color.fromARGB(255, 3, 95, 171)
                              : const Color.fromARGB(255, 244, 4, 4),
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                deleteCategory(categoryId);
              },
              child: Text(
                "Delete",
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                      color: Color.fromARGB(255, 3, 95, 171),
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            )
          ],
        )
      ]),
    );
  }

  Future<void> deleteCategory(String catId) async {
    firebaseFirestore.collection('ArticleCategory').doc(catId).delete();
  }

  Future<void> updateCategory(String catId, String catName) async {
    firebaseFirestore
        .collection('ArticleCategory')
        .doc(catId)
        .update({"categoryName": catName}).then((value) {});
  }

  void getAllPost() async {
    getAllCategoriesList();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getAllCategoriesList() async {
    firebaseFirestore
        .collection("ArticleCategory")
        .limit(20)
        .snapshots()
        .listen((allPostSnapshot) {
      allCategoriesList.clear();
      for (DocumentSnapshot data in allPostSnapshot.docs) {
        var post = data.data() as Map<String, dynamic>;
        var topicModel = TopicModel(
            topicName: post["categoryName"],
            isSelected: false,
            topicId: post["categoryId"]);
        allCategoriesList.add(topicModel);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }
}

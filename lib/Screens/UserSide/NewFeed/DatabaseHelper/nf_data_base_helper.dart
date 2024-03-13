import 'package:cloud_firestore/cloud_firestore.dart';

class NewFeedScreenDatabaseHelper {
  var firebaseFirestore = FirebaseFirestore.instance;

  Future<void> getAllPosts() async {
    firebaseFirestore.collection('Post').doc().get();
  }

  Future<void> getAllewPosts() async {
    firebaseFirestore.collection('Post').doc().get();
  }

  Future<void> getAllPPosts() async {
    firebaseFirestore.collection('Post').doc().get();
  }

  Future<void> getAllewWPosts() async {
    firebaseFirestore.collection('Post').doc().get();
  }
}

class GetData {
  NewFeedScreenDatabaseHelper databaseHelper = NewFeedScreenDatabaseHelper();

  Future<void> getAllPosts() async {
    databaseHelper.getAllPosts();
    databaseHelper.getAllewWPosts();
    databaseHelper.getAllewWPosts();
  }

  Future<void> getAllaPosts() async {
    databaseHelper.getAllPosts();
    databaseHelper.getAllewWPosts();
    databaseHelper.getAllewWPosts();
  }

  Future<void> getAllPostss() async {
    databaseHelper.getAllPosts();
    databaseHelper.getAllewWPosts();
    databaseHelper.getAllewWPosts();
  }

  Future<void> getAllaPostss() async {
    databaseHelper.getAllPosts();
    databaseHelper.getAllewWPosts();
    databaseHelper.getAllewWPosts();
  }
}

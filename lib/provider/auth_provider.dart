import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_auth/constants/app_constants.dart';
import 'package:flutter_otp_auth/model/user_model.dart';
import 'package:flutter_otp_auth/pages/otp_page.dart';
import 'package:flutter_otp_auth/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthProvider extends ChangeNotifier{
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _uid;
  String get uid => _uid!;

  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  final FirebaseAuth _firebaseAuth =  FirebaseAuth.instance;
  get firebaseAuth => _firebaseAuth;

  final FirebaseFirestore _firebaseFireStore =  FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage=  FirebaseStorage.instance;


  AuthProvider(){
    checkSignIn();
  }

  void checkSignIn() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    /// if AppConstants.IS_SIGNED is empty, means the user has not logged in
    _isSignedIn = sharedPreferences.getBool(AppConstants.IS_SIGNED) ?? false ;
    notifyListeners();
  }

  Future setSignIn() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    /// if AppConstants.IS_SIGNED is empty, means the user has not logged in
    sharedPreferences.setBool(AppConstants.IS_SIGNED, true) ;
    _isSignedIn = true;
    notifyListeners();
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        /// after OTP is completed
          verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          /// error
          verificationFailed: (error){
            showSnackBar(context, error.message.toString());
            throw Exception(error.message);
          },
          /// OTP was sent
          codeSent: (verificationId, forceResendToken){
            /// navigate to OTPPage
            Navigator.push(context, MaterialPageRoute(builder: (context) => OTPPage(verificationId: verificationId)));
          },
          /// resend code
          codeAutoRetrievalTimeout: ((verificationID){

          })
      );
    }
    on FirebaseException catch (e){
      /// error
      showSnackBar(context, e.toString());
    }
  }

  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess
  }) async{
    _isLoading = true;
    notifyListeners();

    try{
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: userOtp);
      var signInUser = await _firebaseAuth.signInWithCredential(credential);
      User? user = (signInUser).user!;

      if(user != null){
        ///carry user logic
        // user.phoneNumber;

        _uid =  user.uid;
        onSuccess();
      }

      _isLoading = false;
      notifyListeners();
    }
    on FirebaseException catch(e){
      /// error
      _isLoading = false;
      notifyListeners();

      showSnackBar(context, e.message.toString());
      throw e.message.toString();
    }
  }


  /// Database operations
  Future<bool> checkExistingUser() async{
    DocumentSnapshot snapshot = await _firebaseFireStore.collection(AppConstants.USERS).doc(_uid).get();
    if(snapshot.exists){
      print("----->[AuthProvider] User exists in the database");
      return true;
    }
    else{
      return false;
    }
  }

  void saveUserDataToFirebase({required BuildContext context,
    required UserModel userModel,
    required File profilePic,
    required Function onSuccess}) async {
    _isLoading = true;
    notifyListeners();
    try{
      ///uploading image to firebase storage
       await storeFileToStorage("profilePic/$_uid", profilePic).then((value) {
        /// on success, update user model
        userModel.profilePic = value;
        userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();
        userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        // userModel.uid = _firebaseAuth.currentUser!.uid!;
        userModel.uid = _uid!;
      });
      _userModel = userModel;
      ///uploading data to database
      await _firebaseFireStore
          .collection(AppConstants.USERS)
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
            onSuccess();
            _isLoading = false;
            notifyListeners();
          });

    }
    on FirebaseException catch(e){
      _isLoading = false;
      showSnackBar(context, e.toString());
      notifyListeners();
      throw e.toString();
    }
  }

  Future<String> storeFileToStorage(String ref, File file) async{
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future getDataFromFirestore() async{
    await _firebaseFireStore
        .collection(AppConstants.USERS)
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
          _userModel = UserModel(
              name: snapshot['name'],
              email: snapshot['email'],
              bio: snapshot['bio'],
              profilePic: snapshot['profilePic'],
              createdAt: snapshot['createdAt'],
              phoneNumber: snapshot['phoneNumber'],
              uid: snapshot['uid']
          );
          _uid = userModel.uid;
        });
  }

  /// storing data locally.
  Future saveUserDataToSharedPreference() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(AppConstants.USER_MODEL, jsonEncode(userModel.toMap()));
  }

  Future getDataFromSharedPreference() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String data = sharedPreferences.getString(AppConstants.USER_MODEL) ?? "";
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = userModel.uid;
    notifyListeners();
  }

  Future userSignOut() async {
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    clearSharedPreference();
  }

  Future clearSharedPreference() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }
}
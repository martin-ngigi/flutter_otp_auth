import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_auth/model/user_model.dart';
import 'package:flutter_otp_auth/pages/home_screen.dart';
import 'package:flutter_otp_auth/provider/auth_provider.dart';
import 'package:flutter_otp_auth/utils/utils.dart';
import 'package:flutter_otp_auth/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({Key? key}) : super(key: key);

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {

  File? image;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  /// for selecting image
  void selectImage() async{
    image = await pickImage(context);
    /// then update
    setState(() {
      //nameController.text = image!.path.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body:SafeArea(
          child: isLoading == true ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          ) : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 5),
            child:  Center(
              child: Column(
                children: [
                  /// profile
                  InkWell(
                    onTap: ()
                    {
                      print("---------> [UserInformationPage] You have tapped profile pic");
                      selectImage();
                    },
                    child: image == null ? const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 50,
                      child: Icon(
                        Icons.account_circle,
                        size: 50,
                        color: Colors.white,
                      ),
                    ) : CircleAvatar(
                      backgroundImage: FileImage(image!),
                      radius: 50,
                    ),
                  ),

                  Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    margin: EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        /// name field
                        textField(
                            hintText: "Your name...",
                            icon: Icons.account_circle,
                            textInputType: TextInputType.name,
                            maxLines: 1,
                            controller: nameController
                        ),
                        /// email field
                        textField(
                            hintText: "Your email...",
                            icon: Icons.email_outlined,
                            textInputType: TextInputType.emailAddress,
                            maxLines: 1,
                            controller: emailController
                        ),
                        /// bio field
                        textField(
                            hintText: "Your bio data...",
                            icon: Icons.note,
                            textInputType: TextInputType.text,
                            maxLines: 4,
                            controller: bioController
                        ),
                        const SizedBox(height: 20,),
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.80,
                          child: CustomButton(
                              text: "Continue",
                              onPressed: (){
                                storeDaya();
                              }
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
      )
    );
  }

  Widget textField({
    required String hintText,
    required IconData icon,
    required TextInputType textInputType,
    required int maxLines,
    required TextEditingController controller
  }){
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        cursorColor: Colors.green,
        controller: controller,
        keyboardType: textInputType,
        maxLines: maxLines,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.grey.shade600
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black)
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.green)
            ),
            prefixIcon: Container(
              padding: EdgeInsets.all(8),
              child: Icon(icon, color: Colors.black,),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(8),
              //   color: Colors.green
              // ),
            ),
            suffixIcon: Icon(Icons.edit, color: Colors.black,),
          alignLabelWithHint: true,
          fillColor: Colors.grey[300],
          filled: true
        ),
      ),
    );
  }

  void storeDaya() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        bio: bioController.text.trim(),
        profilePic: "",
        createdAt: "",
        phoneNumber: "",
        uid: ""
    );
    if(image != null){
      ap.saveUserDataToFirebase(
          context: context,
          userModel: userModel,
          profilePic: image!,
          onSuccess: (){
            /// once data is saved, we need to store it locally.
            ap.saveUserDataToSharedPreference().then((value) {
              ap.setSignIn().then((value) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false
                );
              });
            });
          }
      );
    }
    else{
      showSnackBar(context, "Please upload your profile photo");
    }
  }
}

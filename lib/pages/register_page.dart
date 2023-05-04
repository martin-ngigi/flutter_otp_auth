import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_auth/provider/auth_provider.dart';
import 'package:flutter_otp_auth/utils/utils.dart';
import 'package:flutter_otp_auth/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = Country(
      phoneCode: "+254",
      countryCode: "KE",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "Kenya",
      example: "Kenya",
      displayName: "Kenya",
      displayNameNoCountryCode: "Kenya",
      e164Key: ""
  );
  @override
  Widget build(BuildContext context) {
    /// this will prevent the text from appearing in reverse order
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: phoneController.text.length)
    );
    return  Scaffold(
      body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 35),
              child: Column(
                children: [
                  Container(
                    width: double.maxFinite,
                    height: 200,
                    // padding: EdgeInsets.all(20),
                    // decoration: BoxDecoration(
                    //   shape: BoxShape.circle,
                    //   color: Colors.green
                    // ),
                    child: Image.asset(
                        "assets/register.jpeg"
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text(
                    "Add your phone number, we will send you a verification code",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    cursorColor: Colors.green,
                    controller: phoneController,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    onChanged: (value){
                      setState(() {
                        phoneController.text = value;
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter phone number",
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
                        child: InkWell(
                          onTap: (){
                            /// display all countries
                            showCountryPicker(
                                context: context,
                                countryListTheme:const CountryListThemeData(
                                  bottomSheetHeight: 550, /// height of the container of all the countries
                                ),
                                onSelect: (value){
                                  setState(() {
                                    selectedCountry = value;
                                  });
                            });
                          },
                          child: Text(
                            "${selectedCountry.flagEmoji} ${selectedCountry.phoneCode}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      suffixIcon: phoneController.text.length >= 9 ? Container(
                        height: 30,
                        width: 30,
                        margin: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 20,
                        ),
                      ) : null
                    ),
                  ),
                  const SizedBox(height: 20,),

                  /// login button
                  phoneController.text.length >= 9 ? SizedBox(
                    width: double.maxFinite,
                    height: 50,
                    child: CustomButton(
                        text: "Login",
                        onPressed: (){
                          sendPhoneNumber();
                        }
                    ),
                  ) : SizedBox.shrink()
                ],
              ),
            ),
          )
      ),
    );
  }

  void sendPhoneNumber(){
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    ap.signInWithPhone(context, "${selectedCountry.phoneCode}${phoneNumber}");
  }

}

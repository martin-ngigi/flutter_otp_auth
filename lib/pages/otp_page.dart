import 'package:flutter/material.dart';
import 'package:flutter_otp_auth/pages/home_screen.dart';
import 'package:flutter_otp_auth/pages/user_information_page.dart';
import 'package:flutter_otp_auth/provider/auth_provider.dart';
import 'package:flutter_otp_auth/utils/utils.dart';
import 'package:flutter_otp_auth/widgets/custom_button.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPPage extends StatefulWidget {
  final String verificationId;
  const OTPPage({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  TextEditingController pinController = TextEditingController();

  String? otpCode;
  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
          child: isLoading == true ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          ) : Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 35),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  Container(
                    // width: 200,
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
                    "Verification",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text(
                    "Enter OTP that was sent to your number",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20,),

                  ///pin input
                  Pinput(
                    length: 6,
                    showCursor: true,
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.green
                        )
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                      )
                    ),
                    onCompleted: (value){
                      otpCode = value;
                    },
                    /// sms autofill
                    androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
                    controller: pinController,
                  ),
                  const SizedBox(height: 25,),
                  ///verify button
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: CustomButton(
                        text: "Verify",
                        onPressed: (){
                          if(otpCode != null){
                            verifyOTP(context, otpCode!, pinController);
                          }
                          else{
                            print("-----> [OTPPage] Enter 6-digit code");
                            showSnackBar(context, "Enter 6-digit code");
                          }
                        }
                    ),
                  ),
                  const SizedBox(height: 40,),

                  /// Didn't receive any code ?
                  const Text(
                      "Didn't receive any code ?",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38
                    ),
                  ),
                  const SizedBox(height: 8,),

                  const Text(
                    "Resend new code",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }

  void verifyOTP(BuildContext context, String userOTP, TextEditingController pinController){
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
        context: context,
        verificationId: widget.verificationId,
        userOtp: userOTP,
        pinController: pinController,
        onSuccess: (){
          /// checking whether user exists in the db.
          ap.checkExistingUser().then((value) async{
            if(value == true){
              /// user exists in our app
              ap.getDataFromFirestore()
                  .then((value) => ap.saveUserDataToSharedPreference()
                  .then((value) => ap.setSignIn()
                  .then((value) =>  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen() ), (route) => false))));
            }
            else{
              /// new user
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const UserInformationPage() ), (route) => false);
            }
          });
        }
    );
  }

}

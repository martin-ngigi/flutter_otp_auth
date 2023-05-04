import 'package:flutter/material.dart';
import 'package:flutter_otp_auth/pages/register_page.dart';
import 'package:flutter_otp_auth/widgets/custom_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/welcome2.jpg",
                    height: 300,
                  ),
                  const SizedBox(height: 20,),
                  const Text(
                    "Lets get started",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  const Text(
                    "Never a better time than to start now",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    width: double.maxFinite,
                    height: 50,
                    child: CustomButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
                      },
                      text: "Get started",
                    ),
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
}

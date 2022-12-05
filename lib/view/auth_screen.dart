import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:upmarket_test/res/utils.dart';
import 'package:upmarket_test/view/home_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController _mobileController = TextEditingController();

  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> verifyPhone(BuildContext context, String mobile) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: "+91$mobile",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException error) {},
      codeSent: (String verificationId, int? forceResendingToken) {
        log(verificationId);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => OtpScreen(
                      number: mobile,
                      verificationId: verificationId,
                    )));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(21),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Number"),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: width(context),
              child: ElevatedButton(
                  onPressed: () {
                    if (_mobileController.text.trim().isNotEmpty &&
                        _mobileController.text.trim().length == 10) {
                      verifyPhone(context, _mobileController.text.trim());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill correct number")));
                    }
                  },
                  child: const Text("Sign In")),
            )
          ],
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String number;
  final String verificationId;

  const OtpScreen(
      {Key? key, required this.number, required this.verificationId})
      : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> verifyOTP(
      BuildContext context, String verificationId, String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.trim(), smsCode: otp);

    await _firebaseAuth.signInWithCredential(credential).then((value) async {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(21),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pinput(
              controller: _otpController,
              length: 6,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: width(context),
              child: ElevatedButton(
                  onPressed: () {
                    verifyOTP(context, widget.verificationId,
                        _otpController.text.trim());
                  },
                  child: const Text("Verify")),
            )
          ],
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialnetworkapp/loginControl/registerPage.dart';
import 'package:socialnetworkapp/widgets/CustomButton.dart';
import 'package:socialnetworkapp/widgets/CustomInput.dart';

class UserLoginPage extends StatefulWidget {
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {

  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Hata"),
            content: Container(
              child: Text(error),
            ),
            actions: [
              TextButton(
                child: Text("Pencereyi Kapat"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }

  // Create a new user account
  Future<String?> _loginAccount() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _loginEmail, password: _loginPassword);
      return null;
    } on FirebaseAuthException catch(e) {
      if (e.code == 'user-not-found') {
        return 'E-mail hasabı bulunamadı!';
      }else if (e.code == 'wrong-password') {
        return 'Şifre Yanlış.';
      }
      return e.message;

    } catch (e) {
      return e.toString();
    }
  }

  void _submitForm() async {
    setState(() {
      _loginFormLoading = true;
    });

    String? _loginFeedback = await _loginAccount();

    if(_loginFeedback != null) {
      _alertDialogBuilder(_loginFeedback);

      setState(() {
        _loginFormLoading = false;
      });
    }
  }

  bool _loginFormLoading = false;

  String _loginEmail = "";
  String _loginPassword = "";

  FocusNode? _passwordFocusNode;

  @override
  void initState() {
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
              Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*Container(
                    child: Image.asset(
                      'assets/images/appicon.png',
                      height: 150.0,
                      width: 100.0,
                    ),
                  ),*/
                  Container(
                    child: Text(
                      "Hoşgeldin,\nHemen Başlayalım!",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Column(
                    children: [
                      CustomInput(
                        hintText: "Email...",
                        onChanged: (value) {
                          _loginEmail = value;
                        },
                        onSubmitted: (value) {
                          _passwordFocusNode!.requestFocus();
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      CustomInput(
                        hintText: "Şifre...",
                        onChanged: (value) {
                          _loginPassword = value;
                        },
                        focusNode: _passwordFocusNode,
                        isPasswordField: true,
                        onSubmitted: (value) {
                          _submitForm();
                        },
                      ),
                      CustomBtn(
                        text: "Giriş Yap",
                        onPressed: () {
                          _submitForm();
                        },
                        isLoading: _loginFormLoading,
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                    ),
                    child: CustomBtn(
                      text: "Hesap Oluştur",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()
                          ),
                        );
                      },
                      outlineBtn: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

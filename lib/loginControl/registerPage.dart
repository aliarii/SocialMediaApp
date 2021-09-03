import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:socialnetworkapp/pages/homePage.dart';
import 'package:socialnetworkapp/widgets/CustomButton.dart';
import 'package:socialnetworkapp/widgets/CustomInput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  GUser? currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
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
  _createCategory() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? gCurrentUser = auth.currentUser;
    final uid = gCurrentUser!.uid;
    DocumentSnapshot documentSnapshot =
    await usersReference.doc(uid).get();
    if(!documentSnapshot.exists){
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        "following":[],
        "followers":[],
        "id": uid,
        "userName": _nameSurname,
        "userEmail": _registerEmail,
        "timestamp": DateTime.now(),
        "profileName": _userProfileName,
        "url": "https://firebasestorage.googleapis.com/v0/b/social-network-e5ffd.appspot.com/o/emptyuser.png?alt=media&token=8e78232b-2f8e-4308-acbb-fdaf03d7764c",
        "bio": "",
      });

      documentSnapshot = await usersReference.doc(gCurrentUser.uid).get();
    }

    currentUser = GUser.fromDocument(documentSnapshot);
  }

  Future<String?> _createAccount() async {

    try {
      UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _registerEmail!, password: _registerPassword!);
      User? user = result.user;
      user!.updateDisplayName(_nameSurname);
      return null;
    } on FirebaseAuthException catch(e) {
      if (e.code == 'weak-password') {
        return 'Daha güçlü bir şifre seçin.';
      } else if (e.code == 'email-already-in-use') {
        return 'Bu email hesabına kayıtlı bir üyelik var.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }

  }

  void _submitForm() async {
    setState(() {
      _registerFormLoading = true;
    });

    String? _createAccountFeedback = await _createAccount();

    if(_createAccountFeedback != null) {
      _alertDialogBuilder(_createAccountFeedback);
      setState(() {
        _registerFormLoading = false;
      });
    } else {
      _createCategory();
      Navigator.pop(context);
    }
  }

  bool _registerFormLoading = false;
  String? _registerEmail;
  String? _registerPasswordConfirm;
  String? _registerPassword;
  String? _nameSurname;
  String? _userProfileName;
  FocusNode? _passwordFocusNode;
  FocusNode? _passwordConfirmFocusNode;
  
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
          children:<Widget> [
            Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 24.0,
                    ),
                    child: Text(
                      "Yeni Hesap Oluştur",
                      textAlign: TextAlign.center,

                    ),
                  ),
                  Column(
                    children: [
                      CustomInput(
                        hintText: "Email...",
                        onChanged: (value) {
                          _registerEmail = value;
                        },
                        onSubmitted: (value) {
                          _passwordFocusNode!.requestFocus();
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      CustomInput(
                        hintText: "Ad Soyad...",
                        onChanged: (value) {
                          _nameSurname = value;
                        },
                        onSubmitted: (value) {
                          _passwordFocusNode!.requestFocus();
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      CustomInput(
                        hintText: "Kullanıcı Adı...",
                        onChanged: (value) {
                          _userProfileName = value;
                        },
                        onSubmitted: (value) {
                          _passwordFocusNode!.requestFocus();
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      CustomInput(
                        hintText: "Şifre...",
                        onChanged: (value) {
                          _registerPassword = value;
                        },
                        focusNode: _passwordFocusNode,
                        isPasswordField: true,
                        textInputAction: TextInputAction.next,
                      ),
                      CustomInput(
                        hintText: "Şifreyi Doğrula...",
                        onChanged: (value) {
                          _registerPasswordConfirm = value;
                        },
                        focusNode: _passwordConfirmFocusNode,
                        isPasswordField: true,
                      ),

                      CustomBtn(
                        text: "Oluştur",
                        onPressed: () {
                          if(_registerEmail==null){
                            _alertDialogBuilder("E-mail girin!");
                          }
                          if(_nameSurname==null){
                            _alertDialogBuilder("Ad Soyad girin!");
                          }
                          if(_userProfileName==null){
                            _alertDialogBuilder("Kullanıcı adı girin!");
                          }
                          if(_registerPassword!=null && _registerPassword==_registerPasswordConfirm){
                            _submitForm();
                          }
                          else{
                            _alertDialogBuilder("Şifreler aynı değil!");
                          }
                        },
                        isLoading: _registerFormLoading,
                      ),

                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                    ),
                    child: CustomBtn(
                      text: "Giriş Sayfasına Dön",
                      onPressed: () {
                        Navigator.pop(context);
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

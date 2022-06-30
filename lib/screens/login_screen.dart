import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/reuseable_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '-', password = '-';
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  bool _passwordVisible = true;
  String _validEmail = '', _validPassword = '';

  void buttonEnable() async {
    _validEmail = '';
    _validPassword = '';

    setState(() {
      if ('-' != email && '-' != password) {
        showSpinner = true;
      }
      if (email == '-') {
        _validEmail = 'Please enter the email';
      }
      if (password == '-') {
        _validPassword = 'Please enter the Password';
      }
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: 's@gmail.com', password: '123456');

      if (userCredential != null) {
        Navigator.pushNamed(context, ChatScreen.id);
      }
      setState(() {
        showSpinner = false;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _validEmail = 'email not found/register';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _validPassword = 'Please enter the  password';
        });
      }
      setState(() {
        showSpinner = false;
      });
    }
  }

  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  if (value.isEmpty)
                    email = '-';
                  else
                    email = value;
                },
                decoration: kInputDecorationField.copyWith(
                  hintText: 'Enter your email',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
                child: Text(
                  _validEmail,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: _passwordVisible,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  if (value.isEmpty)
                    password = '-';
                  else
                    password = value;
                },
                decoration: kInputDecorationField.copyWith(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    icon: Icon(
                      color: Theme.of(context).primaryColorDark,
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  hintText: 'Enter your password',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
                child: Text(
                  _validPassword,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              ReusableButton(
                textChild: 'Log In',
                colour: Colors.lightBlueAccent,
                onpress: () {
                  if (_validEmail == '-' || _validPassword == '-') ;
                  if (isValidEmail() != true)
                    setState(() {
                      _validEmail = 'Enter valid email';
                    });
                  else
                    buttonEnable();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

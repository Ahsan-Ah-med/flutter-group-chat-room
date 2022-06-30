import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/components/reuseable_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email = '-', password = '-';
  final _auth = FirebaseAuth.instance;
  bool _passwordVisible = true;
  String _validEmail = '', _validPassword = '';
  bool showSpinner = false;

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
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("afasgasgajkfklasjglfas");
      if (userCredential != null) {
        Navigator.pushNamed(context, ChatScreen.id);
      }
      setState(() {
        showSpinner = false;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          if (password != '-') {
            _validPassword = 'Password to weak';
          }
          showSpinner = false;
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _validEmail = 'This email is already in use';
          showSpinner = false;
        });
      }
    } catch (e) {
      print(e);
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
                  if (!value.isEmpty) email = value;
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
                  if (!value.isEmpty) password = value;
                },
                decoration: kInputDecorationField.copyWith(
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
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
                textChild: 'Register',
                colour: Colors.blueAccent,
                onpress: () {
                  if (_validEmail == '-' || _validPassword == '-') ;
                  if (isValidEmail() != true)
                    setState(() {
                      _validEmail = 'Enter valid email';
                    });
                  else
                    buttonEnable();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:connect_firebase/Screens/home_page.dart';
import 'package:connect_firebase/core/widgets/custom_textfied.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final name = TextEditingController();
  final password = TextEditingController();
  bool isRec = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isRec
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextfied(
                      hintText: 'Name',
                      controller: name,
                    ),
                    const SizedBox(height: 15),
                    CustomTextfied(
                      hintText: 'Email',
                      controller: email,
                    ),
                    const SizedBox(height: 15),
                    CustomTextfied(
                      hintText: 'Password',
                      controller: password,
                    ),
                    const SizedBox(height: 15),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            setState(() {
                              isRec = true;
                            });
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: email.text,
                              password: password.text,
                            )
                                .then((val) {
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(email: val.user!.email!),
                                  ),
                                  (rout) => false,
                                );
                              }
                              setState(() {
                                isRec = false;
                              });
                            });
                            name.clear();
                            email.clear();
                            password.clear();
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              log('The password provided is too weak.');
                            } else if (e.code == 'email-already-in-use') {
                              log('The account already exists for that email.');
                            }
                            setState(() {
                              isRec = false;
                            });
                          } catch (e) {
                            log(e.toString());
                            setState(() {
                              isRec = false;
                            });
                          }
                        }
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

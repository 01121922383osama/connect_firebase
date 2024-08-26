import 'dart:developer';

import 'package:connect_firebase/Screens/home_Page.dart';
import 'package:connect_firebase/Screens/sign_up_page.dart';
import 'package:connect_firebase/core/widgets/custom_textfied.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLoged = false;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((user) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomePage(email: user.user!.email!),
          ));
        }
        return null;
      });
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: isLoged
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            setState(() {
                              isLoged = true;
                            });
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: email.text,
                              password: password.text,
                            )
                                .then((val) {
                              log('Login Successful');
                              setState(() {
                                isLoged = false;
                              });
                              if (context.mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(email: val.user!.email!),
                                  ),
                                );
                              }
                            });
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              log('No user found for that email.');
                            }
                            if (e.code == 'wrong-password') {
                              log('Wrong password provided for that user.');
                            }
                            setState(() {
                              isLoged = false;
                            });
                          } catch (e) {
                            log(e.toString());
                          }
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      child: const Text('Sign Up'),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () => signInWithGoogle(),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Sign in with'),
                            const SizedBox(width: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                'assets/google.png',
                                height: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_firebase/Screens/login_page.dart';
import 'package:connect_firebase/core/widgets/custom_textfied.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  final String email;
  const HomePage({super.key, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final database = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  List<Map<String, dynamic>>? posts = [];
  final age = TextEditingController();
  final name = TextEditingController();
  bool isPrgrammer = false;
  bool isCall = false;
  File? image;
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.email),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ));
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isCall
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: posts?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: posts?[index]['isProgrammer']
                        ? Colors.red.withOpacity(0.4)
                        : Colors.white.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onLongPress: () => deletPost(),
                      onTap: () => updatge(
                        userName: posts?[index]['name'],
                        userAge: posts?[index]['age'],
                      ),
                      leading: posts?[index]['profileimage'] == null
                          ? null
                          : CircleAvatar(
                              backgroundImage:
                                  NetworkImage(posts?[index]['profileimage']),
                            ),
                      title: Text(posts?[index]['name']),
                      subtitle: Text(posts?[index]['email']),
                      trailing: CircleAvatar(child: Text(posts?[index]['age'])),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => addPost(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: image == null ? Colors.red : Colors.green,
            onPressed: () => uploudImage(),
            child: const Icon(Icons.photo),
          ),
        ],
      ),
    );
  }

  void uploudImage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Uploud Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? imageData = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (imageData != null) {
                    setState(() {
                      image = File(imageData.path);
                    });
                    final storage = FirebaseStorage.instance.ref();
                    final data = await storage.child('images').putFile(image!);
                    imageUrl = await data.storage
                        .ref()
                        .child('images')
                        .getDownloadURL();
                  }
                },
                child: const Text('Camera'),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? imageData = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (imageData != null) {
                    setState(() {
                      image = File(imageData.path);
                    });
                    final storage = FirebaseStorage.instance.ref();
                    final data = await storage.child('images').putFile(image!);
                    imageUrl = await data.storage
                        .ref()
                        .child('images')
                        .getDownloadURL();
                  }
                },
                child: const Text('Gallery'),
              ),
            ],
          ),
        );
      },
    );
  }

  void getPosts() async {
    setState(() {
      posts?.clear();
      isCall = true;
    });
    await database
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .get()
        .then((data) {
      setState(() {
        posts?.addAll(data.docs.map((data) => data.data()).toList());
        setState(() {
          isCall = false;
        });
      });
    });
  }

  void addPost() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextfied(
                hintText: 'Name',
                controller: name,
              ),
              const SizedBox(height: 15),
              CustomTextfied(
                hintText: 'Age',
                keyboardType: TextInputType.number,
                controller: age,
              ),
              const SizedBox(height: 15),
              Switch(
                  value: isPrgrammer,
                  onChanged: (valu) {
                    setState(() {
                      isPrgrammer = valu;
                    });
                  }),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  setState(() {
                    isCall = true;
                  });
                  await database.collection('users').doc(user.uid).set({
                    'id': user.uid,
                    'email': user.email,
                    'name': name.text,
                    'age': age.text,
                    'isProgrammer': isPrgrammer,
                    'profileimage': imageUrl,
                  }).then((va) {
                    setState(() {
                      getPosts();
                      isCall = false;
                    });
                  });
                  name.clear();
                  age.clear();
                  isPrgrammer = false;
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void deletPost() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  isCall = true;
                });
                await database
                    .collection('users')
                    .doc(user.uid)
                    .delete()
                    .then((value) {
                  setState(() {
                    getPosts();
                    isCall = false;
                  });
                });
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void updatge({required String userName, required String userAge}) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextfied(
                hintText: userName,
                controller: name,
              ),
              const SizedBox(height: 15),
              CustomTextfied(
                hintText: userAge,
                keyboardType: TextInputType.number,
                controller: age,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  setState(() {
                    isCall = true;
                  });
                  await database.collection('users').doc(user.uid).update({
                    'id': user.uid,
                    'email': user.email,
                    'name': name.text,
                    'age': age.text,
                    'isProgrammer': isPrgrammer,
                  }).then((va) {
                    setState(() {
                      getPosts();
                      isCall = false;
                    });
                  });
                  name.clear();
                  age.clear();
                  isPrgrammer = false;
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ignore_for_file: file_names, non_constant_identifier_names, depend_on_referenced_packages, prefer_typing_uninitialized_variables, use_build_context_synchronously

// import 'dart:html';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:pg_helper/saveSharePreferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}
class _EditProfileState extends State<EditProfile> {
  var imagePath =
      "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/UserImage%2FDefaultProfileImage.png?alt=media";
  late Query Ref;
  late Map data;
  late TextEditingController controllerUsername;
  late TextEditingController controllerFirstName;
  late TextEditingController controllerLastName;
  late TextEditingController controllerMail;
  late TextEditingController controllerDateOfBirth;
  late TextEditingController controllerBloodGroup;
  var birthDate = "Select Birthdate";
  var selectedValue = 0;
  var selectedGender;
  late String username;
  late String userKey;
  late String fileName;
  String imageName = "";
  late String email;
  late String userFirstName;
  late String userLastName;
  final key = 'username';
  final key1 = 'email';
  final key2 = 'userFirstName';
  final key3 = 'userLastName';
  File? _image; // Make _image nullable

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        fileName = basename(_image!.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff12d3c6),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            // If the Future is complete, show the actual UI
            return SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Update Account Information",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _image != null
                                ? Image.file(_image!,
                                height: 110, width: 110, fit: BoxFit.cover)
                                : Image.network(
                              imagePath,
                              height: MediaQuery.of(context).size.height *
                                  0.1,
                              width: MediaQuery.of(context).size.height *
                                  0.15,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.cloud_upload,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Upload Image",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff12d3c6)),
                            onPressed: () {
                              getImage();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: controllerUsername,
                        enabled: false,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "Username",
                          prefixIcon:
                          Icon(Icons.person, color: Color(0xff12d3c6)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: TextFormField(
                                controller: controllerFirstName,
                                decoration: const InputDecoration(
                                  hintText: "First Name",
                                  prefixIcon: Icon(Icons.person,
                                      color: Color(0xff12d3c6)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: TextFormField(
                                controller: controllerLastName,
                                decoration: const InputDecoration(
                                  hintText: "Last Name",
                                  prefixIcon: Icon(Icons.person,
                                      color: Color(0xff12d3c6)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: controllerMail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Email Address",
                          prefixIcon:
                          Icon(Icons.mail, color: Color(0xff12d3c6)),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(15))),
                        ),
                      ),
                    ),
                    // Gender
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              const Text(
                                'Gender:',
                                style: TextStyle(fontSize: 18),
                              ),
                              Radio(
                                value: "Male",
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },
                              ),
                              const Text(
                                'Male',
                                style: TextStyle(fontSize: 18),
                              ),
                              Radio(
                                value: "Female",
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },
                              ),
                              const Text(
                                'Female',
                                style: TextStyle(fontSize: 18),
                              ),
                              Radio(
                                value: "Other",
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },
                              ),
                              const Text(
                                'Other',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: controllerBloodGroup,
                        decoration: const InputDecoration(
                          hintText: "Blood Group",
                          prefixIcon:
                          Icon(Icons.bloodtype, color: Color(0xff12d3c6)),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(15))),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: controllerDateOfBirth,
                        readOnly: true,
                        // Make the text input read-only
                        decoration: InputDecoration(
                          hintText: birthDate,
                          prefixIcon: GestureDetector(
                            onTap: () {
                              _getDate(context);
                            },
                            child: const Icon(
                              Icons.date_range,
                              color: Color(0xff12d3c6),
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          filled: true,
                          fillColor: const Color(0xffE0E3E7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          updateData(userKey, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff12d3c6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        },
        future: _loadUserData(),
      ),
    );
  }

  Future<void> _getDate(BuildContext context) async {
    var datePicked = await DatePicker.showSimpleDatePicker(
      context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2090),
      dateFormat: "dd-MM-yyyy",
      locale: DateTimePickerLocale.en_us,
      looping: true,
    );
    setState(() {
      if (datePicked != null) {
        birthDate = "${datePicked.day}-${datePicked.month}-${datePicked.year}";
        controllerDateOfBirth = TextEditingController(text: birthDate);
      }
    });
  }

  @override
  void dispose() {
    controllerUsername.dispose();
    controllerFirstName.dispose();
    controllerLastName.dispose();
    controllerMail.dispose();
    controllerDateOfBirth.dispose();
    controllerBloodGroup.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    String? userData = await getData(key);
    String? userEmail = await getData(key1);
    String? userkey = await getKey();

    username = userData!;
    email = userEmail!;
    userKey = userkey!;

    Ref = FirebaseDatabase.instance
        .ref()
        .child("PG_helper/tblUser")
        .orderByChild("Username")
        .equalTo(username);

    await Ref.once().then((documentSnapshot) async {
      for (var x in documentSnapshot.snapshot.children) {
        data = x.value as Map;
        controllerUsername = TextEditingController(text: data["Username"]);
        controllerFirstName = TextEditingController(text: data["FirstName"]);
        controllerLastName = TextEditingController(text: data["LastName"]);
        controllerMail = TextEditingController(text: data["Email"]);
        controllerDateOfBirth = TextEditingController(text: data["DOB"]);
        controllerBloodGroup = TextEditingController(text: data["BloodGroup"]);
        selectedGender ??= data["Gender"];
        if (data["Photo"] != null) {
          imagePath =
          "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/UserImage%2F${data["Photo"]}?alt=media";
          imageName = data["Photo"];
        }
      }
    });
  }

  Future uploadImage() async {
    fileName = basename(_image!.path);
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child("UserImage/$fileName");
    firebaseStorageRef.putFile(_image!);
  }

  void updateData(String userkey, BuildContext context) async {
    if (_image != null) {
      final updatedData = {
        "Username": controllerUsername.text,
        "FirstName": controllerFirstName.text,
        "LastName": controllerLastName.text,
        "Email": controllerMail.text,
        "DOB": controllerDateOfBirth.text,
        "Gender": selectedGender,
        "BloodGroup": controllerBloodGroup.text,
        "Photo": fileName,
      };
      uploadImage();
      if (imageName != "") {
        final desertRef = FirebaseStorage.instance.ref("UserImage/$imageName");
        await desertRef.delete();
      }
      final userRef = FirebaseDatabase.instance
          .ref()
          .child("PG_helper/tblUser")
          .child(userkey);
      await userRef.update(updatedData);
    } else {
      final updatedData = {
        "Username": controllerUsername.text,
        "FirstName": controllerFirstName.text,
        "LastName": controllerLastName.text,
        "Email": controllerMail.text,
        "DOB": controllerDateOfBirth.text,
        "Gender": selectedGender,
        "BloodGroup": controllerBloodGroup.text,
      };
      final userRef = FirebaseDatabase.instance
          .ref()
          .child("PG_helper/tblUser")
          .child(userkey);
      await userRef.update(updatedData);
      Navigator.pop(context);
    }
  }
}
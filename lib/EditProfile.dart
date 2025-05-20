// ignore_for_file: file_names, non_constant_identifier_names, depend_on_referenced_packages, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:pg_helper/saveSharePreferences.dart';

// class EditProfile extends StatelessWidget {
//   const EditProfile({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("View Profile")),
//       body: const Center(child: Text("This is the View Profile screen")),
//     );
//   }
// }

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
  var selectedGender;
  late String username;
  late String userKey;
  late String fileName;
  String imageName = "";
  late String email;
  File? _image;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        fileName = basename(_image!.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff12d3c6),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder(
        future: _loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _image != null
                            ? Image.file(_image!, height: 110, width: 110, fit: BoxFit.cover)
                            : Image.network(imagePath, height: 110, width: 110, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_upload, color: Colors.white),
                        label: const Text("Upload Image", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff12d3c6)),
                        onPressed: getImage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controllerUsername,
                    enabled: false,
                    decoration: const InputDecoration(
                      hintText: "Username",
                      prefixIcon: Icon(Icons.person, color: Color(0xff12d3c6)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controllerFirstName,
                          decoration: const InputDecoration(
                            hintText: "First Name",
                            prefixIcon: Icon(Icons.person, color: Color(0xff12d3c6)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: controllerLastName,
                          decoration: const InputDecoration(
                            hintText: "Last Name",
                            prefixIcon: Icon(Icons.person, color: Color(0xff12d3c6)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controllerMail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.mail, color: Color(0xff12d3c6)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Gender:', style: TextStyle(fontSize: 18)),
                  Row(
                    children: ["Male", "Female", "Other"].map((gender) {
                      return Row(
                        children: [
                          Radio<String>(
                            value: gender,
                            groupValue: selectedGender,
                            onChanged: (value) => setState(() => selectedGender = value),
                          ),
                          Text(gender, style: const TextStyle(fontSize: 18)),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controllerBloodGroup,
                    decoration: const InputDecoration(
                      hintText: "Blood Group",
                      prefixIcon: Icon(Icons.bloodtype, color: Color(0xff12d3c6)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controllerDateOfBirth,
                    readOnly: true,
                    onTap: () => _getDate(context),
                    decoration: InputDecoration(
                      hintText: birthDate,
                      prefixIcon: const Icon(Icons.date_range, color: Color(0xff12d3c6)),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => updateData(userKey, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff12d3c6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
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
    if (datePicked != null) {
      birthDate = "${datePicked.day}-${datePicked.month}-${datePicked.year}";
      setState(() => controllerDateOfBirth = TextEditingController(text: birthDate));
    }
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
    String? userData = await getData('username');
    String? userEmail = await getData('email');
    String? userkey = await getKey();

    username = userData!;
    email = userEmail!;
    userKey = userkey!;

    Ref = FirebaseDatabase.instance
        .ref()
        .child("PG_helper/tblUser")
        .orderByChild("Username")
        .equalTo(username);

    final documentSnapshot = await Ref.once();
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
  }

  Future uploadImage() async {
    fileName = basename(_image!.path);
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child("UserImage/$fileName");
    await firebaseStorageRef.putFile(_image!);
  }

  void updateData(String userkey, BuildContext context) async {
    final updatedData = {
      "Username": controllerUsername.text,
      "FirstName": controllerFirstName.text,
      "LastName": controllerLastName.text,
      "Email": controllerMail.text,
      "DOB": controllerDateOfBirth.text,
      "Gender": selectedGender,
      "BloodGroup": controllerBloodGroup.text,
      if (_image != null) "Photo": fileName,
    };

    if (_image != null) {
      await uploadImage();
      if (imageName != "") {
        final desertRef = FirebaseStorage.instance.ref("UserImage/$imageName");
        await desertRef.delete();
      }
    }

    final userRef = FirebaseDatabase.instance.ref().child("PG_helper/tblUser").child(userkey);
    await userRef.update(updatedData);

    // Redirect to ViewProfile page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EditProfile()),
    );
  }
}

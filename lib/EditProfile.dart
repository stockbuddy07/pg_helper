// ignore_for_file: file_names, non_constant_identifier_names, depend_on_referenced_packages, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:pg_helper/saveSharePreferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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
  late String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
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
              children: [
              CircleAvatar(
              radius: 40,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '',
                  style: const TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              const Text("User Profile", style: TextStyle(fontSize: 18)),
              ],
            ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controllerUsername,
                    enabled: false,
                    decoration: const InputDecoration(
                      hintText: "Username",
                      prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
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
                            prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
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
                            prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
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
                      prefixIcon: Icon(Icons.mail, color: Colors.blueAccent),
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
                      prefixIcon: Icon(Icons.bloodtype, color: Colors.blueAccent),
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
                      prefixIcon: const Icon(Icons.date_range, color: Colors.blueAccent),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => updateData(userKey, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
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
    }
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
    };

    final userRef = FirebaseDatabase.instance.ref().child("PG_helper/tblUser").child(userkey);
    await userRef.update(updatedData);

    // Go back after saving
    Navigator.pop(context);
  }
}

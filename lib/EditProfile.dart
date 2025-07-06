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
  late TextEditingController controllerContact;
  late TextEditingController controllerDateOfBirth;
  late TextEditingController controllerBloodGroup;
  var birthDate = "Select Birthdate";
  var selectedGender;
  late String username;
  late String userKey;
  late String email;
  bool isLoading = true;

  // Focus nodes
  late FocusNode firstNameFocus;
  late FocusNode lastNameFocus;
  late FocusNode emailFocus;
  late FocusNode contactFocus;
  late FocusNode bloodGroupFocus;

  @override
  void initState() {
    super.initState();
    controllerUsername = TextEditingController();
    controllerFirstName = TextEditingController();
    controllerLastName = TextEditingController();
    controllerMail = TextEditingController();
    controllerContact = TextEditingController();
    controllerDateOfBirth = TextEditingController();
    controllerBloodGroup = TextEditingController();

    firstNameFocus = FocusNode();
    lastNameFocus = FocusNode();
    emailFocus = FocusNode();
    contactFocus = FocusNode();
    bloodGroupFocus = FocusNode();

    _loadUserData();
  }

  @override
  void dispose() {
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    emailFocus.dispose();
    contactFocus.dispose();
    bloodGroupFocus.dispose();

    controllerUsername.dispose();
    controllerFirstName.dispose();
    controllerLastName.dispose();
    controllerMail.dispose();
    controllerContact.dispose();
    controllerDateOfBirth.dispose();
    controllerBloodGroup.dispose();
    super.dispose();
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '',
                        style: const TextStyle(fontSize: 28, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Username Field (always visible label)
              const Text('Username', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              TextFormField(
                controller: controllerUsername,
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // First Name Field
              if (firstNameFocus.hasFocus)
                const Text('First Name', style: TextStyle(fontSize: 14, color: Colors.grey)),
              if (firstNameFocus.hasFocus) const SizedBox(height: 4),
              TextFormField(
                controller: controllerFirstName,
                focusNode: firstNameFocus,
                decoration: InputDecoration(
                  hintText: "First Name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Last Name Field
              if (lastNameFocus.hasFocus)
                const Text('Last Name', style: TextStyle(fontSize: 14, color: Colors.grey)),
              if (lastNameFocus.hasFocus) const SizedBox(height: 4),
              TextFormField(
                controller: controllerLastName,
                focusNode: lastNameFocus,
                decoration: InputDecoration(
                  hintText: "Last Name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              if (emailFocus.hasFocus)
                const Text('Email', style: TextStyle(fontSize: 14, color: Colors.grey)),
              if (emailFocus.hasFocus) const SizedBox(height: 4),
              TextFormField(
                controller: controllerMail,
                focusNode: emailFocus,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Contact Field
              if (contactFocus.hasFocus)
                const Text('Contact Number', style: TextStyle(fontSize: 14, color: Colors.grey)),
              if (contactFocus.hasFocus) const SizedBox(height: 4),
              TextFormField(
                controller: controllerContact,
                focusNode: contactFocus,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Enter your phone number",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Gender Field (always visible label)
              const Text('Gender', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: ["Male", "Female", "Other"].map((gender) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: gender,
                          groupValue: selectedGender,
                          onChanged: (value) => setState(() => selectedGender = value),
                        ),
                        Text(gender),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Blood Group Field
              if (bloodGroupFocus.hasFocus)
                const Text('Blood Group', style: TextStyle(fontSize: 14, color: Colors.grey)),
              if (bloodGroupFocus.hasFocus) const SizedBox(height: 4),
              TextFormField(
                controller: controllerBloodGroup,
                focusNode: bloodGroupFocus,
                decoration: InputDecoration(
                  hintText: "Enter your blood group",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Date of Birth Field (always visible label)
              const Text('Date of Birth', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              TextFormField(
                controller: controllerDateOfBirth,
                readOnly: true,
                onTap: () => _getDate(context),
                decoration: InputDecoration(
                  hintText: birthDate,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => updateData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "SAVE CHANGES",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
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
      setState(() {
        birthDate = "${datePicked.day}-${datePicked.month}-${datePicked.year}";
        controllerDateOfBirth.text = birthDate;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      String? userData = await getData('username');
      String? userEmail = await getData('email');
      String? userkey = await getKey();

      if (userData == null || userEmail == null || userkey == null) {
        throw Exception("User data not found in shared preferences");
      }

      username = userData;
      email = userEmail;
      userKey = userkey;

      Ref = FirebaseDatabase.instance
          .ref()
          .child("PG_helper/tblUser")
          .orderByChild("Username")
          .equalTo(username);

      final documentSnapshot = await Ref.once();
      if (documentSnapshot.snapshot.value != null) {
        for (var x in documentSnapshot.snapshot.children) {
          data = x.value as Map;
          setState(() {
            controllerUsername.text = data["Username"] ?? '';
            controllerFirstName.text = data["FirstName"] ?? '';
            controllerLastName.text = data["LastName"] ?? '';
            controllerMail.text = data["Email"] ?? '';
            controllerContact.text = data["Contact"] ?? '';
            controllerDateOfBirth.text = data["DOB"] ?? '';
            controllerBloodGroup.text = data["BloodGroup"] ?? '';
            selectedGender = data["Gender"] ?? '';
            birthDate = data["DOB"] ?? "Select Birthdate";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void updateData() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      final updatedData = {
        "Username": controllerUsername.text,
        "FirstName": controllerFirstName.text,
        "LastName": controllerLastName.text,
        "Email": controllerMail.text,
        "Contact": controllerContact.text,
        "DOB": controllerDateOfBirth.text,
        "Gender": selectedGender,
        "BloodGroup": controllerBloodGroup.text,
      };

      final userRef = FirebaseDatabase.instance.ref().child("PG_helper/tblUser").child(userKey);
      await userRef.update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
      }
    }
  }
}
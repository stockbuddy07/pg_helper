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
  late String originalContact; // To track contact changes

  // Focus nodes
  late FocusNode firstNameFocus;
  late FocusNode lastNameFocus;
  late FocusNode emailFocus;
  late FocusNode contactFocus;
  late FocusNode bloodGroupFocus;
  late FocusNode _currentFocusNode;
  bool _isEditing = false;

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
    _currentFocusNode = FocusNode();

    _loadUserData();
  }

  @override
  void dispose() {
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    emailFocus.dispose();
    contactFocus.dispose();
    bloodGroupFocus.dispose();
    _currentFocusNode.dispose();

    controllerUsername.dispose();
    controllerFirstName.dispose();
    controllerLastName.dispose();
    controllerMail.dispose();
    controllerContact.dispose();
    controllerDateOfBirth.dispose();
    controllerBloodGroup.dispose();
    super.dispose();
  }

  void _handleCardTap(FocusNode focusNode) {
    if (_currentFocusNode.hasFocus) {
      _currentFocusNode.unfocus();
    }
    setState(() {
      _currentFocusNode = focusNode;
      _isEditing = true;
    });
    FocusScope.of(context).requestFocus(focusNode);
  }

  IconData _getIconForField(String title) {
    switch (title) {
      case 'Name':
        return Icons.person_outline;
      case 'Username':
        return Icons.alternate_email;
      case 'Email':
        return Icons.email_outlined;
      case 'Contact':
        return Icons.phone_iphone_outlined;
      case 'Date of Birth':
        return Icons.calendar_today_outlined;
      case 'Blood Group':
        return Icons.favorite_border_outlined;
      case 'Gender':
        return Icons.transgender_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildProfileCard({
    required String title,
    required String value,
    required FocusNode focusNode,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool isDateField = false,
    bool isEditable = true,
  }) {
    return GestureDetector(
      onTap: isDateField
          ? () => _getDate(context)
          : isEditable
          ? () => _handleCardTap(focusNode)
          : null,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: _currentFocusNode == focusNode
              ? Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              _getIconForField(title),
              color: Colors.blueAccent,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  isDateField
                      ? Text(
                    value.isEmpty ? "Select Birthdate" : value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: value.isEmpty ? Colors.grey[400] : Colors.black87,
                    ),
                  )
                      : _currentFocusNode == focusNode && isEditable
                      ? TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: keyboardType,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  )
                      : Text(
                    value.isEmpty ? "Not provided" : value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: value.isEmpty ? Colors.grey[400] : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (isDateField) const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blueAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return isLoading
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          )
              : GestureDetector(
            onTap: () {
              if (_currentFocusNode.hasFocus) {
                _currentFocusNode.unfocus();
                setState(() => _isEditing = false);
              }
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: 600, // Max width for larger screens
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 600 ? 24 : 16,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // Profile Header Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: constraints.maxWidth > 600 ? 48 : 42,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                username.isNotEmpty ? username[0].toUpperCase() : '',
                                style: TextStyle(
                                  fontSize: constraints.maxWidth > 600 ? 40 : 36,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "${controllerFirstName.text} ${controllerLastName.text}".trim(),
                              style: TextStyle(
                                fontSize: constraints.maxWidth > 600 ? 22 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@$username',
                              style: TextStyle(
                                fontSize: constraints.maxWidth > 600 ? 16 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Username (non-editable)
                      _buildProfileCard(
                        title: 'Username',
                        value: controllerUsername.text,
                        focusNode: FocusNode(),
                        controller: controllerUsername,
                        isEditable: false,
                      ),

                      // First Name
                      _buildProfileCard(
                        title: 'Name',
                        value: controllerFirstName.text,
                        focusNode: firstNameFocus,
                        controller: controllerFirstName,
                      ),

                      // Last Name
                      _buildProfileCard(
                        title: 'Last Name',
                        value: controllerLastName.text,
                        focusNode: lastNameFocus,
                        controller: controllerLastName,
                      ),

                      // Email
                      _buildProfileCard(
                        title: 'Email',
                        value: controllerMail.text,
                        focusNode: emailFocus,
                        controller: controllerMail,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      // Contact
                      _buildProfileCard(
                        title: 'Contact',
                        value: controllerContact.text,
                        focusNode: contactFocus,
                        controller: controllerContact,
                        keyboardType: TextInputType.phone,
                      ),

                      // Date of Birth
                      _buildProfileCard(
                        title: 'Date of Birth',
                        value: controllerDateOfBirth.text,
                        focusNode: FocusNode(),
                        controller: controllerDateOfBirth,
                        isDateField: true,
                      ),

                      // Blood Group
                      _buildProfileCard(
                        title: 'Blood Group',
                        value: controllerBloodGroup.text,
                        focusNode: bloodGroupFocus,
                        controller: controllerBloodGroup,
                      ),

                      // Gender
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.transgender_outlined,
                              color: Colors.blueAccent,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gender',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
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
                                                activeColor: Colors.blueAccent,
                                              ),
                                              Text(
                                                gender,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Save Button
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => updateData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "SAVE CHANGES",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
            controllerContact.text = data["ContactNumber"] ?? '';
            originalContact = data["ContactNumber"] ?? ''; // Store original contact
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

  Future<void> _updateBedContactInfo() async {
    try {
      // Only proceed if contact number has changed
      if (controllerContact.text == originalContact) {
        return;
      }

      // Search all beds for this user's username
      final bedsRef = FirebaseDatabase.instance.ref().child("PG_helper/tblBeds");
      final bedsSnapshot = await bedsRef.get();

      if (bedsSnapshot.exists) {
        // Iterate through all rooms
        for (var room in bedsSnapshot.children) {
          // Iterate through all beds in each room
          for (var bed in room.children) {
            final bedData = bed.value as Map<dynamic, dynamic>;
            if (bedData['username'] == username) {
              // Update the contact number for this bed
              await bedsRef.child("${room.key}/${bed.key}").update({
                'contact': controllerContact.text,
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating bed contact info: $e')),
        );
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
        "ContactNumber": controllerContact.text,
        "DOB": controllerDateOfBirth.text,
        "Gender": selectedGender,
        "BloodGroup": controllerBloodGroup.text,
      };

      final userRef = FirebaseDatabase.instance.ref().child("PG_helper/tblUser").child(userKey);
      await userRef.update(updatedData);

      // Update contact in beds table if contact has changed
      await _updateBedContactInfo();

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